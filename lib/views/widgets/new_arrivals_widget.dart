import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infinite_app/views/collection_screen.dart';
import 'package:infinite_app/views/product_details_screen.dart';

class NewArrivalWidget extends StatefulWidget {
  const NewArrivalWidget({super.key});

  @override
  State<NewArrivalWidget> createState() => _NewArrivalWidgetState();
}

class _NewArrivalWidgetState extends State<NewArrivalWidget> {
  List<dynamic> newArrivals = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNewArrivals();
  }

  Future<void> fetchNewArrivals() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://infinite-clothing.onrender.com/api/products/new-arrivals',
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          newArrivals = data;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Failed to load new arrivals';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "New Arrivals",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CollectionScreen(category: 'All'),
                    ),
                  );
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
        SizedBox(
          height: 240,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : newArrivals.isEmpty
                      ? const Center(
                          child: Text(
                            'No new arrivals found',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount:
                              newArrivals.length > 6 ? 6 : newArrivals.length,
                          itemBuilder: (context, index) {
                            final product = newArrivals[index];
                            return _buildProductCard(product);
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: product['_id'],
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 155,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(
                      image: NetworkImage(product['images'][0]['url']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (product['discountPrice'] != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(((product['discountPrice'] - product['price']) / product['discountPrice']) * 100).round()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs.${(product['price'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                      if (product['discountPrice'] != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          'Rs.${(product['discountPrice'] as num).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: product['_id'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Select Options',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
