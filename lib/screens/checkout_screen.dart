import 'package:flutter/material.dart';
import 'payment_screen.dart';
import 'menu_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;

  const CheckoutScreen({Key? key, required this.cartItems, required this.total})
      : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _orderType = 'Dine-in';
  String? _selectedArea;
  String? _selectedPayment;
  bool _isNavigating = false;

  // Area tempat duduk untuk Coffee Telkom
  final List<String> _seatingAreas = [
    'Area A - Window Seat',
    'Area B - Center',
    'Area C - Corner',
    'Area D - Outdoor',
    'Bar Counter'
  ];

  // Hanya QRIS dan Cash
  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'qris', 'name': 'QRIS', 'icon': Icons.qr_code_rounded},
    {'id': 'cash', 'name': 'Cash', 'icon': Icons.money_rounded},
  ];

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
          title: const Text('Checkout',
              style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Order Type'),
                    const SizedBox(height: 12),
                    _buildOrderTypeToggle(),
                    const SizedBox(height: 24),
                    if (_orderType == 'Dine-in') ...[
                      _buildSectionTitle('Select Seating Area'),
                      const SizedBox(height: 12),
                      _buildSeatingAreaSelector(),
                      const SizedBox(height: 24),
                    ],
                    if (_orderType == 'Takeaway') ...[
                      _buildSectionTitle('Pickup Time'),
                      const SizedBox(height: 12),
                      _buildPickupTimeSelector(),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionTitle('Payment Method'),
                    const SizedBox(height: 12),
                    _buildPaymentSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Order Summary'),
                    const SizedBox(height: 12),
                    _buildOrderPreview(),
                  ],
                ),
              ),
            ),
            _buildCheckoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3E2723)));
  }

  Widget _buildOrderTypeToggle() {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['Dine-in', 'Takeaway'].map((type) {
          final isSelected = _orderType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _orderType = type;
                  if (type == 'Dine-in') _selectedArea = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ]
                        : []),
                child: Center(
                    child: Text(type,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF6B5B4F)
                                : const Color(0xFF757575)))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeatingAreaSelector() {
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _seatingAreas.map((area) {
          final isSelected = _selectedArea == area;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedArea = area;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B5B4F) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6B5B4F)
                          : const Color(0xFFE0D6C9))),
              child: Text(area,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF3E2723))),
            ),
          );
        }).toList());
  }

  Widget _buildPickupTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0D6C9))),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              color: Color(0xFF6B5B4F), size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Est. Ready in 15-20 mins',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3E2723))),
                Text('You can pick up at counter',
                    style:
                        TextStyle(fontSize: 12, color: const Color(0xFF9E9E9E)))
              ])),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD)),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Column(
      children: _paymentMethods.map((method) {
        final isSelected = _selectedPayment == method['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPayment = method['id'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6B5B4F)
                        : const Color(0xFFE0D6C9)),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: const Color(0xFF6B5B4F).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2))
                      ]
                    : []),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(method['icon'] as IconData,
                        color: const Color(0xFF6B5B4F), size: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(method['name'] as String,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3E2723)))),
                Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6B5B4F)
                                : const Color(0xFFBDBDBD),
                            width: 2)),
                    child: isSelected
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Color(0xFF6B5B4F),
                                shape: BoxShape.circle))
                        : null),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderPreview() {
    return Container(
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
                    Text('Rp${_formatPrice(item['price'] * item['quantity'])}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3E2723)))
                  ]))),
          const Divider(height: 16, color: Color(0xFFE0D6C9)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723))),
            Text('Rp${_formatPrice(widget.total)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B5B4F)))
          ]),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    final canCheckout = _orderType == 'Dine-in'
        ? _selectedArea != null && _selectedPayment != null
        : _selectedPayment != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4))
      ]),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canCheckout && !_isNavigating
              ? () {
                  setState(() => _isNavigating = true);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                              orderType: _orderType,
                              table: _selectedArea,
                              paymentMethod: _selectedPayment,
                              cartItems: widget.cartItems,
                              total: widget.total)));
                  if (mounted) setState(() => _isNavigating = false);
                }
              : null,
          style: ElevatedButton.styleFrom(
              backgroundColor: canCheckout
                  ? const Color(0xFF6B5B4F)
                  : const Color(0xFFBDBDBD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text('Continue to Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white)
          ]),
        ),
      ),
    );
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
