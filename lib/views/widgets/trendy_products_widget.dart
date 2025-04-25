import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infinite_app/views/widgets/product_card_widget.dart';

class TrendyProductsWidget extends StatefulWidget {
  const TrendyProductsWidget({super.key});

  @override
  State<TrendyProductsWidget> createState() => _TrendyProductsWidgetState();
}

class _TrendyProductsWidgetState extends State<TrendyProductsWidget> {
  List<dynamic> trendyProducts = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTrendyProducts();
  }

  Future<void> fetchTrendyProducts() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://infinite-clothing.onrender.com/api/products'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          trendyProducts = data;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Failed to load trendy products';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Trendy Products",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (errorMessage.isNotEmpty)
          Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          )
        else if (trendyProducts.isEmpty)
          const Center(
            child: Text(
              'No products found',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: trendyProducts.length,
            itemBuilder: (context, index) {
              final product = trendyProducts[index];
              return ProductCardWidget(product: product);
            },
          ),
      ],
    );
  }
}
