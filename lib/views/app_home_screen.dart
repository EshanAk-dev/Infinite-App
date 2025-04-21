import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/views/widgets/banner.dart';
import 'package:infinite_app/views/collection_screen.dart';
import 'package:infinite_app/views/widgets/new_arrivals_widget.dart';
import 'package:infinite_app/views/widgets/women_topwear_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  int selectedCategoryIndex = 0;
  DateTime? lastBackPressed;
  int cartItemCount = 3; // Example cart item count
  final List<Map<String, String>> categoryData = [
    {'name': 'All', 'image': 'assets/category_image/all.jpg'},
    {'name': 'Men', 'image': 'assets/category_image/men.jpg'},
    {'name': 'Women', 'image': 'assets/category_image/women.jpg'},
    {'name': 'Top Wear', 'image': 'assets/category_image/top_wear.jpg'},
    {'name': 'Bottom Wear', 'image': 'assets/category_image/bottom_wear.jpg'},
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;
          Fluttertoast.showToast(
            msg: 'Press back again to exit',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
          );
          return false;
        }
        return true; // Exit app
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/infinite_logo.png",
                      height: 40,
                    ),
                    // Shopping bag with badge
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(Iconsax.shopping_bag, size: 28),
                        if (cartItemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "$cartItemCount",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Banner
              const HomeBanner(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Shop By Category",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        navigateToCollection('All');
                      },
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
              // Category List
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: List.generate(categoryData.length, (index) {
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
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // New Arrivals
              const NewArrivalWidget(),
              const SizedBox(height: 20),
              // Women's Top Wear
              const WomenTopWearWidget(),
              const SizedBox(height: 20),
            ],
          ),
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isSelected ? Colors.black : Colors.grey[200],
              child: CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(categoryImage),
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
