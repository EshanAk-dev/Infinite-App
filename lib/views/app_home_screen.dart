import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/views/widgets/banner.dart';
import 'package:infinite_app/views/collection_screen.dart';
import 'package:infinite_app/views/widgets/new_arrivals_widget.dart';
import 'package:infinite_app/views/widgets/women_topwear_widget.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  int selectedCategoryIndex = 0;
  final List<Map<String, String>> categoryData = [
    {'name': 'All', 'image': 'assets/category_image/all.jpg'},
    {'name': 'Men', 'image': 'assets/category_image/men.jpg'},
    {'name': 'Women', 'image': 'assets/category_image/women.jpg'},
    {'name': 'Top Wear', 'image': 'assets/category_image/top_wear.jpg'},
    {'name': 'Bottom Wear', 'image': 'assets/category_image/bottom_wear.jpg'},
  ];

  // Navigate to collection screen when category is selected
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Header parts
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
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              "3",
                              style: TextStyle(
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
            // For banner
            HomeBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Shop By Category",
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to all collections
                      navigateToCollection('All');
                    },
                    child: const Text("See All",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 0,
                            color: Colors.black38,
                            fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),

            // Category list - Updated with navigation
            // Category list with images
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: List.generate(categoryData.length, (index) {
                    final category = categoryData[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                        navigateToCollection(category['name']!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: selectedCategoryIndex == index
                                  ? Colors.black
                                  : Colors.grey[200],
                              child: CircleAvatar(
                                radius: 26,
                                backgroundImage: AssetImage(category['image']!),
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category['name']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedCategoryIndex == index
                                    ? Colors.black
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // New Arrival Widget
            const NewArrivalWidget(),
            const SizedBox(height: 20),

            const WomenTopWearWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
