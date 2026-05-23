import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { english, hindi }

class AppProvider extends ChangeNotifier {
  static const _languageKey = 'app_language';
  static const _languageChosenKey = 'language_chosen';
  static const _loggedInKey = 'is_logged_in';
  static const _kycStatusKey = 'kyc_status';
  static const _userNameKey = 'user_name';
  static const _phoneNumberKey = 'phone_number';
  static const _tokenKey = 'auth_token';

  Language _language = Language.english;
  bool _hasSelectedLanguage = false;
  bool _isLoggedIn = false;
  bool _kycDone = false;
  String _kycStatus = 'none'; // none, pending, verified, rejected
  String _userName = '';
  String _phoneNumber = '';
  String _token = ''; // backend session token
  bool _isInitialized = false;

  Language get language => _language;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  bool get kycDone => _kycDone;
  String get kycStatus => _kycStatus;
  String get userName => _userName;
  String get phoneNumber => _phoneNumber;
  String get token => _token;
  bool get isHindi => _language == Language.hindi;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);
    _language = savedLanguage == 'hindi' ? Language.hindi : Language.english;
    _hasSelectedLanguage = prefs.getBool(_languageChosenKey) ?? false;

    _userName = prefs.getString(_userNameKey) ?? '';
    _phoneNumber = prefs.getString(_phoneNumberKey) ?? '';
    _token = prefs.getString(_tokenKey) ?? '';
    _kycStatus = prefs.getString(_kycStatusKey) ?? 'none';
    _kycDone = _kycStatus == 'verified';
    _isLoggedIn =
        (prefs.getBool(_loggedInKey) ?? false) &&
        _phoneNumber.isNotEmpty &&
        _token.isNotEmpty;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _languageKey,
      _language == Language.hindi ? 'hindi' : 'english',
    );
    await prefs.setBool(_languageChosenKey, _hasSelectedLanguage);
    await prefs.setBool(_loggedInKey, _isLoggedIn);
    await prefs.setString(_kycStatusKey, _kycStatus);

    if (_userName.isNotEmpty) {
      await prefs.setString(_userNameKey, _userName);
    } else {
      await prefs.remove(_userNameKey);
    }

    if (_phoneNumber.isNotEmpty) {
      await prefs.setString(_phoneNumberKey, _phoneNumber);
    } else {
      await prefs.remove(_phoneNumberKey);
    }

    if (_token.isNotEmpty) {
      await prefs.setString(_tokenKey, _token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  void setLanguage(Language lang) {
    _language = lang;
    _hasSelectedLanguage = true;
    _persist();
    notifyListeners();
  }

  void setSession({
    required String token,
    required String phone,
    String? name,
    String? kycStatus,
  }) {
    _token = token;
    _phoneNumber = phone;
    _userName = (name != null && name.isNotEmpty) ? name : 'Ramesh Kumar';
    _kycStatus = kycStatus ?? _kycStatus;
    _kycDone = _kycStatus == 'verified';
    _isLoggedIn = true;
    _persist();
    notifyListeners();
  }

  void updateKycStatus(String status) {
    _kycStatus = status;
    _kycDone = status == 'verified';
    _persist();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _token = '';
    _phoneNumber = '';
    _userName = '';
    _kycStatus = 'none';
    _kycDone = false;
    _persist();
    notifyListeners();
  }

  void submitKyc() {
    updateKycStatus('pending');
    // Simulate verification after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      updateKycStatus('verified');
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
    'name_required': 'Full name is required',
    'valid_phone': 'Enter a valid 10-digit mobile number',
    'accept_terms': 'Please accept Terms & Conditions',
    'full_name': 'Full Name',
    'enter_name': 'Enter your full name',
    'nav_home': 'Home',
    'nav_ai_insights': 'AI Insights',
    'nav_history': 'History',
    'nav_profile': 'Profile',
    'personalized_for_you': 'Personalized for you',
    'this_weeks_tips': 'This Week\'s Tips',
    'tip_save_100_title': 'Save ₹100 weekly',
    'tip_save_100_body': 'Set aside ₹100 every week in your Emergency Fund goal. In 1 year, you\'ll have ₹5,200!',
    'tip_spending_title': 'Your spending this month',
    'tip_spending_body': 'You sent ₹4,200 in remittances this month — ₹800 less than last month. Great job!',
    'tip_goal_title': 'You\'re 35% to your goal!',
    'tip_goal_body': 'Your Emergency Fund is ₹3,500 of ₹10,000. Keep going — just ₹6,500 more to go!',
    'tip_invest_title': 'Safe Investment Opportunity',
    'tip_invest_body': 'Government-backed Sukanya Samriddhi Yojana gives 8.2% returns with zero risk. Consider it for family!',
    'savings_goals': 'Savings Goals',
    'new_goal': 'New Goal',
    'of': 'of',
    'add_100': 'Add ₹100',
    'added_100_to': '₹100 added to',
    'micro_investments': 'Micro-Investments',
    'sebi_regulated': 'SEBI Regulated',
    'low_risk_label': 'Low Risk',
    'zero_risk_label': 'Zero Risk',
    'medium_risk_label': 'Medium Risk',
    'high_risk_label': 'High Risk',
    'min': 'Min',
    'liquid_fund': 'Liquid Fund',
    'govt_scheme': 'Government Scheme',
    'bank_fd': 'Bank FD',
    'mutual_fund': 'Mutual Fund',
    'coming_soon': 'Investment module coming soon!',
    'records': 'records',
    'all': 'All',
    'sent': 'Sent',
    'received': 'Received',
    'failed': 'Failed',
    'no_transactions': 'No transactions found',
    'today': 'Today',
    'success': 'Success',
    'fee_label': 'Fee',
    'free': '₹0',
    'transactions_stats': 'Transactions',
    'saved_fees': 'Saved in Fees',
    'account_settings': 'Account Settings',
    'kyc_verification': 'KYC Verification',
    'complete_verification': 'Complete verification',
    'verified_check': 'Verified ✓',
    'sms_push_whatsapp': 'SMS, Push, WhatsApp',
    'security_pin': 'Security & PIN',
    'change_pin_biometrics': 'Change PIN, biometrics',
    'help_support': 'Help & Support',
    'support_24_7': '24/7 customer support',
    'logout_confirm_title': 'Logout',
    'logout_confirm_desc': 'Are you sure you want to logout?',
    'cancel': 'Cancel',
    'good_morning': 'Good Morning',
    'withdraw_coming_soon': 'Withdrawal to UPI/bank coming soon!',
    'zero_fee_banner_title': '₹0 Transaction Fee — Always!',
    'zero_fee_banner_desc': 'Send money home without any platform charges',
    'ai_tip_day': 'AI Tip of the Day',
    'ai_tip_teaser': 'Save ₹100 weekly for emergency fund — reach ₹5,200 in a year!',
    'emergency_fund': 'Emergency Fund',
    'child_education': 'Children\'s Education',
    'new_home': 'New Home',
    'pm_jan_dhan': 'Pradhan Mantri Jan Dhan',
    'fd': 'Fixed Deposit',
    'balanced_mutual_fund': 'Balanced Mutual Fund',
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
    'name_required': 'पूरा नाम आवश्यक है',
    'valid_phone': 'एक मान्य 10-अंकीय मोबाइल नंबर दर्ज करें',
    'accept_terms': 'कृपया नियम और शर्तें स्वीकार करें',
    'full_name': 'पूरा नाम',
    'enter_name': 'अपना पूरा नाम दर्ज करें',
    'nav_home': 'होम',
    'nav_ai_insights': 'AI सलाह',
    'nav_history': 'इतिहास',
    'nav_profile': 'प्रोफाइल',
    'personalized_for_you': 'आपके लिए व्यक्तिगत',
    'this_weeks_tips': 'इस सप्ताह के सुझाव',
    'tip_save_100_title': 'साप्ताहिक ₹100 बचाएं',
    'tip_save_100_body': 'अपने आपातकालीन कोष लक्ष्य में हर सप्ताह ₹100 अलग रखें। 1 वर्ष में, आपके पास ₹5,200 होंगे!',
    'tip_spending_title': 'इस महीने आपका खर्च',
    'tip_spending_body': 'आपने इस महीने प्रेषण (remittance) में ₹4,200 भेजे — पिछले महीने की तुलना में ₹800 कम। बहुत बढ़िया!',
    'tip_goal_title': 'आप अपने लक्ष्य के 35% पर हैं!',
    'tip_goal_body': 'आपका आपातकालीन कोष ₹10,000 में से ₹3,500 है। आगे बढ़ते रहें — बस ₹6,500 और!',
    'tip_invest_title': 'सुरक्षित निवेश का अवसर',
    'tip_invest_body': 'सरकार समर्थित सुकन्या समृद्धि योजना शून्य जोखिम के साथ 8.2% रिटर्न देती है। परिवार के लिए इस पर विचार करें!',
    'savings_goals': 'बचत लक्ष्य',
    'new_goal': 'नया लक्ष्य',
    'of': 'का',
    'add_100': '₹100 जोड़ें',
    'added_100_to': 'में ₹100 जोड़े गए!',
    'micro_investments': 'माइक्रो-निवेश',
    'sebi_regulated': 'SEBI द्वारा विनियमित',
    'low_risk_label': 'कम जोखिम',
    'zero_risk_label': 'शून्य जोखिम',
    'medium_risk_label': 'मध्यम जोखिम',
    'high_risk_label': 'उच्च जोखिम',
    'min': 'न्यूनतम',
    'liquid_fund': 'लिक्विड फंड',
    'govt_scheme': 'सरकारी योजना',
    'bank_fd': 'बैंक एफडी',
    'mutual_fund': 'म्यूचुअल फंड',
    'coming_soon': 'निवेश मॉड्यूल जल्द ही आ रहा है!',
    'records': 'रिकॉर्ड',
    'all': 'सभी',
    'sent': 'भेजे गए',
    'received': 'प्राप्त हुए',
    'failed': 'विफल',
    'no_transactions': 'कोई लेनदेन नहीं मिला',
    'today': 'आज',
    'success': 'सफल',
    'fee_label': 'शुल्क',
    'free': '₹0',
    'transactions_stats': 'लेनदेन',
    'saved_fees': 'बचाया गया शुल्क',
    'account_settings': 'खाता सेटिंग्स',
    'kyc_verification': 'KYC सत्यापन',
    'complete_verification': 'सत्यापन पूर्ण करें',
    'verified_check': 'सत्यापित ✓',
    'sms_push_whatsapp': 'SMS, पुश, व्हाट्सएप',
    'security_pin': 'सुरक्षा और PIN',
    'change_pin_biometrics': 'PIN बदलें, बायोमेट्रिक्स',
    'help_support': 'सहायता और सहायता',
    'support_24_7': '24/7 ग्राहक सहायता',
    'logout_confirm_title': 'लॉग आउट',
    'logout_confirm_desc': 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
    'cancel': 'रद्द करें',
    'good_morning': 'सुप्रभात',
    'withdraw_coming_soon': 'UPI/बैंक से निकासी जल्द ही आ रही है!',
    'zero_fee_banner_title': '₹0 लेनदेन शुल्क — हमेशा!',
    'zero_fee_banner_desc': 'बिना किसी प्लेटफ़ॉर्म शुल्क के पैसे घर भेजें',
    'ai_tip_day': 'आज की AI सलाह',
    'ai_tip_teaser': 'आपातकालीन कोष के लिए साप्ताहिक ₹100 बचाएं — एक साल में ₹5,200 तक पहुंचें!',
    'emergency_fund': 'आपातकालीन कोष',
    'child_education': 'बच्चों की शिक्षा',
    'new_home': 'नया घर',
    'pm_jan_dhan': 'प्रधानमंत्री जन धन योजना',
    'fd': 'फिक्स्ड डिपॉजिट',
    'balanced_mutual_fund': 'संतुलित म्यूचुअल फंड',
  };
}
