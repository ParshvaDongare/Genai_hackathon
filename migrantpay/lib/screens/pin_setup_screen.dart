import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'kyc_screen.dart';

class PinSetupScreen extends StatefulWidget {
  final String phone;
  final String name;
  final String token;

  const PinSetupScreen({
    super.key,
    required this.phone,
    required this.name,
    required this.token,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final List<int> _pin = [];
  final List<int> _confirmPin = [];
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onKeyPress(int digit) {
    setState(() {
      if (!_isConfirming) {
        if (_pin.length < 6) _pin.add(digit);
        if (_pin.length == 6) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _isConfirming = true);
          });
        }
      } else {
        if (_confirmPin.length < 6) _confirmPin.add(digit);
        if (_confirmPin.length == 6) {
          _validatePins();
        }
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) _confirmPin.removeLast();
      } else {
        if (_pin.isNotEmpty) _pin.removeLast();
      }
    });
  }

  void _validatePins() async {
    if (_pin.join() == _confirmPin.join()) {
      setState(() => _isLoading = true);
      try {
        await ApiService.setPin(widget.phone, widget.token, _pin.join());
      } catch (_) {
        // non-fatal — PIN saved locally in AppProvider even if backend fails
      }
      if (mounted) {
        context.read<AppProvider>().login(widget.phone, widget.name);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const KycScreen(),
            transitionsBuilder: (_, anim, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeInOut)),
                child: child,
              );
            },
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PINs don't match. Try again.", style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() {
        _confirmPin.clear();
        _pin.clear();
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 40),
              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_outline, color: Colors.white, size: 40),
              ).animate(delay: 100.ms).scale(
                  begin: const Offset(0, 0),
                  duration: 400.ms,
                  curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                _isConfirming ? 'Confirm PIN' : appProvider.t('set_pin'),
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? 'Re-enter your 6-digit PIN'
                    : appProvider.t('pin_desc'),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 48),
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
                      color: index < currentPin.length
                          ? AppTheme.primary
                          : Colors.white.withOpacity(0.12),
                      boxShadow: index < currentPin.length
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(),
              const Spacer(),
              // Number keypad
              if (_isLoading)
                const CircularProgressIndicator(color: AppTheme.primary)
              else
                _buildKeypad(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const keys = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [null, 0, -1], // null = empty, -1 = delete
    ];

    return Column(
      children: keys
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((key) {
                  if (key == null) {
                    return const SizedBox(width: 80, height: 70);
                  }
                  if (key == -1) {
                    return GestureDetector(
                      onTap: _onDelete,
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
                    onTap: () => _onKeyPress(key),
                    child: Container(
                      width: 80,
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.06)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
            ),
          )
          .toList(),
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2);
  }
}
