import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'kyc_screen.dart';
import 'language_select_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final p = context.read<AppProvider>();
                      p.setLanguage(
                          p.isHindi ? Language.english : Language.hindi);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language,
                              size: 16, color: AppTheme.primaryLight),
                          const SizedBox(width: 6),
                          Text(
                            appProvider.isHindi ? 'English' : 'हिंदी',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 24),
              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        appProvider.userName.isNotEmpty
                            ? appProvider.userName[0].toUpperCase()
                            : 'R',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appProvider.userName.isNotEmpty
                                ? appProvider.userName
                                : 'Ramesh Kumar',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '+91 ${appProvider.phoneNumber.isNotEmpty ? appProvider.phoneNumber : '9876543210'}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  appProvider.kycStatus == 'verified'
                                      ? Icons.verified
                                      : Icons.pending_outlined,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appProvider.kycStatus == 'verified'
                                      ? 'KYC Verified'
                                      : 'KYC Pending',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 28),
              // Stats row
              Row(
                children: [
                  _buildStatCard('12', 'Transactions', AppTheme.primary),
                  const SizedBox(width: 12),
                  _buildStatCard('₹8.2K', 'Sent', AppTheme.error),
                  const SizedBox(width: 12),
                  _buildStatCard('₹7K', 'Saved in Fees', AppTheme.secondary),
                ],
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 28),
              // Settings items
              Text(
                'Account Settings',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 12),
              _buildSettingsItem(
                context,
                icon: Icons.verified_user_outlined,
                title: 'KYC Verification',
                subtitle: appProvider.kycStatus == 'verified'
                    ? 'Verified ✓'
                    : 'Complete verification',
                color: AppTheme.secondary,
                delay: 350,
                onTap: () {
                  if (appProvider.kycStatus != 'verified') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const KycScreen()),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: appProvider.isHindi ? 'हिंदी' : 'English',
                color: AppTheme.primary,
                delay: 400,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const LanguageSelectScreen()),
                  );
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'SMS, Push, WhatsApp',
                color: AppTheme.accent,
                delay: 450,
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: Icons.security_outlined,
                title: 'Security & PIN',
                subtitle: 'Change PIN, biometrics',
                color: AppTheme.info,
                delay: 500,
                onTap: () {},
              ),
              _buildSettingsItem(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: '24/7 customer support',
                color: AppTheme.textMuted,
                delay: 550,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              // Logout
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.bgCard,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: Text('Logout',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      content: Text(
                          'Are you sure you want to logout?',
                          style: GoogleFonts.inter(
                              color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textMuted)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AppProvider>().logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const LanguageSelectScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Logout',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.error.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: AppTheme.error, size: 22),
                      const SizedBox(width: 14),
                      Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint, size: 20),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: 0.05);
  }
}
