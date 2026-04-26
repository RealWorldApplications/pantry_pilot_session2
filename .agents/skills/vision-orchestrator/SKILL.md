---
name: vision-orchestrator
description: Expert in Gemini 3 Multimodal Vision and Flutter Camera integration.
---
# Vision-Orchestrator Rules
1. Use the 'camera' package for the preview.
2. When Gemini returns a recipe, map it to a 'FloatingRecipeCard' widget.
3. Always use Gemini 3 'Active Investigation' if the image is blurry.
4. Output must be valid JSON: { "item": string, "recipe": string[], "funFact": string }.