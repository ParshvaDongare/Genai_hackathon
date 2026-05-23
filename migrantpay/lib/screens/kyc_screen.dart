import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  String _selectedDoc = '';
  bool _docUploaded = false;
  bool _selfieUploaded = false;
  bool _isSubmitting = false;
  String _kycStatus = 'idle'; // idle, pending, verified

  final List<Map<String, dynamic>> _docTypes = [
    {'id': 'aadhaar', 'name': 'Aadhaar Card', 'icon': Icons.credit_card},
    {'id': 'pan', 'name': 'PAN Card', 'icon': Icons.credit_card_outlined},
    {'id': 'voter', 'name': 'Voter ID', 'icon': Icons.how_to_vote_outlined},
    {'id': 'passport', 'name': 'Passport', 'icon': Icons.book_outlined},
  ];

  void _submitKyc() async {
    if (_selectedDoc.isEmpty || !_docUploaded || !_selfieUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all steps', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
      _kycStatus = 'pending';
    });
    final appProvider = context.read<AppProvider>();
    try {
      await ApiService.submitKyc(
        appProvider.phoneNumber,
        appProvider.token,
        _selectedDoc,
      );
      appProvider.updateKycStatus('verified');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _kycStatus = 'verified';
        });
      }
    } catch (_) {
      appProvider.submitKyc();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _kycStatus = 'verified';
        });
      }
    }
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    if (_kycStatus == 'verified') {
      return _buildVerifiedScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: AppTheme.textPrimary, size: 18),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _goToHome,
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.inter(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(),
                const SizedBox(height: 32),
                Text(
                  appProvider.t('kyc_title'),
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  appProvider.t('kyc_desc'),
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppTheme.textSecondary),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 10),
                // KYC Benefits
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.secondary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.secondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'KYC unlocks higher transaction limits up to ₹2 Lakh/month',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppTheme.secondary),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 28),
                // Step 1: Document Type
                _buildStepHeader('1', 'Select Document Type',
                    _selectedDoc.isNotEmpty),
                const SizedBox(height: 12),
                ...List.generate(
                  _docTypes.length ~/ 2,
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDocTypeCard(_docTypes[row * 2]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDocTypeCard(_docTypes[row * 2 + 1]),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 24),
                // Step 2: Upload Document
                _buildStepHeader('2', 'Upload Document', _docUploaded),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _docUploaded = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _docUploaded
                          ? AppTheme.secondary.withOpacity(0.1)
                          : AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _docUploaded
                            ? AppTheme.secondary.withOpacity(0.4)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _docUploaded
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppTheme.secondary, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Document Uploaded',
                                style: GoogleFonts.inter(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file_outlined,
                                  color: AppTheme.textMuted, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload document photo',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'JPG, PNG up to 5MB',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textHint,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                  ),
                ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.1),
                const SizedBox(height: 20),
                // Step 3: Selfie
                _buildStepHeader('3', 'Take Selfie', _selfieUploaded),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _selfieUploaded = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _selfieUploaded
                          ? AppTheme.secondary.withOpacity(0.1)
                          : AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selfieUploaded
                            ? AppTheme.secondary.withOpacity(0.4)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: _selfieUploaded
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppTheme.secondary, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Selfie Captured',
                                style: GoogleFonts.inter(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_front_outlined,
                                  color: AppTheme.textMuted, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to take selfie',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Face clearly visible in good lighting',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textHint,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                  ),
                ).animate(delay: 600.ms).fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 32),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitKyc,
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
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _kycStatus == 'pending'
                                        ? 'Verifying...'
                                        : 'Submitting...',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                appProvider.t('submit_kyc'),
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
      ),
    );
  }

  Widget _buildStepHeader(String step, String title, bool isDone) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: isDone ? AppTheme.greenGradient : null,
            color: isDone ? null : AppTheme.bgElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone ? Colors.transparent : AppTheme.textHint,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    step,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDone ? AppTheme.secondary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDocTypeCard(Map<String, dynamic> doc) {
    final isSelected = _selectedDoc == doc['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedDoc = doc['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              doc['icon'] as IconData,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              doc['name'] as String,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedScreen() {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.greenGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.verified_outlined,
                    color: Colors.white, size: 60),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0, 0),
                      duration: 600.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(),
              const SizedBox(height: 32),
              Text(
                'KYC Verified!',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 12),
              Text(
                'Your identity has been verified successfully.\nYou can now access all features including\nhigher transaction limits.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 500.ms).fadeIn(),
              const SizedBox(height: 16),
              // Benefits chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildBenefitChip('₹2L/month limit'),
                  _buildBenefitChip('All features unlocked'),
                  _buildBenefitChip('Priority support'),
                ],
              ).animate(delay: 600.ms).fadeIn(),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _goToHome,
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
                            'Go to My Wallet',
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
              ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
