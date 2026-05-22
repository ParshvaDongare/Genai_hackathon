import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/wallet_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/bottom_nav.dart';
import 'send_money_screen.dart';
import 'add_money_screen.dart';
import 'transaction_history_screen.dart';
import 'ai_insights_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final walletProvider = context.watch<WalletProvider>();

    final tabs = [
      _buildHomeTab(context, appProvider, walletProvider),
      const AiInsightsScreen(),
      const TransactionHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(
        index: _selectedIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    AppProvider appProvider,
    WalletProvider walletProvider,
  ) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning 👋',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
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
                    ],
                  ),
                  const Spacer(),
                  // Notification icon
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 22),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Language toggle
                  GestureDetector(
                    onTap: () {
                      final p = context.read<AppProvider>();
                      p.setLanguage(p.isHindi ? Language.english : Language.hindi);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        appProvider.isHindi ? 'EN' : 'हि',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),
          // Wallet card
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: WalletCard(
                balance: walletProvider.balance,
                isVisible: _balanceVisible,
                onToggleVisibility: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                kycStatus: appProvider.kycStatus,
              ),
            ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
          ),
          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                appProvider.t('quick_actions'),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionButton(
                    icon: Icons.send_rounded,
                    label: appProvider.t('send_money'),
                    gradient: AppTheme.primaryGradient,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SendMoneyScreen()),
                    ),
                  ),
                  QuickActionButton(
                    icon: Icons.add_rounded,
                    label: appProvider.t('add_money'),
                    gradient: AppTheme.greenGradient,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AddMoneyScreen()),
                    ),
                  ),
                  QuickActionButton(
                    icon: Icons.download_rounded,
                    label: appProvider.t('withdraw'),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Withdrawal to UPI/bank coming soon!',
                              style: GoogleFonts.inter()),
                          backgroundColor: AppTheme.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  QuickActionButton(
                    icon: Icons.history_rounded,
                    label: appProvider.t('history'),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
          ),
          // Zero-fee banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.celebration_outlined,
                          color: AppTheme.secondary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹0 Transaction Fee — Always!',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.secondary,
                            ),
                          ),
                          Text(
                            'Send money home without any platform charges',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.secondary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(),
          ),
          // Recent transactions header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appProvider.t('recent_txns'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: Text(
                      appProvider.t('see_all'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 350.ms).fadeIn(),
          ),
          // Transactions list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= walletProvider.transactions.length ||
                    index >= 4) {
                  return null;
                }
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: TransactionTile(
                    transaction: walletProvider.transactions[index],
                  ).animate(delay: Duration(milliseconds: 400 + index * 80))
                      .fadeIn()
                      .slideX(begin: 0.1),
                );
              },
              childCount:
                  walletProvider.transactions.length.clamp(0, 4),
            ),
          ),
          // AI Insight teaser
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: AppTheme.primaryLight, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 AI Tip of the Day',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Save ₹100 weekly for emergency fund — reach ₹5,200 in a year!',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textMuted, size: 20),
                    ],
                  ),
                ),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1),
          ),
        ],
      ),
    );
  }
}
