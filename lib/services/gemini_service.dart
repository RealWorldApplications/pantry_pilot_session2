import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────
// vision-orchestrator: output must be valid JSON with this exact schema.
class IngredientResult {
  const IngredientResult({
    required this.item,
    required this.recipe,
    required this.funFact,
    this.investigationMode = false,
  });

  /// Parses the model's raw JSON text into an [IngredientResult].
  factory IngredientResult.fromJson(Map<String, dynamic> json) {
    return IngredientResult(
      item: (json['item'] as String? ?? 'Unknown').trim(),
      recipe: (json['recipe'] as List<dynamic>? ?? [])
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      funFact: (json['funFact'] as String? ?? '').trim(),
    );
  }

  /// The identified ingredient name (title-cased).
  final String item;

  /// 3-5 concise preparation steps.
  final List<String> recipe;

  /// One interesting culinary fact.
  final String funFact;

  /// True when the Active Investigation retry path was used.
  final bool investigationMode;
}

// ─── Gemini Service ───────────────────────────────────────────────────────────
class GeminiService {
  // vision-orchestrator: use Gemini 3 Flash (Latest).
  static const _modelId = 'gemini-3-flash-preview';

  // Standard prompt for clear images.
  static String get _stdPrompt =>
      '''
You are a culinary AI assistant specialising in ingredient identification and safety.

Examine the ingredient visible in this image.

Respond ONLY with a single JSON object matching this schema exactly:
{
  "item": "<ingredient name, title-cased>",
  "recipe": ["<step 1>", "<step 2>", "<step 3>"],
  "funFact": "<one interesting culinary fact about this ingredient>"
}

Rules:
- "item": the ingredient name in title case.
- "recipe": exactly 3–5 concise, preparation steps.
- "funFact": one sentence, surprising fact.
- Output MUST be pure JSON.
''';

  // vision-orchestrator rule 3: Active Investigation prompt for blurry images.
  static String get _activeInvestigationPrompt =>
      '''
ACTIVE INVESTIGATION MODE

The image may be low quality. Examine colour, texture, shape.

Respond ONLY with a single JSON object matching this schema exactly:
{
  "item": "<ingredient name, title-cased — best guess>",
  "recipe": ["<step 1>", "<step 2>", "<step 3>"],
  "funFact": "<one interesting culinary fact about this ingredient>"
}

Rules:
- "item": title-cased, best guess acceptable.
- "recipe": exactly 3–5 concise preparation steps.
- "funFact": one sentence, surprising fact.
- Output MUST be pure JSON.
''';

  // ── Blurriness heuristic ────────────────────────────────────────────────────
  // Blurry JPEG images have fewer high-frequency details and compress to
  // smaller files. For ResolutionPreset.medium (~640×480), a sharp image
  // typically exceeds 50 KB. Below that threshold we activate investigation.
  static bool _isBlurry(Uint8List bytes) => bytes.lengthInBytes < 50 * 1024;


  // ── Core analysis ───────────────────────────────────────────────────────────
  /// Sends [imageBytes] (JPEG) to Gemini for ingredient analysis.
  ///
  /// - Uses Active Investigation automatically if the image appears blurry.
  /// - Retries with Active Investigation if the first response isn't valid JSON.
  static Future<IngredientResult> analyze(
    Uint8List imageBytes,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception(
        'GEMINI_API_KEY is not set.\n'
        'Open .env and paste your key from ai.google.dev.',
      );
    }

    final model = GenerativeModel(model: _modelId, apiKey: apiKey);
    final blurry = _isBlurry(imageBytes);

    // vision-orchestrator rule 3: if blurry, skip directly to Active Investigation.
    final firstPrompt = blurry
        ? _activeInvestigationPrompt
        : _stdPrompt;

    final response = await model.generateContent([
      Content.multi([
        TextPart(firstPrompt),
        DataPart('image/jpeg', imageBytes),
      ]),
    ]);

    final rawText = response.text ?? '';
    debugPrint('Gemini Raw Response: $rawText');

    try {
      final base = IngredientResult.fromJson(
        _cleanAndParseJson(rawText),
      );
      return IngredientResult(
        item: base.item,
        recipe: base.recipe,
        funFact: base.funFact,
        investigationMode: blurry,
      );
    } catch (_) {
      // First parse failed — enter Active Investigation retry.
      final retryResponse = await model.generateContent([
        Content.multi([
          TextPart(_activeInvestigationPrompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);
      final retryRaw = retryResponse.text ?? '{}';
      final base = IngredientResult.fromJson(_cleanAndParseJson(retryRaw));
      return IngredientResult(
        item: base.item,
        recipe: base.recipe,
        funFact: base.funFact,
        investigationMode: true,
      );
    }
  }

  /// Extracts JSON from potential markdown code fences.
  static Map<String, dynamic> _cleanAndParseJson(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      final lines = cleaned.split('\n');
      if (lines.length > 2) {
        cleaned = lines.sublist(1, lines.length - 1).join('\n').trim();
      }
    }
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}
