import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import 'menu_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int cartItemCount;
  final Function(List<Map<String, dynamic>>)? onCartChanged;
  final int initialIndex;

  const CartScreen({
    Key? key,
    required this.cartItems,
    required this.cartItemCount,
    this.onCartChanged,
    this.initialIndex = 1,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ✅ FIX: Jangan pakai 'late', langsung inisialisasi
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<Map<String, dynamic>> get _cartItems => widget.cartItems;

  double get _subtotal {
    return _cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double get _tax => _subtotal * 0.11;
  double get _total => _subtotal + _tax;

  void _updateQuantity(int id, int change) {
    final item = _cartItems.firstWhere((i) => i['id'] == id);
    final newQty = (item['quantity'] + change).clamp(1, 10);

    setState(() {
      if (newQty == 0) {
        _cartItems.removeWhere((i) => i['id'] == id);
      } else {
        item['quantity'] = newQty;
      }
      if (widget.onCartChanged != null) {
        widget.onCartChanged!(_cartItems);
      }
    });
  }

  void _removeItem(int id) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == id);
      if (widget.onCartChanged != null) {
        widget.onCartChanged!(_cartItems);
      }
    });
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const MenuScreen(initialIndex: 0)));
        break;
      case 1:
        break;
      case 2:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen(initialIndex: 2)));
        break;
      case 3:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen(initialIndex: 3)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const MenuScreen(initialIndex: 0)));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF3E2723)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Cart',
            style: TextStyle(
                color: Color(0xFF3E2723),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            if (_cartItems.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _cartItems.clear();
                    if (widget.onCartChanged != null) {
                      widget.onCartChanged!(_cartItems);
                    }
                  });
                },
                child: const Text('Clear All',
                    style: TextStyle(
                        color: Color(0xFFE57373),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        body: _cartItems.isEmpty
            ? _buildEmptyCart()
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return _buildCartItem(item);
                      },
                    ),
                  ),
                  _buildOrderSummary(),
                ],
              ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E8), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 48, color: Color(0xFF6B5B4F)),
            ),
            const SizedBox(height: 24),
            const Text('Your cart is empty',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723))),
            const SizedBox(height: 8),
            const Text('Add some delicious coffee to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF757575), height: 1.4)),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: const Text('Browse Menu',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 72,
                height: 72,
                color: const Color(0xFFF5F0E8),
                child: Image.asset(item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.local_cafe, color: Color(0xFF6B5B4F))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(item['name'],
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E2723)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: Color(0xFFBDBDBD)),
                          onPressed: () => _removeItem(item['id']),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints()),
                    ],
                  ),
                  if (item['customization'] != null) ...[
                    const SizedBox(height: 2),
                    Text(item['customization'],
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9E9E9E)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 4),
                  Text('Rp${_formatPrice(item['price'])}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B5B4F))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0D6C9)),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                                icon: Icons.remove_rounded,
                                onPressed: item['quantity'] > 1
                                    ? () => _updateQuantity(item['id'], -1)
                                    : null),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item['quantity']}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3E2723)))),
                            _buildQuantityButton(
                                icon: Icons.add_rounded,
                                onPressed: item['quantity'] < 10
                                    ? () => _updateQuantity(item['id'], 1)
                                    : null),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                          'Rp${_formatPrice(item['price'] * item['quantity'])}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2723))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback? onPressed}) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(icon,
                    size: 16,
                    color: onPressed != null
                        ? const Color(0xFF6B5B4F)
                        : const Color(0xFFBDBDBD)))));
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4))
      ]),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', 'Rp${_formatPrice(_subtotal)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Tax (11%)', 'Rp${_formatPrice(_tax)}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: const Color(0xFFE0D6C9), width: 1))),
            child: _buildSummaryRow('Total', 'Rp${_formatPrice(_total)}',
                isTotal: true),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                  cartItems: List.from(_cartItems),
                                  total: _total)));
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _cartItems.isEmpty
                      ? const Color(0xFFBDBDBD)
                      : const Color(0xFF6B5B4F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Proceed to Checkout',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        size: 18, color: Colors.white)
                  ]),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.lock_outline_rounded,
                size: 14, color: const Color(0xFF9E9E9E)),
            const SizedBox(width: 4),
            Text('Secure payment • Free cancellation',
                style: TextStyle(fontSize: 11, color: const Color(0xFF9E9E9E)))
          ]),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color:
                  isTotal ? const Color(0xFF3E2723) : const Color(0xFF757575))),
      Text(value,
          style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color:
                  isTotal ? const Color(0xFF6B5B4F) : const Color(0xFF3E2723)))
    ]);
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
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4))
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => _onTabTapped(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    isSelected
                        ? items[i]['active'] as IconData
                        : items[i]['icon'] as IconData,
                    size: 22,
                    color: isSelected
                        ? const Color(0xFF6B5B4F)
                        : const Color(0xFFBDBDBD)),
                const SizedBox(height: 4),
                Text(items[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF6B5B4F)
                            : const Color(0xFFBDBDBD))),
                if (isSelected)
                  Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 20,
                      height: 2,
                      decoration: BoxDecoration(
                          color: const Color(0xFF6B5B4F),
                          borderRadius: BorderRadius.circular(2))),
              ],
            ),
          );
        }),
      ),
    );
  }

   String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
