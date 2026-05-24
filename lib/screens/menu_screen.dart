import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';

class MenuScreen extends StatefulWidget {
  final int initialIndex;

  const MenuScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  late int _cartItemCount = 0;
  List<Map<String, dynamic>> _cartItems = [];
  int _selectedIndex = 0; // ✅ Default 0 = Menu
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'id': 1,
      'name': 'ICED LATTE',
      'price': 30000,
      'category': 'Cold',
      'image': 'assets/images/iced-latte.jpg',
      'description': 'Smooth espresso with cold milk and a hint of vanilla.',
      'rating': 4.8,
      'reviews': 124,
      'sizes': ['S', 'M', 'L'],
      'hasSugar': true,
      'temperatures': ['Cold'],
    },
    {
      'id': 2,
      'name': 'CAPPUCCINO',
      'price': 28000,
      'category': 'Hot',
      'image': 'assets/images/cappucino.jpeg',
      'description': 'Rich espresso with steamed milk foam and cocoa dust.',
      'rating': 4.9,
      'reviews': 256,
      'sizes': ['S', 'M', 'L'],
      'hasSugar': false,
      'temperatures': ['Hot', 'Extra Hot'],
    },
    {
      'id': 3,
      'name': 'MATCHA LATTE',
      'price': 33000,
      'category': 'Non-Coffee',
      'image': 'assets/images/matcha-latte.jpg',
      'description': 'Premium Japanese matcha whisked to perfection.',
      'rating': 4.7,
      'reviews': 89,
      'sizes': ['S', 'M', 'L'],
      'hasSugar': true,
      'temperatures': ['Hot', 'Cold'],
    },
    {
      'id': 4,
      'name': 'COLD BREW',
      'price': 33000,
      'category': 'Cold',
      'image': 'assets/images/coldbrew.jpeg',
      'description': 'Slow-steeped for 12 hours for smooth, bold flavor.',
      'rating': 4.9,
      'reviews': 312,
      'sizes': ['M', 'L'],
      'hasSugar': true,
      'temperatures': ['Cold'],
    },
    {
      'id': 5,
      'name': 'LATTE',
      'price': 30000,
      'category': 'Hot',
      'image': 'assets/images/latte.jpg',
      'description': 'Classic espresso with silky steamed milk.',
      'rating': 4.6,
      'reviews': 198,
      'sizes': ['S', 'M', 'L'],
      'hasSugar': false,
      'temperatures': ['Hot'],
    },
    {
      'id': 6,
      'name': 'ESPRESSO',
      'price': 25000,
      'category': 'Hot',
      'image': 'assets/images/espresso.jpg',
      'description': 'Pure bold espresso shot, the heart of every coffee.',
      'rating': 4.8,
      'reviews': 445,
      'sizes': ['S'],
      'hasSugar': false,
      'temperatures': ['Hot'],
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    var items = _menuItems;

    if (_selectedCategory != 'All') {
      items =
          items.where((item) => item['category'] == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item['description']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return items;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart(
    Map<String, dynamic> item, {
    String size = 'M',
    String? sugarLevel,
    String? temperature,
  }) {
    final customizationParts = <String>[];
    if (size != 'M') customizationParts.add('Size: $size');
    if (sugarLevel != null && sugarLevel != '50%') {
      customizationParts.add('Sugar: $sugarLevel');
    }
    if (temperature != null && temperature != 'Hot') {
      customizationParts.add('Temp: $temperature');
    }

    final customization = customizationParts.isNotEmpty
        ? customizationParts.join(' • ')
        : 'Size: $size';

    setState(() {
      final existingIndex = _cartItems.indexWhere(
          (i) => i['id'] == item['id'] && i['customization'] == customization);

      if (existingIndex != -1) {
        _cartItems[existingIndex]['quantity'] =
            (_cartItems[existingIndex]['quantity'] as int) + 1;
      } else {
        _cartItems.add({
          ...item,
          'quantity': 1,
          'customization': customization,
          'selectedSize': size,
          'selectedSugar': sugarLevel,
          'selectedTemp': temperature,
        });
      }

      _cartItemCount++;
    });

    _showAddToCartNotification('${item['name']} ($size)');
  }

  void _showCustomizationSheet(Map<String, dynamic> item) {
    final availableSizes = List<String>.from(item['sizes'] ?? ['S', 'M', 'L']);
    final availableTemps = List<String>.from(item['temperatures'] ?? ['Hot']);
    final hasSugar = item['hasSugar'] ?? false;

    String selectedSize =
        availableSizes.contains('M') ? 'M' : availableSizes.first;
    String? selectedSugar = hasSugar ? '50%' : null;
    String selectedTemp = availableTemps.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFFAF8F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D6C9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFF5F0E8),
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_cafe,
                            color: Color(0xFF6B5B4F)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp${_formatPrice(item['price'])}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B5B4F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE0D6C9)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SIZE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E9E9E),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: availableSizes.map((size) {
                        final isSelected = selectedSize == size;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedSize = size),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6B5B4F)
                                    : const Color(0xFFF5F0E8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6B5B4F)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                size,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF3E2723),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (availableTemps.length > 1) ...[
                      const Text(
                        'TEMPERATURE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E9E9E),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: availableTemps.map((temp) {
                          final isSelected = selectedTemp == temp;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedTemp = temp),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6B5B4F)
                                      : const Color(0xFFF5F0E8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6B5B4F)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  temp,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF3E2723),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (hasSugar) ...[
                      const Text(
                        'SUGAR LEVEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E9E9E),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ['0%', '25%', '50%', '75%', '100%'].map((sugar) {
                          final isSelected = selectedSugar == sugar;
                          return GestureDetector(
                            onTap: () => setState(() => selectedSugar = sugar),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6B5B4F)
                                    : const Color(0xFFF5F0E8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sugar,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF3E2723),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    _addToCart(
                      item,
                      size: selectedSize,
                      sugarLevel: hasSugar ? selectedSugar : null,
                      temperature:
                          availableTemps.length > 1 ? selectedTemp : null,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B4F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ADD TO CART • Rp${_formatPrice(item['price'])}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToCartNotification(String itemName) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => overlayEntry.remove(),
            child: _AnimatedNotificationCard(
              message: '$itemName added to cart',
              onDismiss: () => overlayEntry.remove(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen(initialIndex: 0)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const OrdersScreen(initialIndex: 1)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutScreen(initialIndex: 2)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const ContactScreen(initialIndex: 3)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const MenuScreen(initialIndex: 0)),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildPromoBanner(),
              _buildCategoryFilter(),
              // ✅ FIXED: GridView bisa scroll dengan Expanded
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildMenuGrid(),
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
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Hero(
                tag: 'coffee_logo',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8D7B68), Color(0xFF6B5B4F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6B5B4F).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COFFEE TELKOM',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2723),
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Crafted Excellence',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF6B5B4F).withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 22),
                style: IconButton.styleFrom(
                  foregroundColor: const Color(0xFF6B5B4F),
                  backgroundColor: const Color(0xFFF5F0E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showLogoutDialog,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CartScreen(
                        cartItems: _cartItems,
                        cartItemCount: _cartItemCount,
                        onCartChanged: (updatedCart) {
                          setState(() {
                            _cartItems = updatedCart;
                          });
                        },
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 22,
                        color: Color(0xFF6B5B4F),
                      ),
                    ),
                    if (_cartItemCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.elasticOut,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE57373),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE57373),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            '$_cartItemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search coffee, latte, matcha...',
            hintStyle: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF6B5B4F),
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: Color(0xFF9E9E9E)),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B5B4F), Color(0xFF8D7B68)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Buy 2 Get 1 Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Cold Brews • Until Dec 31',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'Cold';
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shop',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'label': 'All', 'icon': Icons.grid_view_rounded},
      {'label': 'Hot', 'icon': Icons.local_fire_department_rounded},
      {'label': 'Cold', 'icon': Icons.ac_unit_rounded},
      {'label': 'Non-Coffee', 'icon': Icons.eco_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['label'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['label'] as String;
                _animationController.reset();
                _animationController.forward();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6B5B4F), Color(0xFF8D7B68)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected ? Colors.transparent : const Color(0xFFE0D6C9),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(0xFF6B5B4F).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF6B5B4F),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF6B5B4F),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ FIXED: GridView dengan scroll yang benar
  Widget _buildMenuGrid() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 16),
            const Text(
              'No items found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching for something else'
                  : 'Check back later for new items',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {});
      },
      color: const Color(0xFF6B5B4F),
      child: Padding(
        padding: const EdgeInsets.all(16), // ✅ Reduced padding
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12, // ✅ Reduced spacing
            mainAxisSpacing: 12, // ✅ Reduced spacing
            childAspectRatio: 0.68, // ✅ Adjusted ratio untuk kartu lebih tinggi
          ),
          itemCount: _filteredItems.length,
          itemBuilder: (context, index) {
            final item = _filteredItems[index];
            return _buildMenuItem(item, index);
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () => _showCustomizationSheet(item),
      child: Hero(
        tag: 'product_${item['id']}',
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // ✅ Reduced radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12, // ✅ Reduced blur
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16), // ✅ Reduced radius
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0E8),
                          image: DecorationImage(
                            image: AssetImage(item['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, // ✅ Reduced top position
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 10, // ✅ Reduced icon size
                              color: Color(0xFFFFB300),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${item['rating']}',
                              style: const TextStyle(
                                fontSize: 9, // ✅ Reduced font size
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(item['category']),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(item['category'])
                                  .withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item['category'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8, // ✅ Reduced font size
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10), // ✅ Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 13, // ✅ Reduced font size
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E2723),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['description'],
                        style: const TextStyle(
                          fontSize: 9, // ✅ Reduced font size
                          color: Color(0xFF757575),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp${_formatPrice(item['price'])}',
                                style: const TextStyle(
                                  fontSize: 14, // ✅ Reduced font size
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B5B4F),
                                ),
                              ),
                              Text(
                                '${item['reviews']} reviews',
                                style: const TextStyle(
                                  fontSize: 8, // ✅ Reduced font size
                                  color: Color(0xFFBDBDBD),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showCustomizationSheet(item),
                            child: Container(
                              width: 32, // ✅ Reduced size
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6B5B4F),
                                    Color(0xFF8D7B68)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6B5B4F).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 16, // ✅ Reduced icon size
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, IconData activeIcon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 22,
            color:
                isSelected ? const Color(0xFF6B5B4F) : const Color(0xFFBDBDBD),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF6B5B4F)
                  : const Color(0xFFBDBDBD),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Color(0xFF6B5B4F),
                ),
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
                'Are you sure you want to logout from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B5B4F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE57373),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hot':
        return const Color(0xFFFF8A65);
      case 'Cold':
        return const Color(0xFF64B5F6);
      case 'Non-Coffee':
        return const Color(0xFF81C784);
      default:
        return const Color(0xFF6B5B4F);
    }
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

// ============================================================================
// ✅ MODERN NOTIFICATION WIDGET
// ============================================================================
class _AnimatedNotificationCard extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _AnimatedNotificationCard({
    Key? key,
    required this.message,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_AnimatedNotificationCard> createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<_AnimatedNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3E2723),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF81C784),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2500),
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 40 * value,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}
