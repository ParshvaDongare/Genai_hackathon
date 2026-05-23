import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class PinLoginScreen extends StatefulWidget {
  final String phone;
  final String name;

  const PinLoginScreen({
    super.key,
    required this.phone,
    required this.name,
  });

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final List<int> _pin = [];
  bool _isLoading = false;

  void _onKeyPress(int digit) {
    if (_pin.length >= 6 || _isLoading) return;

    setState(() => _pin.add(digit));
    if (_pin.length == 6) {
      _login();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty || _isLoading) return;
    setState(() => _pin.removeLast());
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.loginWithPin(
        phone: widget.phone,
        name: widget.name,
        pin: _pin.join(),
      );
      if (!mounted) return;

      final user = result['user'] as Map<String, dynamic>? ?? {};
      context.read<AppProvider>().setSession(
            token: result['token'] as String,
            phone: widget.phone,
            name: user['name'] as String? ?? widget.name,
            kycStatus: user['kycStatus'] as String? ?? 'pending',
          );

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _pin.clear();
      });

      final msg = e is ApiException ? e.message : 'PIN login failed';
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
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Row(
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
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_person_outlined,
                    color: Colors.white, size: 40),
              ).animate(delay: 100.ms).scale(
                  begin: const Offset(0, 0),
                  duration: 400.ms,
                  curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 8),
              Text(
                '${widget.name}\n+91 ${widget.phone}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length
                          ? AppTheme.primary
                          : AppTheme.bgElevated,
                    ),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 10),
              Text(
                'Enter your 6-digit PIN',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ).animate(delay: 450.ms).fadeIn(),
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator(color: AppTheme.primary)
              else
                _buildKeypad(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const keys = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [null, 0, -1],
    ];

    return Column(
      children: keys
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  if (key == null) {
                    return const SizedBox(width: 80, height: 70);
                  }
                  if (key == -1) {
                    return GestureDetector(
                      onTap: _onDelete,
                      child: Container(
                        width: 80,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.backspace_outlined,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () => _onKeyPress(key),
                    child: Container(
                      width: 80,
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: Text(
                          '$key',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
          .toList(),
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2);
  }
}
