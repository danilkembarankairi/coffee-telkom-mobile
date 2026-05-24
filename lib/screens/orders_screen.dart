import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  final int initialIndex;
  const OrdersScreen({Key? key, this.initialIndex = 1})
      : super(key: key); // ✅ Default 1 (Orders
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Load sample orders untuk demo
    _orderService.addSampleOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orderService.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
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
            title: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'My Orders',
                style: TextStyle(
                  color: Color(0xFF3E2723),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFAF8F3),
                      const Color(0xFFFAF8F3).withOpacity(0.8),
                      const Color(0xFFFAF8F3).withOpacity(0.4),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Orders List or Empty State
          orders.isEmpty
              ? SliverFillRemaining(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildEmptyState(),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = orders[index];
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildOrderCard(order, index),
                        );
                      },
                      childCount: orders.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0, end: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5F0E8), Color(0xFFE8E0D5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B5B4F).withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 56,
                      color: Color(0xFF6B5B4F),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start ordering your favorite coffee\nand track them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Back to menu
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5B4F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_cafe_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Browse Menu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                          int.parse(order.statusColor.replaceAll('#', '0xFF'))),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Info: Date + Type
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: const Color(0xFF6B5B4F).withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.formattedDate,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    order.orderType == 'Dine-in'
                        ? Icons.table_bar_rounded
                        : Icons.takeout_dining_rounded,
                    size: 14,
                    color: const Color(0xFF6B5B4F).withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.orderType}${order.tableNumber != null ? ' • ${order.tableNumber}' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Items Preview
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          '• ${item.quantity}x ${item.name}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3E2723),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• +${order.items.length - 2} more items',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6B5B4F).withOpacity(0.7),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Footer: Total + Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      Text(
                        'Rp${_formatPrice(order.total)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B5B4F),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF6B5B4F),
                      size: 18,
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

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
