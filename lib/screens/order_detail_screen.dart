import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // ✅ FIX: order bisa diupdate dari backend
  late Order _currentOrder;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();

    // ✅ Fetch status terbaru dari backend, lalu poll tiap 10 detik
    _fetchOrderStatus();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchOrderStatus(),
    );
  }

  // ✅ FIX: Ambil status order terbaru dari backend
  Future<void> _fetchOrderStatus() async {
    // Hanya poll jika order belum selesai/dibatalkan
    if (_currentOrder.status == 'Completed' ||
        _currentOrder.status == 'Cancelled') return;

    // Kalau ID bukan MongoDB _id (misal pakai ID lokal CT-xxx), skip polling
    if (_currentOrder.id.startsWith('CT-')) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse(
            'https://coffee-telkom.my.id/api/order/${_currentOrder.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final updated = Order.fromJson(data);
        setState(() => _currentOrder = updated);
      }
    } catch (e) {
      // Gagal fetch, tetap tampil data lokal
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFFFAF8F3),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF3E2723), size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_slideAnimation),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.id.length > 16
                          ? '...${order.id.substring(order.id.length - 16)}'
                          : order.id,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _hexToColor(order.statusColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _hexToColor(order.statusColor).withOpacity(0.15),
                      const Color(0xFFFAF8F3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                  )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(order),
                      const SizedBox(height: 20),
                      const Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...order.items.map((item) => _buildOrderItem(item)),
                      const SizedBox(height: 20),
                      _buildPriceSummary(order),
                      const SizedBox(height: 24),
                      if (order.status != 'Completed' &&
                          order.status != 'Cancelled')
                        _buildStatusTimeline(order),
                      const SizedBox(height: 32),
                      _buildActionButtons(order),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.calendar_today_rounded,
                size: 16,
                color: const Color(0xFF6B5B4F).withOpacity(0.7)),
            const SizedBox(width: 8),
            Text('Ordered: ${order.formattedDate}',
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF757575))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(
                order.orderType.toLowerCase() == 'dine-in'
                    ? Icons.table_bar_rounded
                    : Icons.takeout_dining_rounded,
                size: 16,
                color: const Color(0xFF6B5B4F).withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
                '${order.orderType}${order.tableNumber != null && order.tableNumber!.isNotEmpty ? ' • ${order.tableNumber}' : ''}',
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF757575))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.payment_rounded,
                size: 16,
                color: const Color(0xFF6B5B4F).withOpacity(0.7)),
            const SizedBox(width: 8),
            Text('Paid via ${_getPaymentName(order.paymentMethod)}',
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF757575))),
          ]),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.white,
              child: _getItemImage(item.name),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723))),
                if (item.customization != null &&
                    item.customization!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.customization!,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E))),
                ],
                const SizedBox(height: 4),
                Text('Rp${_formatPrice(item.price.toDouble())} × ${item.quantity}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B5B4F))),
              ],
            ),
          ),
          Text('Rp${_formatPrice((item.price * item.quantity).toDouble())}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723))),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', 'Rp${_formatPrice(order.subtotal)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Tax (11%)', 'Rp${_formatPrice(order.tax)}'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Color(0xFFE0D6C9), width: 1)),
            ),
            child: _buildPriceRow('Total Paid',
                'Rp${_formatPrice(order.total)}',
                isTotal: true),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal
                  ? const Color(0xFF3E2723)
                  : const Color(0xFF757575),
            )),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 17 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? const Color(0xFF6B5B4F)
                  : const Color(0xFF3E2723),
            )),
      ],
    );
  }

  Widget _buildStatusTimeline(Order order) {
    final statuses = ['Processing', 'Preparing', 'Ready', 'Completed'];
    final currentIndex = statuses.indexOf(order.status);
    final statusColor = _hexToColor(order.statusColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Status',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723))),
              // ✅ Indikator auto-refresh
              const Row(
                children: [
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Color(0xFF6B5B4F),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('Live',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isActive = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < statuses.length - 1 ? 16 : 0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive ? statusColor : const Color(0xFFE0E0E0),
                      border: Border.all(
                        color:
                            isActive ? statusColor : const Color(0xFFBDBDBD),
                        width: 2,
                      ),
                    ),
                    child: isActive && !isCurrent
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? const Color(0xFF3E2723)
                                  : const Color(0xFFBDBDBD),
                            )),
                        if (isCurrent && order.status != 'Completed')
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(_getStatusDescription(status),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9E9E9E))),
                          ),
                      ],
                    ),
                  ),
                  if (index < statuses.length - 1)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 2,
                      height: 24,
                      color: index < currentIndex
                          ? statusColor
                          : const Color(0xFFE0E0E0),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Processing':
        return 'Confirming your order...';
      case 'Preparing':
        return 'Barista is making your coffee...';
      case 'Ready':
        return 'Ready for pickup!';
      default:
        return '';
    }
  }

  Widget _buildActionButtons(Order order) {
    if (order.status == 'Completed' || order.status == 'Cancelled') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B5B4F),
                side: const BorderSide(color: Color(0xFF6B5B4F)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reorder',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showRateDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Rate',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }

    if (order.status == 'Ready') {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Terima kasih! Selamat menikmati.'),
                backgroundColor: Color(0xFF81C784),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF81C784),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 20),
              SizedBox(width: 8),
              Text("I've Picked Up My Order",
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF9E9E9E)),
          SizedBox(width: 8),
          Text('Hubungi admin untuk membatalkan pesanan',
              style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  void _showRateDialog() {
    int selectedRating = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rate Your Order',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723))),
                const SizedBox(height: 8),
                const Text('How was your experience?',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setDialogState(
                          () => selectedRating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 36,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Terima kasih! Rating $selectedRating bintang diberikan.'),
                          backgroundColor: const Color(0xFF6B5B4F),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5B4F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kirim Rating',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
   Widget _getItemImage(String name) {
    final map = {
      'iced latte': 'assets/images/iced-latte.jpg',
      'latte': 'assets/images/latte.jpg',
      'cappuccino': 'assets/images/cappucino.jpeg',
      'espresso': 'assets/images/espresso.jpg',
      'cold brew': 'assets/images/coldbrew.jpeg',
      'matcha latte': 'assets/images/matcha-latte.jpg',
    };

    final key = name.toLowerCase();

    final asset = map.entries
        .firstWhere(
          (e) => key.contains(e.key),
          orElse: () => const MapEntry(
            '',
            'assets/images/coffee_background.jpg',
          ),
        )
        .value;

    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.local_cafe, color: Color(0xFF6B5B4F)),
    );
  }

  String _getPaymentName(String id) {
    const methods = {
      'qris': 'QRIS',
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'cash': 'Cash',
    };
    return methods[id] ?? id;
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
