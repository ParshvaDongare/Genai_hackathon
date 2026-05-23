import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../theme/app_theme.dart';
import 'send_money_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final bool returnResult;

  const QrScannerScreen({
    super.key,
    this.returnResult = false,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _overlayController;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isHandlingResult = false;
  bool _torchEnabled = false;
  String? _errorMessage;

  final List<Map<String, String>> _demoQrs = const [
    {'name': 'Sita Devi', 'phone': '9123456789', 'upi': 'sita@ybl'},
    {'name': 'Mohan Kumar', 'phone': '9988776655', 'upi': 'mohan@paytm'},
    {'name': 'Sunita Sharma', 'phone': '9876123456', 'upi': 'sunita@gpay'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionTimeoutMs: 750,
      returnImage: false,
      autoZoom: true,
    );
    _barcodeSubscription =
        _scannerController.barcodes.listen(_handleBarcodeCapture);
    _startScanner();
  }

  Future<void> _startScanner() async {
    try {
      setState(() => _errorMessage = null);
      await _scannerController.start();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Camera access failed. Allow camera permission and try again.';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || _isHandlingResult) return;

    if (state == AppLifecycleState.resumed) {
      _startScanner();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _scannerController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _barcodeSubscription?.cancel();
    _scannerController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeCapture(BarcodeCapture capture) async {
    if (_isHandlingResult || capture.barcodes.isEmpty) return;

    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    final contact = _parseQrPayload(rawValue.trim());
    await _onScanSuccess(contact);
  }

  Map<String, String> _parseQrPayload(String rawValue) {
    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map<String, dynamic>) {
        return {
          if ((decoded['name'] ?? '').toString().isNotEmpty)
            'name': decoded['name'].toString(),
          if ((decoded['phone'] ?? '').toString().isNotEmpty)
            'phone': decoded['phone'].toString(),
          if ((decoded['upi'] ?? '').toString().isNotEmpty)
            'upi': decoded['upi'].toString(),
        };
      }
    } catch (_) {
      // Not JSON; continue with URI/plain-text parsing.
    }

    final uri = Uri.tryParse(rawValue);
    if (uri != null && uri.scheme == 'upi') {
      return {
        if ((uri.queryParameters['pn'] ?? '').isNotEmpty)
          'name': uri.queryParameters['pn']!,
        if ((uri.queryParameters['pa'] ?? '').isNotEmpty)
          'upi': uri.queryParameters['pa']!,
      };
    }

    if (RegExp(r'^\d{10}$').hasMatch(rawValue)) {
      return {'phone': rawValue};
    }

    return {'upi': rawValue};
  }

  Future<void> _onScanSuccess(Map<String, String> contact) async {
    if (_isHandlingResult) return;

    _isHandlingResult = true;
    await _scannerController.stop();

    if (!mounted) return;

    final displayValue =
        contact['name'] ?? contact['phone'] ?? contact['upi'] ?? 'QR data';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.qr_code_2, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'QR scanned: $displayValue',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (widget.returnResult) {
      Navigator.of(context).pop(contact);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SendMoneyScreen(
          preFilledPhoneOrUpi: contact['phone'] ?? contact['upi'],
          preFilledName: contact['name'],
        ),
      ),
    );
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    if (!mounted) return;
    setState(() => _torchEnabled = !_torchEnabled);
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final capture = await _scannerController.analyzeImage(pickedFile.path);
    if (capture == null || capture.barcodes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No QR code found in the selected image.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _handleBarcodeCapture(capture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(
              _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.28)),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'Align the QR code inside the frame',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Camera scan is now live',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
                  const Spacer(),
                  _buildScannerFrame(),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFromGallery,
                            icon: const Icon(Icons.image_outlined, size: 18),
                            label: Text(
                              'Scan from Gallery',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.white10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 18),
                  _buildDemoTargetsSheet(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerFrame() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 2),
            ),
          ),
          AnimatedBuilder(
            animation: _overlayController,
            builder: (context, child) {
              return Positioned(
                top: _overlayController.value * 220 + 18,
                left: 18,
                right: 18,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.9),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(top: 0, left: 0, child: _buildCorner(top: true, left: true)),
          Positioned(top: 0, right: 0, child: _buildCorner(top: true, left: false)),
          Positioned(bottom: 0, left: 0, child: _buildCorner(top: false, left: true)),
          Positioned(bottom: 0, right: 0, child: _buildCorner(top: false, left: false)),
        ],
      ),
    );
  }

  Widget _buildDemoTargetsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: const BoxDecoration(
        color: Color(0xFF10233A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Demo QR Targets',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use these if you want to test the payment flow without a real QR.',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ..._demoQrs.map((contact) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _onScanSuccess(contact),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white12,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          color: AppTheme.secondaryLight,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact['name']!,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              contact['phone'] ?? contact['upi']!,
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white24,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    const double length = 24;
    const double thickness = 4;
    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(
              width: length,
              height: thickness,
              color: AppTheme.secondary,
            ),
          ),
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: left ? 0 : null,
            right: left ? null : 0,
            child: Container(
              width: thickness,
              height: length,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
