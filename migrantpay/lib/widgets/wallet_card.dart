import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class WalletCard extends StatelessWidget {
  final double balance;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final String kycStatus;

  const WalletCard({
    super.key,
    required this.balance,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.kycStatus,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,###.##', 'en_IN');

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF4F46E5),
            Color(0xFF0EA5E9),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'My MigrantPay Wallet',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // KYC badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kycStatus == 'verified'
                            ? AppTheme.secondary.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            kycStatus == 'verified'
                                ? Icons.verified
                                : Icons.pending_outlined,
                            size: 12,
                            color: kycStatus == 'verified'
                                ? AppTheme.secondary
                                : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            kycStatus == 'verified'
                                ? 'Verified'
                                : 'KYC Pending',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: kycStatus == 'verified'
                                  ? AppTheme.secondary
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '₹',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isVisible
                                  ? formatter.format(balance)
                                  : '••••••',
                              style: GoogleFonts.inter(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onToggleVisibility,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.security, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'End-to-end encrypted • RBI Compliant',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
