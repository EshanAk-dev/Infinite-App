// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/views/cart_screen.dart';
import 'package:infinite_app/views/search_screen.dart';
import 'package:infinite_app/views/widgets/banner.dart';
import 'package:infinite_app/views/collection_screen.dart';
import 'package:infinite_app/views/widgets/men_topwear_widget.dart';
import 'package:infinite_app/views/widgets/new_arrivals_widget.dart';
import 'package:infinite_app/views/widgets/whatsapp_button.dart';
import 'package:infinite_app/views/widgets/women_topwear_widget.dart';
import 'package:infinite_app/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:infinite_app/views/widgets/trendy_products_widget.dart';
import 'package:infinite_app/views/widgets/internet_connectivity_widget.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  int selectedCategoryIndex = 0;
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, String>> categoryData = [
    {'name': 'All', 'image': 'assets/category_image/all.jpg'},
    {'name': 'Men', 'image': 'assets/category_image/men.jpg'},
    {'name': 'Women', 'image': 'assets/category_image/women.jpg'},
    {'name': 'Dresses', 'image': 'assets/category_image/dress.jpg'},
    {'name': 'Top Wear', 'image': 'assets/category_image/top_wear.jpg'},
    {'name': 'Bottom Wear', 'image': 'assets/category_image/bottom_wear.jpg'},
    {'name': 'Hats', 'image': 'assets/category_image/hats.jpg'},
    {'name': 'Aprons', 'image': 'assets/category_image/apron.jpg'},
  ];

  void navigateToCollection(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionScreen(category: category),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      floating: true,
      expandedHeight: 60,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                "assets/infinite_logo.png",
                height: 42,
                fit: BoxFit.contain,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Iconsax.search_normal,
                        color: Colors.black, size: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Consumer<CartService>(
                  builder: (context, cart, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Iconsax.bag_2,
                                color: Colors.black, size: 20),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  cart.itemCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(children: [
        NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              _buildAppBar(colorScheme),
            ];
          },
          body: InternetConnectivityWidget(
            showFullScreen: true,
            child: CustomScrollView(
              slivers: [
                // Home Banner
                const SliverToBoxAdapter(
                  child: HomeBanner(),
                ),

                // Shop By Category Section
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade50, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.style,
                                color: Colors.black87,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Shop By Category",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => navigateToCollection('All'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "See All",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category List
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categoryData.length,
                      itemBuilder: (context, index) {
                        final category = categoryData[index];
                        return CategoryItem(
                          categoryName: category['name']!,
                          categoryImage: category['image']!,
                          isSelected: selectedCategoryIndex == index,
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                            navigateToCollection(category['name']!);
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // New Arrivals
                const SliverToBoxAdapter(child: NewArrivalWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Women's Top Wear
                const SliverToBoxAdapter(child: WomenTopWearWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Men's Top Wear
                const SliverToBoxAdapter(child: MenTopWearWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Trendy Products
                const SliverToBoxAdapter(child: TrendyProductsWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
        const WhatsAppButton(),
      ]),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String categoryName;
  final String categoryImage;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.categoryName,
    required this.categoryImage,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  categoryImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            categoryName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? Colors.black
                  : colorScheme.onSurface.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
