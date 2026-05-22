import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';
import '../screens/transaction_detail_screen.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isSent = transaction.type == TransactionType.sent;
    final isAdded = transaction.type == TransactionType.addedMoney;
    final isFailed = transaction.status == 'failed';

    Color iconBg;
    Color iconColor;
    IconData icon;
    Color amountColor;
    String amountPrefix;

    if (isFailed) {
      iconBg = AppTheme.error.withOpacity(0.15);
      iconColor = AppTheme.error;
      icon = Icons.error_outline_rounded;
      amountColor = AppTheme.error;
      amountPrefix = '-₹';
    } else if (isSent) {
      iconBg = AppTheme.primary.withOpacity(0.15);
      iconColor = AppTheme.primaryLight;
      icon = Icons.arrow_upward_rounded;
      amountColor = AppTheme.error;
      amountPrefix = '-₹';
    } else if (isAdded) {
      iconBg = AppTheme.secondary.withOpacity(0.15);
      iconColor = AppTheme.secondary;
      icon = Icons.arrow_downward_rounded;
      amountColor = AppTheme.secondary;
      amountPrefix = '+₹';
    } else {
      iconBg = AppTheme.secondary.withOpacity(0.15);
      iconColor = AppTheme.secondary;
      icon = Icons.arrow_downward_rounded;
      amountColor = AppTheme.secondary;
      amountPrefix = '+₹';
    }

    final formatter = NumberFormat('#,##,###', 'en_IN');
    final timeFormatter = DateFormat('hh:mm a', 'en_IN');
    final dateFormatter = DateFormat('dd MMM', 'en_IN');
    final now = DateTime.now();
    final isToday = transaction.timestamp.day == now.day &&
        transaction.timestamp.month == now.month;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(txn: transaction),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        isToday
                            ? 'Today, ${timeFormatter.format(transaction.timestamp)}'
                            : '${dateFormatter.format(transaction.timestamp)}, ${timeFormatter.format(transaction.timestamp)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFailed
                              ? AppTheme.error.withOpacity(0.1)
                              : AppTheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isFailed ? 'Failed' : 'Success',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isFailed
                                ? AppTheme.error
                                : AppTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix${formatter.format(transaction.amount)}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isFailed ? AppTheme.textMuted : amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fee: ₹0',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
