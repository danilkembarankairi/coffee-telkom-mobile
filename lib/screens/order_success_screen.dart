import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'dart:math' as math;

class OrderSuccessScreen extends StatefulWidget {
  final String orderNumber;
  final double total;

  const OrderSuccessScreen({
    Key? key,
    required this.orderNumber,
    required this.total,
  }) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _checkController.forward();
    _confettiController.forward();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen(initialIndex: 0)),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
        body: SafeArea(
          child: Stack(
            children: [
              // Confetti Effect
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ConfettiPainter(
                          progress: _confettiController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Main Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Success Icon with Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildSuccessIcon(),
                    ),

                    const SizedBox(height: 24),

                    // Animated Content
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            _buildTitle(),
                            const SizedBox(height: 24),
                            _buildOrderCard(),
                            const SizedBox(height: 20),
                            _buildProgressTracker(),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF81C784).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Order Confirmed! 🎉',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your order is being prepared.\nWe\'ll notify you when it\'s ready.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B5B4F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF6B5B4F),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0D6C9)),
          const SizedBox(height: 16),
          _buildDetailRow('Order Number', widget.orderNumber, isBold: true),
          const SizedBox(height: 12),
          _buildDetailRow('Total Paid', 'Rp${_formatPrice(widget.total)}',
              isBold: true),
          const SizedBox(height: 12),
          _buildDetailRow('Payment', 'Ready to Pay',
              valueColor: const Color(0xFF81C784)),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5B4F), Color(0xFF8D7B68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5B4F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estimated Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '15-20 minutes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Your order will be ready soon',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStep('Ordered', true),
              _buildProgressStep('Preparing', false),
              _buildProgressStep('Ready', false),
              _buildProgressStep('Done', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrdersScreen(initialIndex: 1),
                ),
                (route) => route.isFirst,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B5B4F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.local_shipping_rounded, size: 22),
            label: const Text(
              'Track My Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuScreen(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B5B4F),
              side: const BorderSide(
                color: Color(0xFF6B5B4F),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.home_rounded, size: 20),
            label: const Text(
              'Back to Menu',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? const Color(0xFF3E2723),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

// Custom painter untuk confetti effect
class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    final random = math.Random(42);
    final colors = [
      const Color(0xFF81C784),
      const Color(0xFF6B5B4F),
      const Color(0xFFFFB74D),
      const Color(0xFFE57373),
      const Color(0xFF64B5F6),
      const Color(0xFFBA68C8),
    ];

    for (int i = 0; i < 50; i++) {
      final paint = Paint()
        ..color =
            colors[random.nextInt(colors.length)].withOpacity(1.0 - progress);

      final x = random.nextDouble() * size.width;
      final startY = size.height * 0.3;
      final y =
          startY + (progress * size.height * 0.8) + (random.nextDouble() * 50);
      final particleSize = 4.0 + random.nextDouble() * 6.0;
      final rotation = progress * math.pi * 2 * random.nextDouble();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, particleSize / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize,
            height: particleSize,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
