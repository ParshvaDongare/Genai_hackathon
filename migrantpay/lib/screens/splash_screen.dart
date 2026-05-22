import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'language_select_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _startLoading();
  }

  void _startLoading() async {
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() => _progress = i / 100);
      }
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LanguageSelectScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1B), Color(0xFF1A0A35), Color(0xFF0A0A1B)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background glow circles
            Positioned(
              top: -100,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.1),
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.currency_rupee_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 28),
                  // App name
                  Text(
                    'MigrantPay',
                    style: GoogleFonts.inter(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 8),
                  // Tagline
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.walletGradient.createShader(bounds),
                    child: Text(
                      'Zero Fees. Real Freedom.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 80),
                  // Loading bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Securing your connection...',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
            // Bottom badge
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user,
                          size: 14, color: AppTheme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'RBI Compliant • PCI-DSS Secured • AES-256 Encrypted',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'v1.0.0 • Hackathon MVP',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}
