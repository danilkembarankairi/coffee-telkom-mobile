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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo Circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFF6B5B4F), width: 1.2),
                  borderRadius: BorderRadius.circular(16),
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B5B4F),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'COFFEE TELKOM',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A4A4A),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          // Icon kanan - Cart dan Profile
          Row(
            children: [
              // Cart Icon
              GestureDetector(
                onTap: () {
                  _navigateToLogin();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: const Color(0xFF6B5B4F),
                  ),
                ),
              ),
              // Profile Icon
              GestureDetector(
                onTap: () {
                  _navigateToLogin();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: const Color(0xFF6B5B4F),
                  ),
                ),
              ),
            ],
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
          child: Column(
            children: [
              // Image Section dengan Gradasi Smooth
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    // Gambar
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/coffee_background.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradasi dari atas (tipis)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3],
                        ),
                      ),
                    ),
                    // Gradasi dari bawah (lebih panjang dan smooth)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFFAF8F3).withOpacity(0.3),
                            const Color(0xFFFAF8F3).withOpacity(0.6),
                            const Color(0xFFFAF8F3).withOpacity(0.85),
                            const Color(0xFFFAF8F3),
                          ],
                          stops: const [0.3, 0.6, 0.8, 0.95, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        item['subtitle'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFBDBDBD),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        item['description'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),

                      // Features
                      ..._buildFeatures(item['features']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildFeatures(List<String> features) {
    return features.asMap().entries.map((entry) {
      int index = entry.key;
      String feature = entry.value;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFBDBDBD),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFBDBDBD),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          if (index < features.length - 1) const SizedBox(height: 4),
        ],
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
          (index) => Container(
            width: _current == index ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: _current == index
                  ? const Color(0xFF8D7B68)
                  : const Color(0xFFE0E0E0),
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
