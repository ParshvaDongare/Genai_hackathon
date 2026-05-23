import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.check_circle_rounded,
      'color': AppTheme.secondary,
      'title': 'Money Sent Successfully!',
      'body': 'You sent ₹3,000 to Sita Devi. Zero fees charged.',
      'time': '2 hours ago',
      'isUnread': true,
    },
    {
      'icon': Icons.arrow_downward_rounded,
      'color': AppTheme.primary,
      'title': 'Salary Received',
      'body': '₹5,000 received from Employer - Site Office.',
      'time': '2 hours ago',
      'isUnread': true,
    },
    {
      'icon': Icons.auto_awesome,
      'color': AppTheme.accent,
      'title': 'AI Savings Tip',
      'body': 'Save ₹100 this week for your Emergency Fund goal!',
      'time': '5 hours ago',
      'isUnread': true,
    },
    {
      'icon': Icons.verified_user,
      'color': AppTheme.secondary,
      'title': 'KYC Verified',
      'body': 'Your identity verification is complete. ₹2L/month limit unlocked!',
      'time': 'Yesterday',
      'isUnread': false,
    },
    {
      'icon': Icons.security,
      'color': AppTheme.info,
      'title': 'New Device Login',
      'body': 'MigrantPay was opened on a new device. If this wasn\'t you, contact support.',
      'time': 'Yesterday',
      'isUnread': false,
    },
    {
      'icon': Icons.error_outline_rounded,
      'color': AppTheme.error,
      'title': 'Transfer Failed - Refunded',
      'body': '₹1,200 transfer to Sunita failed. Amount refunded to wallet.',
      'time': '2 days ago',
      'isUnread': false,
    },
    {
      'icon': Icons.savings_outlined,
      'color': AppTheme.secondary,
      'title': 'Savings Reminder',
      'body': 'Don\'t forget to add to your Children\'s Education goal this week!',
      'time': '3 days ago',
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppTheme.textPrimary, size: 18),
          ),
        ),
        title: Text('Notifications',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.primaryLight),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final notif = _notifications[i];
          final isUnread = notif['isUnread'] as bool;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnread
                  ? AppTheme.primary.withOpacity(0.06)
                  : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnread
                    ? AppTheme.primary.withOpacity(0.2)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (notif['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notif['icon'] as IconData,
                    color: notif['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['body'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif['time'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(
              delay: Duration(milliseconds: 100 + i * 60)).fadeIn().slideX(begin: 0.05);
        },
      ),
    );
  }
}
