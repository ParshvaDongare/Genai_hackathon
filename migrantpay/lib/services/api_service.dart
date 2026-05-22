import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your machine's IP if testing on Android device
  // For Chrome/Web: localhost works fine
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> _headers(String? phone, String? token) {
    return {
      'Content-Type': 'application/json',
      if (phone != null) 'x-phone': phone,
      if (token != null) 'x-token': token,
    };
  }

  // ─── AUTH ───────────────────────────────────────────────────────────────────

  /// Send OTP to phone via Twilio (or demo mode returns demoOtp)
  static Future<Map<String, dynamic>> sendOtp(String phone, {String? name}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'name': name ?? ''}),
    );
    return _parse(res);
  }

  /// Verify OTP — returns token + user info on success
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );
    return _parse(res);
  }

  /// Set 6-digit PIN for the account
  static Future<Map<String, dynamic>> setPin(
      String phone, String token, String pin) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/set-pin'),
      headers: _headers(phone, token),
      body: jsonEncode({'phone': phone, 'token': token, 'pin': pin}),
    );
    return _parse(res);
  }

  /// Verify PIN before sensitive actions
  static Future<Map<String, dynamic>> verifyPin(
      String phone, String token, String pin) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-pin'),
      headers: _headers(phone, token),
      body: jsonEncode({'phone': phone, 'token': token, 'pin': pin}),
    );
    return _parse(res);
  }

  /// Submit KYC — auto-verified in demo
  static Future<Map<String, dynamic>> submitKyc(
      String phone, String token, String docType) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/submit-kyc'),
      headers: _headers(phone, token),
      body: jsonEncode({'phone': phone, 'token': token, 'docType': docType}),
    );
    return _parse(res);
  }

  // ─── WALLET ─────────────────────────────────────────────────────────────────

  /// Get wallet balance
  static Future<Map<String, dynamic>> getBalance(
      String phone, String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/wallet/balance'),
      headers: _headers(phone, token),
    );
    return _parse(res);
  }

  /// Get transaction history
  static Future<Map<String, dynamic>> getTransactions(
      String phone, String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/wallet/transactions'),
      headers: _headers(phone, token),
    );
    return _parse(res);
  }

  /// Send money (zero fee)
  static Future<Map<String, dynamic>> sendMoney({
    required String phone,
    required String token,
    required String receiverPhone,
    required String receiverName,
    required double amount,
    required String pin,
    String note = '',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/wallet/send'),
      headers: _headers(phone, token),
      body: jsonEncode({
        'phone': phone,
        'token': token,
        'receiverPhone': receiverPhone,
        'receiverName': receiverName,
        'amount': amount,
        'pin': pin,
        'note': note,
      }),
    );
    return _parse(res);
  }

  /// Add money to wallet
  static Future<Map<String, dynamic>> addMoney({
    required String phone,
    required String token,
    required double amount,
    String method = 'UPI',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/wallet/add'),
      headers: _headers(phone, token),
      body: jsonEncode({
        'phone': phone,
        'token': token,
        'amount': amount,
        'method': method,
      }),
    );
    return _parse(res);
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _parse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    throw ApiException(
      message: body['error'] ?? 'Unknown error',
      statusCode: res.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
