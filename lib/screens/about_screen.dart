import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'contact_screen.dart';
import 'orders_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class AboutScreen extends StatefulWidget {
  final int initialIndex;

  const AboutScreen({Key? key, this.initialIndex = 2}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // ✅ FIX: Inisialisasi langsung dengan nilai default, JANGAN pakai 'late'
  int _selectedIndex = 2; // Default 2 = About

  @override
  void initState() {
    super.initState();
    // ✅ Sinkronkan dengan widget parameter
    _selectedIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: // Menu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen(initialIndex: 0)),
        );
        break;
      case 1: // Orders
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const OrdersScreen(initialIndex: 1)),
        );
        break;
      case 2: // About (current)
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const ContactScreen(initialIndex: 3)),
        );
        break;
      case 4:                                          // ← TAMBAH
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const ProfileScreen(initialIndex: 4)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen(initialIndex: 0)),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              // ✅ FIXED: SingleChildScrollView agar bisa scroll
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildDescription(),
                      const SizedBox(height: 32),
                      _buildStatsGrid(),
                      const SizedBox(height: 32),
                      _buildFeatures(),
                      const SizedBox(height: 32),
                      _buildQuote(),
                      const SizedBox(height: 32),
                      _buildCTAButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
                    errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('CT',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B5B4F)))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'COFFEE TELKOM',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2723)),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    size: 20, color: Color(0xFF6B5B4F)),
                onPressed: () => _showLogoutDialog(),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    size: 20, color: Color(0xFF6B5B4F)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      children: [
        Text(
          'WHERE TECHNOLOGY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9E9E9E),
            letterSpacing: 2,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'MEETS TRADITION',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3E2723),
            height: 1.1,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 60,
          height: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF6B5B4F),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: const Text(
        'Coffee Telkom was born from a simple yet powerful idea: what if the precision of technology could elevate the soul of coffee? Nestled in the heart of Telkom Innovation Center, we blend data-driven brewing methods with time-honored craftsmanship to create an experience that\'s both innovative and deeply personal.\n\nFrom bean selection to the final pour, every step is optimized with care. Our AI-assisted roasting profiles ensure consistency, while our master baristas bring intuition and passion to each cup. We source exclusively from ethical Indonesian farms, supporting local communities while delivering exceptional flavor. Because great coffee shouldn\'t just taste good — it should feel good too.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
          height: 1.7,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'value': '50+', 'label': 'Premium Blends'},
      {'value': '12K+', 'label': 'Happy Customers'},
      {'value': '100%', 'label': 'Ethically Sourced'},
      {'value': '4.9★', 'label': 'Average Rating'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 2.3,
      children: stats
          .map((stat) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat['value'] as String,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B5B4F))),
                    const SizedBox(height: 5),
                    Text(stat['label'] as String,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFFFFB300),
        'title': 'Innovation First',
        'desc':
            'Blending cutting-edge technology from Telkom Innovation Lab to perfect every brew.'
      },
      {
        'icon': Icons.eco_rounded,
        'color': const Color(0xFF81C784),
        'title': 'Local Soul',
        'desc':
            'Championing Indonesian coffee heritage with beans sourced from sustainable local farms.'
      },
      {
        'icon': Icons.palette_rounded,
        'color': const Color(0xFF64B5F6),
        'title': 'Crafted with Care',
        'desc':
            'Every cup is prepared by certified baristas who treat coffee as an art form.'
      },
    ];

    return Column(
      children: features
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                          color: (f['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(f['icon'] as IconData,
                          color: f['color'] as Color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['title'] as String,
                              style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3E2723))),
                          const SizedBox(height: 5),
                          Text(f['desc'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF757575),
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildQuote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0D6C9), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF5F0E8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.format_quote_rounded,
            size: 28,
            color: Color(0xFF6B5B4F),
          ),
          SizedBox(height: 12),
          Text(
            '"We don\'t just serve coffee. We craft moments of connection, powered by innovation and rooted in tradition."',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.w500,
                height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const MenuScreen(initialIndex: 0)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B5B4F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: const Color(0xFF6B5B4F).withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('EXPLORE OUR MENU',
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final items = [
      {
        'icon': Icons.local_cafe_outlined,
        'active': Icons.local_cafe_rounded,
        'label': 'Menu'
      },
      {
        'icon': Icons.receipt_long_outlined,
        'active': Icons.receipt_long_rounded,
        'label': 'Orders'
      },
      {
        'icon': Icons.info_outline,
        'active': Icons.info_rounded,
        'label': 'About'
      },
      {
        'icon': Icons.mail_outline,
        'active': Icons.mail_rounded,
        'label': 'Contact'
      },
      {
        'icon': Icons.person_outline,         
        'active': Icons.person_rounded,        
        'label': 'Profile'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 25,
              offset: const Offset(0, -5))
        ],
        border: Border(
            top: BorderSide(
                color: const Color(0xFFE0D6C9).withOpacity(0.5), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => _onTabTapped(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(8),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: const Color(0xFFF5F0E8),
                          borderRadius: BorderRadius.circular(10))
                      : null,
                  child: Icon(
                    isSelected
                        ? items[i]['active'] as IconData
                        : items[i]['icon'] as IconData,
                    size: 24,
                    color: isSelected
                        ? const Color(0xFF6B5B4F)
                        : const Color(0xFFBDBDBD),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF6B5B4F)
                          : const Color(0xFFBDBDBD)),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                        color: const Color(0xFF6B5B4F),
                        borderRadius: BorderRadius.circular(2)),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8), shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded,
                      size: 28, color: Color(0xFF6B5B4F))),
              const SizedBox(height: 18),
              const Text('Logout',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723))),
              const SizedBox(height: 10),
              const Text('Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF757575), height: 1.5)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Color(0xFF6B5B4F),
                                  fontWeight: FontWeight.w500)))),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (_) => false);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('Logout',
                          style: TextStyle(fontWeight: FontWeight.w600)),
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
}
