import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction txn;
  final bool isSuccess;

  const TransactionDetailScreen({
    super.key,
    required this.txn,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a', 'en_IN');
    final isSent = txn.type == TransactionType.sent;
    final isFailed = txn.status == 'failed';

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
        title: Text('Transaction Details',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Receipt shared!', style: GoogleFonts.inter()),
                  backgroundColor: AppTheme.secondary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Success/status animation
              if (isSuccess)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppTheme.greenGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.5),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 50),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0, 0),
                        duration: 500.ms,
                        curve: Curves.elasticOut)
                    .fadeIn()
              else
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isFailed
                        ? AppTheme.error.withOpacity(0.15)
                        : AppTheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFailed
                        ? Icons.error_outline_rounded
                        : isSent
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                    color: isFailed
                        ? AppTheme.error
                        : isSent
                            ? AppTheme.primaryLight
                            : AppTheme.secondary,
                    size: 44,
                  ),
                ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 400.ms),
              const SizedBox(height: 16),
              if (isSuccess)
                Text(
                  'Money Sent!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 8),
              // Amount
              Text(
                '${isSent ? '-' : '+'}₹${formatter.format(txn.amount)}',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: isFailed
                      ? AppTheme.textMuted
                      : isSent
                          ? AppTheme.error
                          : AppTheme.secondary,
                  letterSpacing: -1,
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 24),
              // Transaction details card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('To / From', txn.name),
                    _buildDetailRow('Mobile / UPI', txn.phoneOrUpi),
                    _buildDetailRow('Date & Time',
                        dateFormatter.format(txn.timestamp)),
                    _buildDetailRow(
                      'Status',
                      txn.status.toUpperCase(),
                      valueColor: isFailed
                          ? AppTheme.error
                          : AppTheme.secondary,
                    ),
                    _buildDetailRow('Transaction Fee', '₹0 (Zero Fee!)',
                        valueColor: AppTheme.secondary),
                    if (txn.note.isNotEmpty)
                      _buildDetailRow('Note', txn.note),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
              const SizedBox(height: 16),
              // Transaction ID
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_outlined,
                            size: 16, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Transaction ID',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: txn.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied!',
                                    style: GoogleFonts.inter()),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.bgElevated,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy_outlined,
                              size: 16, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      txn.id,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn(),
              const SizedBox(height: 12),
              // Blockchain hash
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link,
                            size: 16, color: AppTheme.primaryLight),
                        const SizedBox(width: 6),
                        Text(
                          'Blockchain Audit Hash',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: txn.blockchainHash));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Hash copied!',
                                    style: GoogleFonts.inter()),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.bgElevated,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: const Icon(Icons.copy_outlined,
                              size: 16,
                              color: AppTheme.primaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      txn.blockchainHash,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified,
                            size: 14, color: AppTheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'Immutable record on distributed ledger',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn(),
              const SizedBox(height: 30),
              if (isSuccess || Navigator.canPop(context))
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
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
                      ),
                      child: Center(
                        child: Text(
                          'Back to Home',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
              color: const Color(0xFFE2E8F0), height: 1),
        ],
      ),
    );
  }
}
