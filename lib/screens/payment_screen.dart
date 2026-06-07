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

  const PaymentScreen(
      {Key? key,
      required this.orderType,
      required this.table,
      required this.paymentMethod,
      required this.cartItems,
      required this.total})
      : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

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
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF3E2723)),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Payment',
              style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6B5B4F), Color(0xFF8D7B68)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Icon(Icons.lock_rounded, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  const Text('Secure Payment',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Your transaction is encrypted and secure',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 13))
                ]),
              ),
              const SizedBox(height: 24),
              _buildInfoRow('Order Type', widget.orderType),
              if (widget.table != null) _buildInfoRow('Table', widget.table!),
              _buildInfoRow('Payment', _getPaymentName(widget.paymentMethod)),
              const SizedBox(height: 20),
              const Text('Items',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723))),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0D6C9))),
                child: Column(
                  children: [
                    ...widget.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item['quantity']}x ${item['name']}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF757575))),
                              Text(
                                  'Rp${_formatPrice(item['price'] * item['quantity'])}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF3E2723)))
                            ]))),
                    const Divider(height: 16, color: Color(0xFFE0D6C9)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E2723))),
                          Text('Rp${_formatPrice(widget.total)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B5B4F)))
                        ]),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5B4F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.payment_rounded, size: 20),
                              SizedBox(width: 10),
                              Text('Pay Now',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))
                            ]),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildSecurityBadge(Icons.verified_rounded, 'Verified'),
                const SizedBox(width: 16),
                _buildSecurityBadge(Icons.shield_rounded, 'Encrypted')
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF757575))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E2723)))
        ]));
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF6B5B4F)),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)))
    ]);
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final subtotal = widget.cartItems.fold<double>(
        0,
        (sum, item) =>
            sum + (item['price'] as num) * (item['quantity'] as num));
    final tax = subtotal * 0.11;
    final total = subtotal + tax;

    // ─── Kirim ke backend MongoDB ─────────────────────────────────
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
            // ✅ FIX: lowercase agar sesuai enum backend ('dine-in' / 'takeaway')
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

        // ✅ FIX: Pakai _id dari MongoDB sebagai orderId
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          orderId = data['_id'] ?? orderId;
        }
      }
    } catch (e) {
      // Gagal kirim ke backend, tetap lanjut dengan ID lokal
    }
    // ─────────────────────────────────────────────────────────────

    // Simpan lokal juga (untuk cache My Orders di app)
    final order = Order(
      id: orderId, // ✅ Pakai _id dari MongoDB
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
              orderNumber: orderId, total: widget.total)),
      (route) => false,
    );
  }

  String _getPaymentName(String? id) {
    const methods = {
      'qris': 'QRIS',
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'cash': 'Cash'
    };
    return methods[id] ?? 'Unknown';
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
