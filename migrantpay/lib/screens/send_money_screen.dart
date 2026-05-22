import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';
import 'transaction_detail_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  int _step = 0; // 0: enter details, 1: confirm, 2: pin entry
  final List<int> _pin = [];

  final List<Map<String, String>> _frequentContacts = [
    {'name': 'Sita Devi (Maa)', 'phone': '9123456789', 'upi': 'sita@ybl'},
    {'name': 'Mohan Kumar', 'phone': '9988776655', 'upi': 'mohan@paytm'},
    {'name': 'Sunita (Sister)', 'phone': '9876123456', 'upi': 'sunita@gpay'},
  ];

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _proceed() {
    if (_receiverController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please fill all fields', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a valid amount', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _step = 1);
  }

  void _onPinKey(int digit) {
    if (_pin.length < 6) {
      setState(() => _pin.add(digit));
      if (_pin.length == 6) {
        _sendMoney();
      }
    }
  }

  void _onPinDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin.removeLast());
    }
  }

  void _sendMoney() async {
    setState(() => _isLoading = true);
    final amount = double.parse(_amountController.text);
    final walletProvider = context.read<WalletProvider>();
    final txn = await walletProvider.sendMoney(
      receiverName:
          _nameController.text.isNotEmpty ? _nameController.text : 'Family',
      receiverPhone: _receiverController.text,
      amount: amount,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (txn != null) {
        // Show success notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '₹${amount.toInt()} sent successfully! 🎉',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(txn: txn, isSuccess: true),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 1) return _buildConfirmScreen();
    if (_step == 2) return _buildPinScreen();
    return _buildDetailsScreen();
  }

  Widget _buildDetailsScreen() {
    final walletProvider = context.watch<WalletProvider>();
    final formatter = NumberFormat('#,##,###', 'en_IN');

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
        title: Text('Send Money',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: AppTheme.secondary),
                const SizedBox(width: 4),
                Text(
                  '₹${formatter.format(walletProvider.balance)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zero fee banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Zero Platform Fee — You pay what you send!',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 24),
              // Frequent contacts
              Text(
                'Frequent Contacts',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 12),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _frequentContacts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    final contact = _frequentContacts[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _receiverController.text = contact['phone']!;
                          _nameController.text = contact['name']!;
                        });
                      },
                      child: Container(
                        width: 76,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.2),
                              child: Text(
                                contact['name']![0],
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryLight,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              contact['name']!.split(' ')[0],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 24),
              // Fields
              Text(
                'Receiver Details',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.inter(
                    fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Receiver's name (optional)",
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppTheme.textMuted),
                ),
              ).animate(delay: 350.ms).fadeIn().slideX(begin: -0.05),
              const SizedBox(height: 12),
              TextFormField(
                controller: _receiverController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Mobile number, UPI ID, or bank account',
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppTheme.textMuted),
                ),
              ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.05),
              const SizedBox(height: 20),
              Text(
                'Amount',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ).animate(delay: 450.ms).fadeIn(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 4),
                    child: Text(
                      '₹',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                ),
              ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.05),
              const SizedBox(height: 10),
              // Quick amount chips
              Wrap(
                spacing: 8,
                children: [500, 1000, 2000, 5000].map((amt) {
                  return GestureDetector(
                    onTap: () => setState(
                        () => _amountController.text = '$amt'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        '₹$amt',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate(delay: 550.ms).fadeIn(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _proceed,
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
                            'Review Transfer',
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
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmScreen() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final formatter = NumberFormat('#,##,###', 'en_IN');

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => setState(() => _step = 0),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
        title: Text('Confirm Transfer',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                children: [
                  // Amount
                  Text(
                    '₹${formatter.format(amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ).animate().scale(
                      begin: const Offset(0.8, 0.8), duration: 400.ms),
                  const SizedBox(height: 8),
                  // Receiver
                  Text(
                    'To: ${_nameController.text.isNotEmpty ? _nameController.text : _receiverController.text}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(delay: 100.ms).fadeIn(),
                  Text(
                    _receiverController.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                    ),
                  ).animate(delay: 150.ms).fadeIn(),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF2A2A4A)),
                  const SizedBox(height: 16),
                  // Fee breakdown
                  _buildFeeRow('Transfer Amount', '₹${formatter.format(amount)}'),
                  const SizedBox(height: 8),
                  _buildFeeRow('Platform Fee', '₹0', isGreen: true),
                  const SizedBox(height: 8),
                  _buildFeeRow('Network Charges', '₹0', isGreen: true),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2A2A4A)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${formatter.format(amount)}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 20),
            // Blockchain notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: AppTheme.primaryLight, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This transaction will be recorded on blockchain for immutable audit trail',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = 2),
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
                        const Icon(Icons.lock_outline,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Enter PIN to Send',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 14, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isGreen ? AppTheme.secondary : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPinScreen() {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => setState(() {
            _step = 1;
            _pin.clear();
          }),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
        title: Text('Confirm with PIN',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_rounded,
                  color: Colors.white, size: 36),
            ).animate().scale(
                begin: const Offset(0, 0),
                duration: 400.ms,
                curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'Enter your 6-digit PIN',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ).animate(delay: 100.ms).fadeIn(),
            Text(
              'Authorize the money transfer',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.textMuted),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 36),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? AppTheme.primary
                        : Colors.white.withOpacity(0.12),
                    boxShadow: index < _pin.length
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(),
            const Spacer(),
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Processing transaction...',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              )
            else
              _buildPinKeypad(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPinKeypad() {
    const keys = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [null, 0, -1],
    ];
    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key == null) return const SizedBox(width: 80, height: 70);
              if (key == -1) {
                return GestureDetector(
                  onTap: _onPinDelete,
                  child: Container(
                    width: 80,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.06)),
                    ),
                    child: const Icon(Icons.backspace_outlined,
                        color: AppTheme.textSecondary),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => _onPinKey(key),
                child: Container(
                  width: 80,
                  height: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Center(
                    child: Text(
                      '$key',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
