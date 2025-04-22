import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infinite_app/views/collection_screen.dart';
import 'package:infinite_app/views/product_details_screen.dart';

class WomenTopWearWidget extends StatefulWidget {
  const WomenTopWearWidget({super.key});

  @override
  State<WomenTopWearWidget> createState() => _WomenTopWearWidgetState();
}

class _WomenTopWearWidgetState extends State<WomenTopWearWidget> {
  List<dynamic> womenTopWear = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchWomenTopWear();
  }

  Future<void> fetchWomenTopWear() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://infinite-clothing.onrender.com/api/products?gender=Women&category=Top+Wear'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          womenTopWear = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load women top wear';
          isLoading = false;
        });
      }
    } catch (e) {
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
                "Top Wear for Women",
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
                          const CollectionScreen(category: 'Top Wear'),
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
                  ? Center(child: Text(errorMessage))
                  : womenTopWear.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount:
                              womenTopWear.length > 6 ? 6 : womenTopWear.length,
                          itemBuilder: (context, index) {
                            final product = womenTopWear[index];
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
                                    // Product Image
                                    Container(
                                      height: 155,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              product['images'][0]['url']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Product Info
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              if (product['discountPrice'] !=
                                                  null) ...[
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Rs.${(product['discountPrice'] as num).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 10,
                                                    decoration: TextDecoration
                                                        .lineThrough,
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
                                                    builder: (context) =>
                                                        ProductDetailScreen(
                                                      productId: product['_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                          },
                        ),
        ),
      ],
    );
  }
}
