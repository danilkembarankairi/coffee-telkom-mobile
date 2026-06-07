import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import '../services/order_service.dart';

class ProfileScreen extends StatefulWidget {
  final int initialIndex;

  const ProfileScreen({Key? key, this.initialIndex = 4}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String baseUrl = 'https://coffee-telkom.my.id/api';

  // ─── State ───────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  Map<String, dynamic>? _userData;
  String? _token;
  File? _pickedImage;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // For password change
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ganti Foto Profil',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723))),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFF6B5B4F)),
              ),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker()
                    .pickImage(source: ImageSource.camera, imageQuality: 70);
                if (picked != null) {
                  setState(() => _pickedImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFF6B5B4F)),
              ),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker()
                    .pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (picked != null) {
                  setState(() => _pickedImage = File(picked.path));
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Load profile from backend ───────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token == null) {
        _redirectToLogin();
        return;
      }

      final res = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          _userData = data['user'];
          _nameController.text = _userData?['name'] ?? '';
          _emailController.text = _userData?['email'] ?? '';
          _phoneController.text = _userData?['phone'] ?? '';
        });
      } else if (res.statusCode == 401) {
        _redirectToLogin();
      } else {
        _showSnack(data['msg'] ?? 'Gagal memuat profil', isError: true);
      }
    } catch (e) {
      _showSnack('Koneksi gagal: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Save profile edits ──────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Nama tidak boleh kosong', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          _userData = data['user'];
          _isEditing = false;
        });
        _showSnack('Profil berhasil diperbarui');
      } else {
        _showSnack(data['msg'] ?? 'Gagal menyimpan', isError: true);
      }
    } catch (e) {
      _showSnack('Koneksi gagal: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ─── Change password ─────────────────────────────────────────────
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnack('Password baru tidak cocok', isError: true);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnack('Password minimal 6 karakter', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/user/change-password'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': _oldPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        Navigator.pop(context); // close bottom sheet
        _showSnack('Password berhasil diubah');
      } else {
        _showSnack(data['msg'] ?? 'Gagal mengubah password', isError: true);
      }
    } catch (e) {
      _showSnack('Koneksi gagal: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────
  Future<void> _logout() async {
    OrderService().clearOrders(); // ← tambah ini
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) _redirectToLogin();
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : const Color(0xFF6B5B4F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── UI ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF6B5B4F)),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    // reset form
                    _nameController.text = _userData?['name'] ?? '';
                    _phoneController.text = _userData?['phone'] ?? '';
                  });
                },
              )
            : null,
        actions: [
          if (!_isLoading)
            _isEditing
                ? TextButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(
                              color: Color(0xFF6B5B4F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )
                : IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: Color(0xFF6B5B4F)),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B5B4F)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 28),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildActionsCard(),
                  const SizedBox(height: 16),
                  _buildLogoutButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ─── Avatar / header ─────────────────────────────────────────────
  Widget _buildAvatarSection() {
    final name = _userData?['name'] ?? 'User';
    final email = _userData?['email'] ?? '';
    final avatar = _userData?['avatar'];
    final role = _userData?['role'] ?? 'user';

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6B5B4F), width: 2.5),
                color: const Color(0xFFF5F0E8),
              ),
              child: ClipOval(
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, fit: BoxFit.cover)
                    : avatar != null
                        ? Image.network(avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _avatarFallback(name))
                        : _avatarFallback(name),
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(          // ← wrap dengan GestureDetector
                  onTap: _showImagePickerOptions, // ← tambah onTap
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B5B4F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
        ),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: role == 'admin'
                ? const Color(0xFF3E2723)
                : const Color(0xFFF5F0E8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role == 'admin' ? '👑 Admin' : '☕ Member',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: role == 'admin'
                  ? Colors.white
                  : const Color(0xFF6B5B4F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B5B4F),
        ),
      ),
    );
  }

  // ─── Info card ───────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Nama Lengkap',
            controller: _nameController,
            icon: Icons.person_rounded,
            enabled: _isEditing,
          ),
          const Divider(height: 24, color: Color(0xFFF5F0E8)),
          _buildField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_rounded,
            enabled: false, // email tidak bisa diubah
            hint: 'Email tidak dapat diubah',
          ),
          const Divider(height: 24, color: Color(0xFFF5F0E8)),
          _buildField(
            label: 'Nomor HP',
            controller: _phoneController,
            icon: Icons.phone_rounded,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF6B5B4F)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              enabled
                  ? TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: const TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Text(
                      controller.text.isNotEmpty
                          ? controller.text
                          : hint ?? '-',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: controller.text.isNotEmpty
                            ? const Color(0xFF3E2723)
                            : const Color(0xFFBDBDBD),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Action card (ganti password, dll) ──────────────────────────
  Widget _buildActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.lock_rounded,
            label: 'Ganti Password',
            onTap: _showChangePasswordSheet,
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF5F0E8)),
          _buildActionItem(
  icon: Icons.help_outline_rounded,
  label: 'Bantuan',
  onTap: () => _showInfoDialog(
    'Bantuan',
    'Untuk bantuan lebih lanjut, hubungi kami di:\n\nEmail: hello@coffeetelkom.id\nInstagram: @coffeetelkom\n\nJam operasional: 08.00 – 20.00 WIB',
  ),
),
_buildActionItem(
  icon: Icons.privacy_tip_rounded,
  label: 'Kebijakan Privasi',
  onTap: () => _showInfoDialog(
    'Kebijakan Privasi',
    'Kami menjaga kerahasiaan data pribadi Anda. Informasi yang dikumpulkan hanya digunakan untuk keperluan layanan Coffee Telkom dan tidak akan dibagikan kepada pihak ketiga tanpa persetujuan Anda.',
  ),
),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color?.withOpacity(0.1) ?? const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18, color: color ?? const Color(0xFF6B5B4F)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color ?? const Color(0xFF3E2723),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color ?? const Color(0xFFBDBDBD), size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Logout button ───────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[200]!),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ─── Change password bottom sheet ────────────────────────────────
  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Ganti Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: const Color(0xFF9E9E9E),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                  label: 'Password Lama',
                  controller: _oldPasswordController,
                  obscure: _obscureOld,
                  toggle: () => setState(() => _obscureOld = !_obscureOld)),
              const SizedBox(height: 12),
              _buildPasswordField(
                  label: 'Password Baru',
                  controller: _newPasswordController,
                  obscure: _obscureNew,
                  toggle: () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 12),
              _buildPasswordField(
                  label: 'Konfirmasi Password Baru',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirm,
                  toggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan Password',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F0E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 20,
            color: const Color(0xFF9E9E9E),
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

   void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723))),
              const SizedBox(height: 16),
              Text(content,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF757575), height: 1.6)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Mengerti',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Logout dialog ───────────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F0E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    size: 32, color: Color(0xFF6B5B4F)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Yakin ingin keluar dari akun kamu?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF8D6E63)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFBDBDBD)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(color: Color(0xFF9E9E9E))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom navigation (index 4 = Profile) ───────────────────────
  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.local_cafe_rounded, 'Menu', 0, Icons.local_cafe),
          _buildNavItem(
              Icons.receipt_long_rounded, 'Orders', 1, Icons.receipt_long),
          _buildNavItem(Icons.info_rounded, 'About', 2, Icons.info),
          _buildNavItem(Icons.mail_rounded, 'Contact', 3, Icons.mail),
          _buildNavItem(Icons.person_rounded, 'Profile', 4, Icons.person),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, IconData activeIcon) {
    final isSelected = widget.initialIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 22,
            color: isSelected
                ? const Color(0xFF6B5B4F)
                : const Color(0xFFBDBDBD),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF6B5B4F)
                  : const Color(0xFFBDBDBD),
            ),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 4) return; // already here
    Navigator.pop(context); // pop back, then menu_screen handles routing
  }
}
