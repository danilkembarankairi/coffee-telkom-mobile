import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'menu_screen.dart'; // ✅ Ganti ini

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key})
      : super(key: key); // ✅ Tidak ada parameter 'from'

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                const SizedBox(height: 40),

                // Logo & Welcome Text
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF6B5B4F), width: 2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/Logo-Telu-Coffee-new.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text(
                                  'CT',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B5B4F),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome To Coffee Telkom',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Login to continue ordering',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Form Login
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email or Phone',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'your@email.com',
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Color(0xFF9E9E9E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF6B5B4F), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email or phone';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Color(0xFF9E9E9E)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF9E9E9E),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD7CCC8)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF6B5B4F), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: const Color(0xFF6B5B4F),
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // Forgot password logic
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B5B4F),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Login logic here
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MenuScreen(
                                      initialIndex:
                                          0), // ✅ Kembali ke MenuScreen biasa
                                ),
                              );
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
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Or continue with
                      Row(
                        children: const [
                          Expanded(child: Divider(color: Color(0xFFD7CCC8))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFD7CCC8))),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: Icons.g_mobiledata,
                            color: Colors.red,
                            onPressed: () {
                              // Google login
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            icon: Icons.facebook,
                            color: Colors.blue,
                            onPressed: () {
                              // Facebook login
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            icon: Icons.apple,
                            color: Colors.black,
                            onPressed: () {
                              // Apple login
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Register',
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

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD7CCC8)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
