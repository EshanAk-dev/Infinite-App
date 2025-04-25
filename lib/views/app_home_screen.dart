import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/views/cart_screen.dart';
import 'package:infinite_app/views/widgets/banner.dart';
import 'package:infinite_app/views/collection_screen.dart';
import 'package:infinite_app/views/widgets/men_topwear_widget.dart';
import 'package:infinite_app/views/widgets/new_arrivals_widget.dart';
import 'package:infinite_app/views/widgets/women_topwear_widget.dart';
import 'package:infinite_app/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:infinite_app/views/widgets/trendy_products_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: colorScheme.surface,
              elevation: 0,
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/infinite_logo.png",
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    Consumer<CartService>(
                      builder: (context, cart, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Iconsax.bag_2, size: 28),
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
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
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
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            // Home Banner
            const SliverToBoxAdapter(
              child: HomeBanner(),
            ),

            // Shop By Category Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shop By Category",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => navigateToCollection('All'),
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
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
                  color: isSelected ? colorScheme.primary : Colors.transparent,
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
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
