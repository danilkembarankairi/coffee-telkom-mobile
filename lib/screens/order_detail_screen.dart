import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

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
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Helper function untuk convert hex string ke Color
  Color _hexToColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: CustomScrollView(
        slivers: [
          // App Bar with Status
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
                      order.id,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _hexToColor(order.statusColor), // ✅ FIX
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
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _hexToColor(order.statusColor).withOpacity(0.15), // ✅ FIX
                      const Color(0xFFFAF8F3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Order Content
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
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: const Color(0xFF6B5B4F).withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Ordered: ${order.formattedDate}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                order.orderType == 'Dine-in'
                    ? Icons.table_bar_rounded
                    : Icons.takeout_dining_rounded,
                size: 16,
                color: const Color(0xFF6B5B4F).withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                '${order.orderType}${order.tableNumber != null ? ' • ${order.tableNumber}' : order.pickupTime != null ? ' • Pickup: ${order.pickupTime}' : ''}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.payment_rounded,
                size: 16,
                color: const Color(0xFF6B5B4F).withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Paid via ${_getPaymentName(order.paymentMethod)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
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
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.local_cafe, color: Color(0xFF6B5B4F)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2723),
                  ),
                ),
                if (item.customization != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.customization!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Rp${_formatPrice(item.price.toDouble())} × ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B5B4F),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp${_formatPrice((item.price * item.quantity).toDouble())}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
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
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFE0D6C9),
                  width: 1,
                ),
              ),
            ),
            child: _buildPriceRow(
              'Total Paid',
              'Rp${_formatPrice(order.total)}',
              isTotal: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? const Color(0xFF3E2723) : const Color(0xFF757575),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF6B5B4F) : const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(Order order) {
    final statuses = ['Processing', 'Preparing', 'Ready', 'Completed'];
    final currentIndex = statuses.indexOf(order.status);
    final statusColor = _hexToColor(order.statusColor); // ✅ FIX

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
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isActive = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return Padding(
              padding:
                  EdgeInsets.only(bottom: index < statuses.length - 1 ? 16 : 0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? statusColor
                          : const Color(0xFFE0E0E0), // ✅ FIX
                      border: Border.all(
                        color: isActive
                            ? statusColor
                            : const Color(0xFFBDBDBD), // ✅ FIX
                        width: 2,
                      ),
                    ),
                    child: isActive && !isCurrent
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                                ? const Color(0xFF3E2723)
                                : const Color(0xFFBDBDBD),
                          ),
                        ),
                        if (isCurrent && order.status != 'Completed')
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _getStatusDescription(status),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
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
                          : const Color(0xFFE0E0E0), // ✅ FIX
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
              onPressed: () {
                // Reorder same items
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B5B4F),
                side: const BorderSide(color: Color(0xFF6B5B4F)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reorder',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Rate order
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Rate',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
            _orderService.updateOrderStatus(order.id, 'Completed');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order marked as completed!'),
                backgroundColor: Color(0xFF81C784),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF81C784),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'I\'ve Picked Up My Order',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          _showCancelDialog(order);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE57373),
          side: const BorderSide(color: Color(0xFFE57373)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Cancel Order',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE57373)),
            SizedBox(width: 8),
            Text('Cancel Order'),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF757575)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              _orderService.updateOrderStatus(order.id, 'Cancelled');
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order cancelled'),
                  backgroundColor: Color(0xFFE57373),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
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
