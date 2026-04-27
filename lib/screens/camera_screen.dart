import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/gemini_service.dart';
import '../theme/pantry_theme.dart';
import '../widgets/camera_controls.dart';
import '../widgets/camera_state_views.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/floating_recipe_card.dart';
import '../widgets/top_bar.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  _CameraState _cameraState = _CameraState.initializing;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!isCameraSupported) {
      _setError(
        'Camera is not supported on this platform.\n\n'
        'Run on Android, iOS, Windows, or Web to use the camera.',
        isUnsupported: true,
      );
      return;
    }

    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        _setError('No cameras found on this device.');
        return;
      }
      await _initController(cameras.first);
    } catch (e) {
      _setError('Camera discovery failed:\n$e');
    }
  }

  Future<void> _initController(CameraDescription camera) async {
    setState(() => _cameraState = _CameraState.initializing);

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() => _cameraState = _CameraState.ready);
    } on CameraException catch (e) {
      _setError('${e.code}: ${e.description ?? "Unknown error"}');
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setError(String message, {bool isUnsupported = false}) {
    if (!mounted) return;
    setState(() {
      _cameraState = isUnsupported
          ? _CameraState.unsupported
          : _CameraState.error;
      _errorMessage = message;
    });
  }

  Future<void> _retry() => _bootstrap();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initController(controller.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  void _bypassCamera() {
    setState(() => _cameraState = _CameraState.ready);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCharcoal,
      body: switch (_cameraState) {
        _CameraState.initializing => const CameraLoadingView(),
        _CameraState.error => CameraErrorView(
          message: _errorMessage ?? 'An unknown error occurred.',
          onRetry: _retry,
          onBypass: _bypassCamera,
        ),
        _CameraState.unsupported => CameraUnsupportedView(
          message: _errorMessage ?? 'Camera not supported on this platform.',
          onBypass: _bypassCamera,
        ),
        _CameraState.ready => PreviewView(controller: _controller),
      },
    );
  }
}

enum _CameraState { initializing, error, unsupported, ready }

class PreviewView extends StatefulWidget {
  const PreviewView({super.key, required this.controller});

  final CameraController? controller;

  @override
  State<PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onScan({Uint8List? testBytes}) async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    try {
      final Uint8List bytes;
      if (testBytes != null) {
        bytes = testBytes;
      } else {
        if (widget.controller == null) {
          throw Exception('Camera bypassed. Long-press to test scan.');
        }
        final xFile = await widget.controller!.takePicture();
        bytes = await xFile.readAsBytes();
      }

      final result = await GeminiService.analyze(bytes);

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        builder: (_) => FloatingRecipeCard(result: result),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: kCharcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _onTestScan() async {
    const url =
        'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=400&q=80';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await _onScan(testBytes: response.bodyBytes);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test Scan Failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kCharcoal,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.controller != null)
            CameraPreview(widget.controller!)
          else
            const Center(
              child: Icon(
                Icons.videocam_off_rounded,
                size: 64,
                color: Colors.white24,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kCharcoal.withValues(alpha: 0.65),
                  Colors.transparent,
                  Colors.transparent,
                  kCharcoal.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.22, 0.62, 1.0],
              ),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: TopBar()),
          Center(
            child: ViewfinderFrame(
              size: Size(size.width * 0.72, size.width * 0.72),
              isScanning: _isScanning,
            ),
          ),
          Positioned(
            top: size.height * 0.5 + size.width * 0.36 + 20,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isScanning ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: const Text(
                'Point at any ingredient',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: safeBottom + 32,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _isScanning
                      ? const AlwaysStoppedAnimation(1.0)
                      : _pulseAnim,
                  child: ScanButton(
                    isScanning: _isScanning,
                    onPressed: _onScan,
                    onLongPress: _onTestScan,
                  ),
                ),
                const SizedBox(height: 16),
                StatusChip(
                  lensDirection:
                      widget.controller?.description.lensDirection ??
                      CameraLensDirection.back,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
