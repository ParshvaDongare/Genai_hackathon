import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _agreed = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a valid 10-digit mobile number',
              style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept Terms & Conditions', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.sendOtp(
        _phoneController.text,
        name: _nameController.text,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      // If demo mode, result contains demoOtp to auto-fill
      final demoOtp = result['demoOtp'] as String?;
      if (demoOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔑 Demo OTP: $demoOtp (auto-filled)',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => OtpScreen(
            phone: _phoneController.text,
            name: _nameController.text,
            demoOtp: demoOtp,
          ),
          transitionsBuilder: (_, anim, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = e is ApiException ? e.message : 'Failed to send OTP. Is the server running?';
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

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline,
                              size: 14, color: AppTheme.secondary),
                          const SizedBox(width: 4),
                          Text('256-bit Secured',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 40),
                // Title
                Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'Join 50,000+ migrant workers saving with MigrantPay',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 40),
                // Name field
                Row(
                  children: [
                    Text(
                      'Full Name',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Optional',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'e.g. Ramesh Kumar (optional)',
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppTheme.textMuted),
                  ),
                ).animate(delay: 350.ms).fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 20),
                // Phone field
                Text(
                  appProvider.t('mobile_number'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2),
                  decoration: InputDecoration(
                    hintText: appProvider.t('enter_mobile'),
                    prefixIcon: const Icon(Icons.phone_android_outlined,
                        color: AppTheme.textMuted),
                    prefixText: '+91  ',
                    prefixStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate(delay: 450.ms).fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 28),
                // Terms
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: _agreed ? AppTheme.primaryGradient : null,
                          color: _agreed ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _agreed
                                ? Colors.transparent
                                : AppTheme.textMuted,
                            width: 2,
                          ),
                        ),
                        child: _agreed
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondary),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 500.ms).fadeIn(),
                const SizedBox(height: 36),
                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: _agreed
                            ? AppTheme.primaryGradient
                            : const LinearGradient(colors: [
                                Color(0xFF3A3A5C),
                                Color(0xFF3A3A5C)
                              ]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _agreed
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    appProvider.t('send_otp'),
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 20),
                // Social proof
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrustBadge(Icons.people_alt_outlined, '50K+', 'Users'),
                    const SizedBox(width: 24),
                    _buildTrustBadge(
                        Icons.currency_rupee, '2Cr+', 'Transferred'),
                    const SizedBox(width: 24),
                    _buildTrustBadge(Icons.star_rounded, '4.8', 'Rating'),
                  ],
                ).animate(delay: 700.ms).fadeIn(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}
