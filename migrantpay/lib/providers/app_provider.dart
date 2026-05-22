import 'package:flutter/material.dart';

enum Language { english, hindi }

class AppProvider extends ChangeNotifier {
  Language _language = Language.english;
  bool _isLoggedIn = false;
  bool _kycDone = false;
  String _kycStatus = 'none'; // none, pending, verified, rejected
  String _userName = '';
  String _phoneNumber = '';
  String _token = ''; // backend session token

  Language get language => _language;
  bool get isLoggedIn => _isLoggedIn;
  bool get kycDone => _kycDone;
  String get kycStatus => _kycStatus;
  String get userName => _userName;
  String get phoneNumber => _phoneNumber;
  String get token => _token;
  bool get isHindi => _language == Language.hindi;

  void setLanguage(Language lang) {
    _language = lang;
    notifyListeners();
  }

  void setSession({required String token, required String phone, String? name}) {
    _token = token;
    _phoneNumber = phone;
    _userName = (name != null && name.isNotEmpty) ? name : 'Ramesh Kumar';
    _isLoggedIn = true;
    notifyListeners();
  }

  void login(String phone, String name) {
    _isLoggedIn = true;
    _phoneNumber = phone;
    _userName = name.isNotEmpty ? name : 'Ramesh Kumar';
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _token = '';
    _phoneNumber = '';
    _userName = '';
    notifyListeners();
  }

