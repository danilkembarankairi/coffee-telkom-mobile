import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _current = 0;

  final List<Map<String, dynamic>> sliderData = [
    {
      'title': 'PREMIUM ROASTED',
      'subtitle': 'ARTISAN BREWED • EXCEPTIONAL TASTE',
      'description':
          'Experience the perfect blend of craftsmanship and innovation.',
      'features': [
        'Award winning blend',
        'Lab tested quality',
        'Sustainably sourced'
      ],
    },
    {
      'title': 'PERFECT EVERY BREW',
      'subtitle': 'MODERN TECHNOLOGY • AUTHENTIC TASTE',
      'description':
          'Experience the perfect blend of craftsmanship and innovation.',
      'features': [
        'Premium coffee beans',
        'Precision process',
        'Consistent flavor'
      ],
    },
    {
      'title': 'COFFEE TELKOM',
      'subtitle': 'MODERN COFFEE • INNOVATION • CONNECTION',
      'description':
          'High-quality coffee, crafted with technology and tradition.',
      'features': [
        'Brewed with technology',
        'Served with care',
        'Designed for you'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildSlider()),
            _buildBottomDots(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToLogin,
        backgroundColor: const Color(0xFF6B5B4F),
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: const Text(
          'Start Shopping',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo di kiri
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6B5B4F), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/Logo-Telu-Coffee-new.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'CT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B5B4F),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Title di tengah
          const Expanded(
            child: Column(
              children: [
                Text(
                  'COFFEE TELKOM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723),
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Premium Coffee Experience',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8D7B68),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Profile icon di kanan
          GestureDetector(
            onTap: _navigateToLogin,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 22,
                color: Color(0xFF6B5B4F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        onPageChanged: (index, reason) {
          setState(() => _current = index);
        },
      ),
      items: sliderData.map((item) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: const Color(0xFFFAF8F3),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 150,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Image Section - Gambar kopi di tengah dengan gradasi
                    Container(
                      height: MediaQuery.of(context).size.height * 0.40,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Stack(
                        children: [
                          // Gambar dengan rounded corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/coffee_background.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          // Gradasi di bagian bawah (DIPERPANJANG)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 100, // Diperpanjang dari 120 ke 180
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    const Color(0xFFFAF8F3).withOpacity(0.2),
                                    const Color(0xFFFAF8F3).withOpacity(0.4),
                                    const Color(0xFFFAF8F3).withOpacity(0.7),
                                    const Color(0xFFFAF8F3).withOpacity(0.9),
                                    const Color(0xFFFAF8F3),
                                  ],
                                  stops: const [
                                    0.0,
                                    0.25,
                                    0.45,
                                    0.65,
                                    0.8,
                                    0.92,
                                    1.0
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Gradasi di sisi kiri
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    const Color(0xFFFAF8F3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Gradasi di sisi kanan
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    const Color(0xFFFAF8F3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12), // Dikurangi dari 24 ke 12

                    // Content Section
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3E2723),
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            // Underline dekoratif
                            Container(
                              width: 60,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8D7B68),
                                    Color(0xFF6B5B4F)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Subtitle
                            Text(
                              item['subtitle'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8D7B68),
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            // Description
                            Text(
                              item['description'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Features
                            ..._buildFeatures(item['features']),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildFeatures(List<String> features) {
    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8D7B68), Color(0xFF6B5B4F)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B5B4F).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              feature,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5D4E3F),
                letterSpacing: 0.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBottomDots() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          sliderData.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _current == index ? 28 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _current == index
                  ? const Color(0xFF6B5B4F)
                  : const Color(0xFFD7CCC8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}
