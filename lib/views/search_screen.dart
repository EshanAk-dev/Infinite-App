// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_app/views/widgets/product_card_widget.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:infinite_app/services/cart_service.dart';
import 'package:infinite_app/views/cart_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> products = [];
  bool isLoading = false;
  String errorMessage = '';
  DateTime? lastBackPressed;
  FocusNode _searchFocusNode = FocusNode();

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        products = [];
        errorMessage = '';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://infinite-clothing.onrender.com/api/products?search=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load products. Please try again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search for products...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey[600]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          products = [];
                          errorMessage = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: TextStyle(color: Colors.black87),
            onChanged: (value) => searchProducts(value),
            onSubmitted: (value) => searchProducts(value),
          ),
        ),
        actions: [
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
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.black),
                      ),
                    )
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red[400]),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () =>
                                    searchProducts(_searchController.text),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        )
                      : products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.search_normal,
                                      size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 24),
                                  Text(
                                    _searchController.text.isEmpty
                                        ? 'Search for your favorite products'
                                        : 'No products found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Try different keywords',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                        return ProductCardWidget(
                                          product: product,
                                        );
                                      },
                                      childCount: products.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
            )
          ],
        ),
      ),
    );
  }
}