  void submitKyc() {
    _kycStatus = 'pending';
    notifyListeners();
    // Simulate verification after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _kycStatus = 'verified';
      _kycDone = true;
      notifyListeners();
    });
  }

  String t(String key) {
    if (_language == Language.hindi) {
      return _hiStrings[key] ?? _enStrings[key] ?? key;
    }
    return _enStrings[key] ?? key;
  }

  static const Map<String, String> _enStrings = {
    'app_name': 'MigrantPay',
    'tagline': 'Zero Fees. Real Freedom.',
    'welcome': 'Welcome Back',
    'get_started': 'Get Started',
    'select_language': 'Select Language',
    'language_desc': 'Choose your preferred language',
    'english': 'English',
    'hindi': 'हिंदी',
    'mobile_number': 'Mobile Number',
    'enter_mobile': 'Enter your mobile number',
    'send_otp': 'Send OTP',
    'verify_otp': 'Verify OTP',
    'otp_sent_to': 'OTP sent to',
    'enter_otp': 'Enter 6-digit OTP',
    'resend_otp': 'Resend OTP',
    'verify': 'Verify',
    'set_pin': 'Set Your PIN',
    'pin_desc': 'Create a 6-digit PIN to secure your account',
    'confirm_pin': 'Confirm PIN',
    'create_pin': 'Create PIN',
    'kyc_title': 'Complete KYC',
    'kyc_desc': 'Verify your identity to unlock full wallet features',
    'select_doc': 'Select Document Type',
    'aadhaar': 'Aadhaar Card',
    'pan': 'PAN Card',
    'voter_id': 'Voter ID',
    'passport': 'Passport',
    'upload_doc': 'Upload Document',
    'take_selfie': 'Take Selfie',
    'submit_kyc': 'Submit for Verification',
    'kyc_pending': 'KYC Verification Pending',
    'kyc_verified': 'KYC Verified',
    'kyc_rejected': 'KYC Rejected',
    'my_wallet': 'My Wallet',
    'balance': 'Balance',
    'send_money': 'Send Money',
    'add_money': 'Add Money',
    'withdraw': 'Withdraw',
    'history': 'History',
    'quick_actions': 'Quick Actions',
    'recent_txns': 'Recent Transactions',
    'see_all': 'See All',
    'send_to': 'Send To',
    'receiver_mobile': 'Receiver\'s Mobile / UPI ID',
    'enter_amount': 'Enter Amount',
    'fee': 'Transaction Fee',
    'zero_fee': '₹0 (Zero Fee!)',
    'total_amount': 'Total Amount',
    'proceed': 'Proceed',
    'confirm_transfer': 'Confirm Transfer',
    'enter_pin': 'Enter PIN to confirm',
    'transfer_success': 'Money Sent Successfully!',
    'txn_id': 'Transaction ID',
    'blockchain_hash': 'Blockchain Hash',
    'done': 'Done',
    'ai_insights': 'AI Financial Insights',
    'weekly_tip': 'Weekly Savings Tip',
    'save_goal': 'Savings Goal',
    'create_goal': 'Create New Goal',
    'invest': 'Invest',
    'risk_low': 'Low Risk',
    'risk_medium': 'Medium Risk',
    'risk_high': 'High Risk',
    'notifications': 'Notifications',
    'home': 'Home',
    'settings': 'Settings',
    'profile': 'Profile',
    'logout': 'Logout',
    'rupees': '₹',
    'zero': '₹0',
    'transaction_fee_zero': 'Zero Platform Fee',
  };

  static const Map<String, String> _hiStrings = {
    'app_name': 'MigrantPay',
    'tagline': 'शून्य शुल्क। असली आज़ादी।',
    'welcome': 'वापसी पर स्वागत',
    'get_started': 'शुरू करें',
    'select_language': 'भाषा चुनें',
    'language_desc': 'अपनी पसंदीदा भाषा चुनें',
    'english': 'English',
    'hindi': 'हिंदी',
    'mobile_number': 'मोबाइल नंबर',
    'enter_mobile': 'अपना मोबाइल नंबर दर्ज करें',
    'send_otp': 'OTP भेजें',
    'verify_otp': 'OTP सत्यापित करें',
    'otp_sent_to': 'OTP भेजा गया',
    'enter_otp': '6-अंकीय OTP दर्ज करें',
    'resend_otp': 'OTP दोबारा भेजें',
    'verify': 'सत्यापित करें',
    'set_pin': 'PIN सेट करें',
    'pin_desc': 'अपने खाते को सुरक्षित करने के लिए 6-अंकीय PIN बनाएं',
    'confirm_pin': 'PIN की पुष्टि करें',
    'create_pin': 'PIN बनाएं',
    'kyc_title': 'KYC पूर्ण करें',
    'kyc_desc': 'पूर्ण वॉलेट सुविधाओं को अनलॉक करने के लिए अपनी पहचान सत्यापित करें',
    'select_doc': 'दस्तावेज़ प्रकार चुनें',
    'aadhaar': 'आधार कार्ड',
    'pan': 'पैन कार्ड',
    'voter_id': 'वोटर आईडी',
    'passport': 'पासपोर्ट',
    'upload_doc': 'दस्तावेज़ अपलोड करें',
    'take_selfie': 'सेल्फी लें',
    'submit_kyc': 'सत्यापन के लिए जमा करें',
    'kyc_pending': 'KYC सत्यापन लंबित',
    'kyc_verified': 'KYC सत्यापित',
    'kyc_rejected': 'KYC अस्वीकृत',
    'my_wallet': 'मेरा वॉलेट',
    'balance': 'बैलेंस',
    'send_money': 'पैसे भेजें',
    'add_money': 'पैसे जोड़ें',
    'withdraw': 'निकासी',
    'history': 'इतिहास',
    'quick_actions': 'त्वरित क्रियाएं',
    'recent_txns': 'हाल के लेनदेन',
    'see_all': 'सभी देखें',
    'send_to': 'किसे भेजें',
    'receiver_mobile': 'प्राप्तकर्ता का मोबाइल / UPI ID',
    'enter_amount': 'राशि दर्ज करें',
    'fee': 'लेनदेन शुल्क',
    'zero_fee': '₹0 (शून्य शुल्क!)',
    'total_amount': 'कुल राशि',
    'proceed': 'आगे बढ़ें',
    'confirm_transfer': 'स्थानांतरण की पुष्टि करें',
    'enter_pin': 'पुष्टि करने के लिए PIN दर्ज करें',
    'transfer_success': 'पैसे सफलतापूर्वक भेजे गए!',
    'txn_id': 'लेनदेन ID',
    'blockchain_hash': 'ब्लॉकचेन हैश',
    'done': 'हो गया',
    'ai_insights': 'AI वित्तीय अंतर्दृष्टि',
    'weekly_tip': 'साप्ताहिक बचत टिप',
    'save_goal': 'बचत लक्ष्य',
    'create_goal': 'नया लक्ष्य बनाएं',
    'invest': 'निवेश करें',
    'risk_low': 'कम जोखिम',
    'risk_medium': 'मध्यम जोखिम',
    'risk_high': 'उच्च जोखिम',
    'notifications': 'सूचनाएं',
    'home': 'होम',
    'settings': 'सेटिंग्स',
    'profile': 'प्रोफाइल',
    'logout': 'लॉग आउट',
    'rupees': '₹',
    'zero': '₹0',
    'transaction_fee_zero': 'शून्य प्लेटफ़ॉर्म शुल्क',
  };
}
