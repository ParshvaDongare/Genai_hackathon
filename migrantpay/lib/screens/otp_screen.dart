import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'pin_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String name;
  final String? demoOtp; // auto-filled in demo mode

  const OtpScreen({
    super.key,
    required this.phone,
    required this.name,
    this.demoOtp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  bool _isVerifying = false;
  int _resendSeconds = 30;
  bool _canResend = false;
  final _pinController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // In demo mode, auto-fill the OTP
    if (widget.demoOtp != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _pinController.text = widget.demoOtp!;
          setState(() => _otp = widget.demoOtp!);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _resendSeconds = 30;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _verifyOtp() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter 6-digit OTP', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isVerifying = true);

    try {
      final result = await ApiService.verifyOtp(widget.phone, _otp);
      if (!mounted) return;

      setState(() => _isVerifying = false);
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => PinSetupScreen(
            phone: widget.phone,
            name: widget.name,
            token: result['token'],
            kycStatus: (result['user'] as Map<String, dynamic>?)?['kycStatus'] as String?,
          ),
          transitionsBuilder: (_, anim, __, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      final msg = e is ApiException ? e.message : 'Verification failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _resendOtp() async {
    setState(() {
      _canResend = false;
      _resendSeconds = 30;
    });
    _startResendTimer();

    try {
      final result = await ApiService.sendOtp(widget.phone, name: widget.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['demoMode'] == true
                  ? 'Demo OTP: ${result['demoOtp']}'
                  : 'OTP resent to +91${widget.phone}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Auto-fill if demo mode
        if (result['demoOtp'] != null) {
          _pinController.text = result['demoOtp'];
          setState(() => _otp = result['demoOtp']);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDemoMode = widget.demoOtp != null;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: AppTheme.textPrimary, size: 18),
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 40),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.sms_outlined, color: Colors.white, size: 36),
              ).animate(delay: 100.ms).scale(
                  begin: const Offset(0, 0),
                  duration: 400.ms,
                  curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                appProvider.t('verify_otp'),
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
                  children: [
                    TextSpan(text: '${appProvider.t('otp_sent_to')} '),
                    TextSpan(
                      text: '+91 ${widget.phone}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 10),
              // Demo or live badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDemoMode
                      ? AppTheme.accent.withOpacity(0.1)
                      : AppTheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDemoMode
                        ? AppTheme.accent.withOpacity(0.3)
                        : AppTheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDemoMode ? Icons.info_outline : Icons.sms,
                      size: 14,
                      color: isDemoMode ? AppTheme.accent : AppTheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isDemoMode
                          ? 'Demo OTP: ${widget.demoOtp} (auto-filled)'
                          : 'OTP sent via SMS to +91${widget.phone}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDemoMode ? AppTheme.accent : AppTheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 350.ms).fadeIn(),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _pinController,
                onChanged: (value) => setState(() => _otp = value),
                onCompleted: (value) {
                  setState(() => _otp = value);
                  _verifyOtp();
                },
                keyboardType: TextInputType.number,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(14),
                  fieldHeight: 60,
                  fieldWidth: 48,
                  activeFillColor: AppTheme.bgElevated,
                  inactiveFillColor: AppTheme.bgCard,
                  selectedFillColor: AppTheme.bgElevated,
                  activeColor: AppTheme.primary,
                  inactiveColor: const Color(0xFFE2E8F0),
                  selectedColor: AppTheme.primary,
                ),
                enableActiveFill: true,
                textStyle: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive OTP? ",
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _resendOtp : null,
                    child: Text(
                      _canResend
                          ? 'Resend OTP'
                          : 'Resend in ${_resendSeconds}s',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _canResend ? AppTheme.primaryLight : AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 500.ms).fadeIn(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isVerifying
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5)
                          : Text(
                              appProvider.t('verify'),
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
