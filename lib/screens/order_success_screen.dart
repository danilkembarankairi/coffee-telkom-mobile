import 'package:flutter/material.dart';
import 'menu_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final double total;

  const OrderSuccessScreen(
      {Key? key, required this.orderNumber, required this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: const Color(0xFF81C784),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF81C784).withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 4)
                      ]),
                  child: const Icon(Icons.check_rounded,
                      size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Order Confirmed! 🎉',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                  'Your order is being prepared. We\'ll notify you when it\'s ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF757575), height: 1.5)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4))
                    ]),
                child: Column(
                  children: [
                    _buildDetailRow('Order Number', orderNumber, isBold: true),
                    const SizedBox(height: 12),
                    _buildDetailRow('Total Paid', 'Rp${_formatPrice(total)}'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Estimated Time', '15-20 minutes'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MenuScreen(initialIndex: 0)),
                        (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5B4F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0),
                  child: const Text('Back to Menu',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                  onPressed: () {},
                  child: const Text('Track My Order',
                      style: TextStyle(
                          color: Color(0xFF6B5B4F),
                          fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF757575),
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400)),
      Text(value,
          style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF3E2723),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500))
    ]);
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
