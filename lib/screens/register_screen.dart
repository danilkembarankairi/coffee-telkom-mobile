import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF6B5B4F)),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 20),

                // Header
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join Coffee Telkom community',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                  ),
                ),

                const SizedBox(height: 32),

                // Form Register
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'your@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Phone
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+62 8xx-xxxx-xxxx',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password
                      _buildPasswordTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Create a password',
                        obscureText: _obscurePassword,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildPasswordTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        obscureText: _obscureConfirmPassword,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Terms & Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            activeColor: const Color(0xFF6B5B4F),
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF757575),
                                  ),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF6B5B4F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xFF6B5B4F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (!_agreeToTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please agree to Terms & Conditions'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              // ✅ Register logic - SIMPAN DATA USER DISINI
                              // Contoh: await AuthService.register(...)

                              // ✅ Tampilkan pesan sukses
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Registration successful! Please login.'),
                                  backgroundColor: Color(0xFF6B5B4F),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // ✅ Navigasi ke Login Screen (BUKAN langsung ke Dashboard)
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B5B4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B5B4F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
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
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E)),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF9E9E9E),
              ),
              onPressed: onToggle,
            ),
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
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
