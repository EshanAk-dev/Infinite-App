import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:infinite_app/services/cart_service.dart';
import 'package:infinite_app/views/cart_screen.dart';
import 'package:infinite_app/views/widgets/product_card_widget.dart';

class CollectionScreen extends StatefulWidget {
  final String category;

  const CollectionScreen({super.key, required this.category});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String queryParam = '';

      if (widget.category == 'All') {
        // No filter for All
      } else if (widget.category == 'Men' || widget.category == 'Women') {
        queryParam = '?gender=${widget.category}';
      } else {
        queryParam = '?category=${widget.category}';
      }

      final response = await http.get(
        Uri.parse(
            'https://infinite-clothing.onrender.com/api/products$queryParam'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load products';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.category == 'All' ? 'All Collections' : widget.category,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: Colors.black87),
            onPressed: () {},
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
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Showing ${products.length} results',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
                : errorMessage.isNotEmpty
                    ? SliverFillRemaining(
                        child: Center(child: Text(errorMessage)))
                    : products.isEmpty
                        ? SliverFillRemaining(
                            child: Center(child: Text('No products found')))
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = products[index];
                                  return ProductCardWidget(product: product);
                                },
                                childCount: products.length,
                              ),
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}
