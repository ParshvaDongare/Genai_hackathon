import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LanguageSelectScreen extends StatelessWidget {
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F0F24), Color(0xFF0A0A1B)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.currency_rupee_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'MigrantPay',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                const SizedBox(height: 60),
                // Title
                Text(
                  'Select Language',
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  'भाषा चुनें',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 48),
                // Language options
                _LanguageCard(
                  flag: '🇬🇧',
                  name: 'English',
                  subtitle: 'Continue in English',
                  isSelected: appProvider.language == Language.english,
                  delay: 300,
                  onTap: () => appProvider.setLanguage(Language.english),
                ),
                const SizedBox(height: 16),
                _LanguageCard(
                  flag: '🇮🇳',
                  name: 'हिंदी',
                  subtitle: 'हिंदी में जारी रखें',
                  isSelected: appProvider.language == Language.hindi,
                  delay: 400,
                  onTap: () => appProvider.setLanguage(Language.hindi),
                ),
                const Spacer(),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const RegisterScreen(),
                          transitionsBuilder: (_, anim, __, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                    parent: anim, curve: Curves.easeInOut),
                              ),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              appProvider.t('get_started'),
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String name;
  final String subtitle;
  final bool isSelected;
  final int delay;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check,
                      size: 16, color: AppTheme.primary)
                  : null,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: 0.2);
  }
}
