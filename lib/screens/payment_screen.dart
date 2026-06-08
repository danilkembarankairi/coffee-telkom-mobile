import 'package:flutter/material.dart';
import 'order_success_screen.dart';
import 'menu_screen.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  final String orderType;
  final String? table;
  final String? paymentMethod;
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const PaymentScreen({
    Key? key,
    required this.orderType,
    required this.table,
    required this.paymentMethod,
    required this.cartItems,
    required this.total,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isQRIS = widget.paymentMethod == 'qris';
    final isCash = widget.paymentMethod == 'cash';

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF3E2723)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Payment',
            style: TextStyle(
                color: Color(0xFF3E2723),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QRIS Payment Section
              if (isQRIS) _buildQRISPaymentSection(),

              // Cash Payment Section - Centered
              if (isCash) _buildCashPaymentSection(),

              const SizedBox(height: 24),

              // Order Details
              _buildSectionTitle('Order Details'),
              const SizedBox(height: 12),
              _buildInfoRow('Order Type', widget.orderType),
              if (widget.table != null)
                _buildInfoRow('Table/Area', widget.table!),
              _buildInfoRow(
                  'Payment Method', _getPaymentName(widget.paymentMethod)),
              const SizedBox(height: 20),

              // Items Section
              const Text(
                'Items',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723)),
              ),
              const SizedBox(height: 12),
              _buildItemsCard(),

              const SizedBox(height: 32),

              // Pay Button
              _buildPayButton(),

              const SizedBox(height: 16),

              // Security Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSecurityBadge(Icons.verified_rounded, 'Verified'),
                  const SizedBox(width: 16),
                  _buildSecurityBadge(Icons.shield_rounded, 'Encrypted'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // QRIS Payment Section with QR Code
  Widget _buildQRISPaymentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5B4F), Color(0xFF8D7B68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B4F).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // QRIS Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 48,
              color: Color(0xFF6B5B4F),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan QRIS to Pay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan QR code below with your mobile banking app',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          // QR Code Image
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/QR.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code, size: 80, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'QRIS Code',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Amount: Rp${_formatPrice(widget.total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cash Payment Section - Centered Professional Design
  Widget _buildCashPaymentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5B4F), Color(0xFF8D7B68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B4F).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cash Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.payments_rounded,
              size: 56,
              color: Color(0xFF6B5B4F),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cash Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pay at the counter when you pick up your order',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Instructions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Show this order number at cashier',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3E2723),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0D6C9)),
      ),
      child: Column(
        children: [
          ...widget.cartItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item['quantity']}x ${item['name']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                      ),
                    ),
                    Text(
                      'Rp${_formatPrice(item['price'] * item['quantity'])}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16, color: Color(0xFFE0D6C9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2723),
                ),
              ),
              Text(
                'Rp${_formatPrice(widget.total)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5B4F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B5B4F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B5B4F)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final subtotal = widget.cartItems.fold<double>(
      0,
      (sum, item) => sum + (item['price'] as num) * (item['quantity'] as num),
    );
    final tax = subtotal * 0.11;
    final total = subtotal + tax;

    // Generate Order ID
    String orderId =
        'CT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('https://coffee-telkom.my.id/api/order'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'orderType': widget.orderType.toLowerCase(),
            'tableNumber': widget.table,
            'paymentMethod': widget.paymentMethod,
            'tax': tax,
            'items': widget.cartItems
                .map((item) => {
                      'name': item['name'],
                      'price': item['price'],
                      'quantity': item['quantity'],
                      'sugarLevel': item['customization'] ?? '',
                    })
                .toList(),
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          orderId = data['_id'] ?? orderId;
        }
      }
    } catch (e) {
      // Continue with local ID if backend fails
    }

    // Save order locally
    final order = Order(
      id: orderId,
      orderDate: DateTime.now(),
      orderType: widget.orderType,
      tableNumber: widget.table,
      paymentMethod: widget.paymentMethod ?? 'cash',
      items: widget.cartItems
          .map((item) => OrderItem(
                id: item['id'] as int,
                name: item['name'] as String,
                price: (item['price'] as num).toInt(),
                quantity: item['quantity'] as int,
                image: item['image'] as String,
                customization: item['customization'] as String?,
              ))
          .toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: 'Processing',
    );
    await OrderService().addOrder(order);

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderNumber: orderId,
            total: widget.total,
          ),
        ),
        (route) => false,
      );
    }
  }

  String _getPaymentName(String? id) {
    const methods = {
      'qris': 'QRIS',
      'cash': 'Cash',
    };
    return methods[id] ?? 'Unknown';
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
