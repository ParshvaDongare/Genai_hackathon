import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  bool _showGoalCreator = false;

  final List<Map<String, dynamic>> _aiTips = [
    {
      'icon': '💡',
      'title': 'Save ₹100 weekly',
      'body':
          'Set aside ₹100 every week in your Emergency Fund goal. In 1 year, you\'ll have ₹5,200!',
      'color': AppTheme.primary,
    },
    {
      'icon': '📊',
      'title': 'Your spending this month',
      'body':
          'You sent ₹4,200 in remittances this month — ₹800 less than last month. Great job!',
      'color': AppTheme.secondary,
    },
    {
      'icon': '🎯',
      'title': 'You\'re 35% to your goal!',
      'body':
          'Your Emergency Fund is ₹3,500 of ₹10,000. Keep going — just ₹6,500 more to go!',
      'color': AppTheme.accent,
    },
    {
      'icon': '🏦',
      'title': 'Safe Investment Opportunity',
      'body':
          'Government-backed Sukanya Samriddi Yojana gives 8.2% returns with zero risk. Consider it for family!',
      'color': AppTheme.info,
    },
  ];

  final List<Map<String, dynamic>> _investments = [
    {
      'name': 'Emergency Fund',
      'type': 'Liquid Fund',
      'return': '7.2% p.a.',
      'risk': 'Low',
      'minAmount': '₹10',
      'color': AppTheme.secondary,
    },
    {
      'name': 'Pradhan Mantri Jan Dhan',
      'type': 'Government Scheme',
      'return': '4% p.a.',
      'risk': 'Zero',
      'minAmount': '₹1',
      'color': AppTheme.accent,
    },
    {
      'name': 'Fixed Deposit',
      'type': 'Bank FD',
      'return': '8.5% p.a.',
      'risk': 'Low',
      'minAmount': '₹100',
      'color': AppTheme.info,
    },
    {
      'name': 'Balanced Mutual Fund',
      'type': 'Mutual Fund',
      'return': '12-15% p.a.',
      'risk': 'Medium',
      'minAmount': '₹500',
      'color': AppTheme.primary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Financial Insights',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Personalized for you',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 22),
                  ),
                ],
              ).animate().fadeIn(),
            ),
          ),
          // AI Tips carousel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'This Week\'s Tips 💡',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _aiTips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) {
                      final tip = _aiTips[i];
                      return Container(
                        width: 240,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (tip['color'] as Color).withOpacity(0.25),
                              (tip['color'] as Color).withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (tip['color'] as Color).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tip['icon'] as String,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text(
                              tip['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip['body'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ).animate(
                          delay: Duration(milliseconds: 100 + i * 100)).fadeIn().slideX(begin: 0.1);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Savings Goals
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Savings Goals 🎯',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showGoalCreator = !_showGoalCreator),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'New Goal',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final goal = walletProvider.goals[i];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(goal.emoji,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '₹${goal.savedAmount.toInt()} of ₹${goal.targetAmount.toInt()}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(goal.progress * 100).toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearPercentIndicator(
                          percent: goal.progress.clamp(0, 1).toDouble(),
                          lineHeight: 8,
                          barRadius: const Radius.circular(8),
                          backgroundColor:
                              Colors.white.withOpacity(0.08),
                          linearGradient: LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.secondary,
                            ],
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                walletProvider.addToGoal(goal.id, 100);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('₹100 added to ${goal.name}!',
                                        style: GoogleFonts.inter()),
                                    backgroundColor: AppTheme.secondary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.greenGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Add ₹100',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: Duration(milliseconds: 300 + i * 100))
                      .fadeIn()
                      .slideY(begin: 0.1),
                );
              },
              childCount: walletProvider.goals.length,
            ),
          ),
          // Investment recommendations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Micro-Investments 📈',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SEBI Regulated',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final inv = _investments[i];
                final riskColor = inv['risk'] == 'Zero' || inv['risk'] == 'Low'
                    ? AppTheme.secondary
                    : inv['risk'] == 'Medium'
                        ? AppTheme.accent
                        : AppTheme.error;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                                (inv['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              inv['return'].toString().split('%')[0],
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: inv['color'] as Color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inv['name'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                inv['type'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: riskColor.withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${inv['risk']} Risk',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: riskColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Min ${inv['minAmount']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppTheme.textMuted,
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
                              inv['return'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Investment module coming soon!',
                                        style: GoogleFonts.inter()),
                                    backgroundColor: AppTheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Invest',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(
                      delay: Duration(milliseconds: 400 + i * 80)).fadeIn().slideX(begin: 0.1),
                );
              },
              childCount: _investments.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
