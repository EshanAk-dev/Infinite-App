import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayPalHelper {
  // Get current exchange rate from USD to LKR
  static Future<double> getExchangeRate() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['rates']['LKR'] ?? 290.0;
      } else {
        print('Exchange rate API error: ${response.statusCode}');
        return 200.0;
      }
    } catch (e) {
      print('Exchange rate fetch error: $e');
      return 200.0;
    }
  }

  // Process PayPal payment
  static Future<void> processPayment({
    required BuildContext context,
    required String checkoutId,
    required double amountLKR,
    required String clientId,
    required String secretKey,
    required String returnURL,
    required String cancelURL,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final exchangeRate = await getExchangeRate();
      final amountUSD = amountLKR / exchangeRate;
      final formattedAmount = amountUSD.toStringAsFixed(2);

      // Use root navigator to ensure safe context usage
      final navigator = Navigator.of(context, rootNavigator: true);

      // Show PayPal screen
      navigator.push(
        MaterialPageRoute(
          builder: (BuildContext newContext) => UsePaypal(
            sandboxMode: true,
            clientId: clientId,
            secretKey: secretKey,
            returnURL: returnURL,
            cancelURL: cancelURL,
            transactions: [
              {
                "amount": {
                  "total": formattedAmount,
                  "currency": "USD",
                  "details": {
                    "subtotal": formattedAmount,
                    "shipping": '0.00',
                    "shipping_discount": 0
                  }
                },
                "description":
                    "Payment for Infinite Clothing Order #$checkoutId",
                "item_list": {
                  "items": [
                    {
                      "name": "Infinite Clothing Order",
                      "quantity": 1,
                      "price": formattedAmount,
                      "currency": "USD"
                    }
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) {
              print("Payment success: $params");

              final paymentDetails = {
                'id': params['paymentId'] ?? params['id'] ?? 'unknown',
                'status': 'completed',
                'update_time': DateTime.now().toIso8601String(),
                'payer': {
                  'email_address': params['payerEmail'] ??
                      params['payer']?['email_address'] ??
                      'unknown@example.com',
                },
                'amount': {
                  'value': formattedAmount,
                  'currency_code': 'USD',
                },
                'LKR_amount': amountLKR.toStringAsFixed(2),
              };

              // Return to previous screen first
              Future.microtask(() {
                Navigator.of(newContext).maybePop();
              });

              onSuccess(paymentDetails);
            },
            onError: (error) {
              print("Payment error: $error");
              Future.microtask(() {
                Navigator.of(newContext).maybePop();
              });
              onError(error.toString());
            },
            onCancel: (params) {
              print("Payment cancelled: $params");
              Future.microtask(() {
                Navigator.of(newContext).maybePop();
              });
              onError('Payment cancelled by user');
            },
          ),
        ),
      );
    } catch (e) {
      print("PayPal processing error: $e");
      onError(e.toString());
    }
  }
}
