import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {
  String _filter = 'all'; // all, sent, received, failed

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'All'},
    {'id': 'sent', 'label': 'Sent'},
    {'id': 'received', 'label': 'Received'},
    {'id': 'failed', 'label': 'Failed'},
  ];

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final txns = walletProvider.transactions.where((txn) {
      switch (_filter) {
        case 'sent':
          return txn.type == TransactionType.sent;
        case 'received':
          return txn.type == TransactionType.received ||
              txn.type == TransactionType.addedMoney;
        case 'failed':
          return txn.status == 'failed';
        default:
          return true;
      }
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Transaction History',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${txns.length} records',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _filter == f['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppTheme.primaryGradient
                            : null,
                        color: isSelected ? null : AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Text(
                        f['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 16),
            // Transactions
            Expanded(
              child: txns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: AppTheme.textHint),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: GoogleFonts.inter(
                              color: AppTheme.textMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: txns.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (ctx, index) {
                        return TransactionTile(
                          transaction: txns[index],
                        )
                            .animate(
                                delay: Duration(
                                    milliseconds: 200 + index * 60))
                            .fadeIn()
                            .slideX(begin: 0.05);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
