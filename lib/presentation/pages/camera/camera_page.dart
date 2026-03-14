import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../config/injection.dart';
import '../../../services/ml_kit_service.dart';
import '../../../services/camera_service.dart';
import '../../routes/app_router.dart';

@RoutePage()
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  final MLKitService _mlKitService = sl<MLKitService>();
  final CameraService _cameraService = sl<CameraService>();

  bool _isProcessing = false;
  String? _processedImagePath;
  String? _extractedText;
  String? _merchantName;
  double? _totalAmount;
  double? _originalAmount;
  String _detectedCurrency = 'THB';
  String _statusMessage = '';

  late AnimationController _scanAnimController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_scanAnimController);
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนใบเสร็จ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image preview with scan overlay ──
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: double.infinity,
                    height: 280,
                    color: _processedImagePath != null
                        ? Colors.black
                        : cs.surfaceVariant,
                    child: _processedImagePath != null
                        ? Image.file(
                            File(_processedImagePath!),
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _scanAnimation,
                                builder: (_, child) => Transform.scale(
                                  scale:
                                      1.0 + _scanAnimation.value * 0.12,
                                  child: child,
                                ),
                                child: Icon(Icons.document_scanner,
                                    size: 72,
                                    color: cs.primary.withOpacity(0.35)),
                              ),
                              const SizedBox(height: 12),
                              Text('ถ่ายรูปหรือเลือกใบเสร็จ',
                                  style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13)),
                            ],
                          ),
                  ),
                  // Scan-line while processing
                  if (_isProcessing)
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (_, __) => Positioned(
                        top: _scanAnimation.value * 270,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.transparent,
                              cs.primary,
                              cs.primary,
                              Colors.transparent,
                            ]),
                          ),
                        ),
                      ),
                    ),
                  // Processing overlay
                  if (_isProcessing)
                    Container(
                      color: Colors.black38,
                      height: 280,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: cs.primary),
                            const SizedBox(height: 12),
                            Text(
                              _statusMessage,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Action buttons ──
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isProcessing ? null : _captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('ถ่ายรูป'),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('แกลเลอรี'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Result card (animated) ──
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: _extractedText != null
                  ? _ResultCard(
                      merchantName: _merchantName,
                      totalAmount: _totalAmount,
                      originalAmount: _originalAmount,
                      detectedCurrency: _detectedCurrency,
                      colorScheme: cs,
                    )
                  : const SizedBox.shrink(),
            ),

            if (_extractedText != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _navigateToForm,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('ถัดไป — กรอกข้อมูล'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
              ),
            ],

            const SizedBox(height: 8),
            TextButton.icon(
              onPressed:
                  _isProcessing ? null : () => context.router.push(ExpenseFormRoute()),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('กรอกข้อมูลเองโดยไม่สแกน'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'กำลังถ่ายรูป...';
    });
    try {
      final path = await _cameraService.captureImage();
      if (path != null && mounted) await _processImage(path);
    } catch (e) {
      _showError('ไม่สามารถถ่ายรูปได้: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'กำลังเลือกรูป...';
    });
    try {
      final path = await _cameraService.pickImageFromGallery();
      if (path != null && mounted) await _processImage(path);
    } catch (e) {
      _showError('ไม่สามารถเลือกรูปได้: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() => _statusMessage = 'กำลังวิเคราะห์ใบเสร็จ...');
    final imageFile = File(imagePath);
    final text = await _mlKitService.extractTextFromImage(imageFile);
    final data = await _mlKitService.parseReceiptData(text);
    if (mounted) {
      setState(() {
        _processedImagePath = imagePath;
        _extractedText = text;
        _merchantName = data['merchantName'] as String?;
        _totalAmount = data['totalAmount'] as double?;
        _originalAmount = data['originalAmount'] as double?;
        _detectedCurrency = data['detectedCurrency'] as String? ?? 'THB';
        _statusMessage = '';
      });
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _navigateToForm() {
    context.router.push(ExpenseFormRoute(
      receiptImagePath: _processedImagePath,
      merchantName: _merchantName,
      amount: _totalAmount,
      extractedText: _extractedText,
    ));
  }
}

// ─────────────────────────────────────────────
// Animated Result Card
// ─────────────────────────────────────────────
class _ResultCard extends StatefulWidget {
  final String? merchantName;
  final double? totalAmount;
  final double? originalAmount;
  final String detectedCurrency;
  final ColorScheme colorScheme;

  const _ResultCard({
    required this.merchantName,
    required this.totalAmount,
    required this.originalAmount,
    required this.detectedCurrency,
    required this.colorScheme,
  });

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.check_circle_rounded,
                    color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ตรวจพบข้อมูลจากใบเสร็จ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ]),
              if (widget.merchantName != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.store_outlined,
                      size: 14, color: cs.onPrimaryContainer.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    widget.merchantName!,
                    style: TextStyle(color: cs.onPrimaryContainer),
                  ),
                ]),
              ],
              if (widget.totalAmount != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.payments_outlined,
                      size: 14, color: cs.onPrimaryContainer.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  // Show original + converted if not THB
                  if (widget.detectedCurrency != 'THB' && widget.originalAmount != null)
                    Text(
                      '${widget.detectedCurrency} ${widget.originalAmount!.toStringAsFixed(2)}  →  ฿${widget.totalAmount!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: cs.onPrimaryContainer,
                      ),
                    )
                  else
                    Text(
                      '฿${widget.totalAmount!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
