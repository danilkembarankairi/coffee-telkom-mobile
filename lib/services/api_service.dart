import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://coffee-telkom.my.id/api';

  // ─── Simpan token & user ke SharedPreferences ──────────────────
  static Future<void> saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', user['id'] ?? '');
    await prefs.setString('userName', user['name'] ?? '');
    await prefs.setString('userEmail', user['email'] ?? '');
    await prefs.setString('userRole', user['role'] ?? 'user');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Auth header helper ────────────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── POST /api/auth/login ──────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      await saveSession(data['token'], data['user']);
    }
    return data;
  }

  // ─── POST /api/auth/google ─────────────────────────────────────
  // Kirim access_token dari GoogleSignIn ke backend,
  // backend yang verifikasi ke Google API
  static Future<Map<String, dynamic>> loginWithGoogle(
    String accessToken,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'access_token': accessToken}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      await saveSession(data['token'], data['user']);
    }
    return data;
  }

  // ─── POST /api/auth/register ───────────────────────────────────
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      await saveSession(data['token'], data['user']);
    }
    return data;
  }

  // ─── GET /api/user/profile ────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ─── PUT /api/user/profile ────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        if (phone != null) 'phone': phone,
      }),
    );
    return jsonDecode(response.body);
  }

  // ─── PUT /api/user/change-password ────────────────────────────
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/change-password'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  // ─── POST /api/password/forgot ────────────────────────────────
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/password/forgot'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }
}
