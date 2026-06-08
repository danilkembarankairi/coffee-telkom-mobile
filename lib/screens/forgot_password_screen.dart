import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const String baseUrl = 'https://coffee-telkom.my.id/api';

  // Step 1 — input email
  final _emailController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  // Step 2 — input token + password baru
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _resetFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // 0 = form email, 1 = form token+password, 2 = sukses
  int _step = 0;

  String _sentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Step 1: Kirim email ─────────────────────────────────────────
  Future<void> _sendResetEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/password/forgot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          _sentEmail = _emailController.text.trim();
          _step = 1;
        });
      } else {
        _showSnack(data['msg'] ?? 'Gagal mengirim email', isError: true);
      }
    } catch (e) {
      _showSnack('Koneksi gagal. Periksa internet kamu.', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Step 2: Reset password dengan token ────────────────────────
  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': _tokenController.text.trim(),
          'newPassword': _newPasswordController.text,
        }),
      );
      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() => _step = 2);
      } else {
        _showSnack(data['msg'] ?? 'Gagal reset password', isError: true);
      }
    } catch (e) {
      _showSnack('Koneksi gagal. Periksa internet kamu.', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : const Color(0xFF6B5B4F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3E2723)),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0); // balik ke form email
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _step == 0
              ? 'Lupa Password'
              : _step == 1
                  ? 'Buat Password Baru'
                  : 'Berhasil',
          style: const TextStyle(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _step == 0
                ? _buildStep1Email()
                : _step == 1
                    ? _buildStep2Reset()
                    : _buildStep3Success(),
          ),
        ),
      ),
    );
  }

  // ─── Step 1: Form Email ──────────────────────────────────────────
  Widget _buildStep1Email() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F0E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded,
                size: 48, color: Color(0xFF6B5B4F)),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Reset Password',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan email akun kamu. Kami akan kirim kode reset ke email tersebut.',
          style: TextStyle(
              fontSize: 14, color: Color(0xFF8D6E63), height: 1.5),
        ),
        const SizedBox(height: 32),
        Form(
          key: _emailFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A4A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  hint: 'your@email.com',
                  icon: Icons.email_outlined,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                    return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              _buildPrimaryButton(
                label: 'Kirim Kode Reset',
                onPressed: _isLoading ? null : _sendResetEmail,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 2: Form Token + Password Baru ─────────────────────────
  Widget _buildStep2Reset() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Info banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0E8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD7CCC8)),
          ),
          child: Row(
            children: [
              const Icon(Icons.mark_email_read_rounded,
                  color: Color(0xFF6B5B4F), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cek email kamu!',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kode dikirim ke $_sentEmail\nCopy kode dari email, paste di bawah.',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8D6E63),
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Form(
          key: _resetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Token field
              const Text('Kode Reset',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A4A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tokenController,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFF3E2723)),
                decoration: _inputDecoration(
                  hint: 'Paste kode dari email di sini',
                  icon: Icons.vpn_key_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste_rounded,
                        color: Color(0xFF9E9E9E), size: 20),
                    tooltip: 'Paste',
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) {
                        _tokenController.text = data!.text!.trim();
                      }
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Kode tidak boleh kosong';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password baru
              const Text('Password Baru',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A4A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: _inputDecoration(
                  hint: 'Minimal 6 karakter',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF9E9E9E),
                    ),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Password tidak boleh kosong';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Konfirmasi password
              const Text('Konfirmasi Password',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A4A))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: _inputDecoration(
                  hint: 'Ulangi password baru',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF9E9E9E),
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Konfirmasi password tidak boleh kosong';
                  if (v != _newPasswordController.text)
                    return 'Password tidak cocok';
                  return null;
                },
              ),

              const SizedBox(height: 28),

              _buildPrimaryButton(
                label: 'Ganti Password',
                onPressed: _isLoading ? null : _resetPassword,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              // Kirim ulang
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _step = 0),
                  child: const Text(
                    'Tidak dapat kode? Kirim ulang',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B5B4F),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 3: Sukses ──────────────────────────────────────────────
  Widget _buildStep3Success() {
    return Column(
      key: const ValueKey('step3'),
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F0E8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              size: 56, color: Color(0xFF6B5B4F)),
        ),
        const SizedBox(height: 28),
        const Text(
          'Password Berhasil Diubah!',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Password kamu sudah diperbarui.\nSilakan login dengan password baru.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: Color(0xFF8D6E63), height: 1.5),
        ),
        const SizedBox(height: 40),
        _buildPrimaryButton(
          label: 'Login Sekarang',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          isLoading: false,
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF9E9E9E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B5B4F), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[400]!),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B5B4F),
          disabledBackgroundColor: const Color(0xFFBCAAA4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
      ),
    );
  }
}
