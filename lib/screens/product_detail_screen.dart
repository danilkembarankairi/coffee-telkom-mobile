import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onAddToCart;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${product['id']}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      product['image'],
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF3E2723)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border_rounded,
                      color: Color(0xFF3E2723)),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF8F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 18, color: Color(0xFFFFB300)),
                            const SizedBox(width: 4),
                            Text(
                              '${product['rating']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    '${product['reviews']} customer reviews',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category & Price
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(product['category']),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product['category'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rp${_formatPrice(product['price'])}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B5B4F),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'],
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF757575),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Customization Options
                  const Text(
                    'Customize',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Size Options
                  _buildOptionRow(
                    title: 'Size',
                    options: ['S', 'M', 'L'],
                    selected: 'M',
                  ),
                  const SizedBox(height: 16),

                  // Temperature Options
                  _buildOptionRow(
                    title: 'Temperature',
                    options: product['category'] == 'Cold'
                        ? ['Iced']
                        : ['Hot', 'Extra Hot'],
                    selected: product['category'] == 'Cold' ? 'Iced' : 'Hot',
                  ),
                  const SizedBox(height: 16),

                  // Sugar Level (for non-coffee)
                  if (product['category'] == 'Non-Coffee')
                    _buildOptionRow(
                      title: 'Sugar Level',
                      options: ['0%', '25%', '50%', '75%', '100%'],
                      selected: '50%',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Add to Cart Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
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
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                onAddToCart(product);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5B4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required String title,
    required List<String> options,
    required String selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((option) {
            final isSelected = option == selected;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF6B5B4F),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF6B5B4F),
                backgroundColor: const Color(0xFFF5F0E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF6B5B4F)
                        : Colors.transparent,
                  ),
                ),
                onSelected: (_) {},
              ),
            );
          }).toList(),
        ),
      ],
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
