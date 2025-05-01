// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:infinite_app/services/cart_service.dart';
import 'package:infinite_app/views/login_screen.dart';
import 'package:infinite_app/views/order_confirmation_screen.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

const String BASE_URL = 'https://infinite-clothing.onrender.com';
const String CREATE_CHECKOUT_ENDPOINT = '/api/checkout';
const String PROCESS_PAYMENT_ENDPOINT = '/api/checkout/:id/pay';
const String FINALIZE_CHECKOUT_ENDPOINT = '/api/checkout/:id/finalize';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  String _paymentMethod = '';
  int _activeStep = 1; // 1: Shipping, 2: Payment

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(arguments: {'redirect': 'checkout'}),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartService.items.isEmpty
          ? _buildEmptyCart(theme)
          : SafeArea(
              child: isMobile
                  ? _buildMobileLayout(cartService, theme)
                  : _buildDesktopLayout(cartService, theme),
            ),
    );
  }

  Widget _buildMobileLayout(CartService cartService, ThemeData theme) {
    return Column(
      children: [
        // Checkout Steps
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _buildCheckoutSteps(),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Form Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _activeStep == 1
                        ? _buildShippingForm(theme)
                        : _buildPaymentForm(cartService, theme),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Summary
                _buildOrderSummary(cartService, theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(CartService cartService, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Checkout Steps
          _buildCheckoutSteps(),
          const SizedBox(height: 24),

          // Main Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Form
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _activeStep == 1
                        ? _buildShippingForm(theme)
                        : _buildPaymentForm(cartService, theme),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Right side - Order Summary
              Expanded(
                flex: 1,
                child: _buildOrderSummary(cartService, theme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.shopping_bag,
              size: 100,
              color: theme.colorScheme.onBackground.withOpacity(0.2)),
          const SizedBox(height: 24),
          Text('Your cart is empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6))),
          const SizedBox(height: 12),
          Text('Looks like you haven\'t added anything yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.4))),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.black,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Explore Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(1, 'Shipping', _activeStep >= 1),
        Container(
          width: 40,
          height: 1,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        _buildStep(2, 'Payment', _activeStep >= 2),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.black : Colors.grey.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              isActive && _activeStep > stepNumber ? '✓' : '$stepNumber',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }

  Widget _buildShippingForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shipping Information', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),

          // Name Fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: _inputDecoration('First Name', theme),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration('Last Name', theme),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration('Address', theme),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Address in required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // City and Postal Code
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: _inputDecoration('City', theme),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: _inputDecoration('Postal Code', theme),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Postal code is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Country and Phone
          TextFormField(
            controller: _countryController,
            decoration: _inputDecoration('Country', theme),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Country is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('Phone Number', theme),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Payment Method Selection
          Text('Payment Method', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),

          _buildPaymentMethodOption('Paypal', 'Pay with PayPal', theme),
          const SizedBox(height: 12),

          _buildPaymentMethodOption('COD', 'Cash on Delivery', theme,
              subtitle: 'Available only in Sri Lanka'),
          const SizedBox(height: 24),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    _paymentMethod.isNotEmpty) {
                  if (_paymentMethod == 'COD') {
                    _handleCODPayment();
                  } else {
                    setState(() => _activeStep = 2);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _paymentMethod == 'COD' ? 'Place Order' : 'Continue to Payment',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildPaymentMethodOption(String method, String title, ThemeData theme,
      {String? subtitle}) {
    return InkWell(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: _paymentMethod == method ? Colors.black : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _paymentMethod == method
                      ? Colors.black
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
                color: _paymentMethod == method
                    ? Colors.black
                    : Colors.transparent,
              ),
              child: _paymentMethod == method
                  ? Icon(Icons.check,
                      size: 14, color: theme.colorScheme.onPrimary)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                if (subtitle != null)
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm(CartService cartService, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: theme.textTheme.titleLarge),
        const SizedBox(height: 20),

        if (_paymentMethod == 'Paypal')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: Column(
              children: [
                Text('Pay with PayPal', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handlePaypalPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Pay with PayPal'),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        // Back and Pay buttons
        Row(
          children: [
            Expanded(
                child: OutlinedButton(
              onPressed: () => setState(() => _activeStep = 1),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              child: Text('Back',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
            )),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_paymentMethod == 'Paypal') {
                    _handlePaypalPayment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartService cartService, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Cart Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartService.items.length,
              itemBuilder: (context, index) {
                final item = cartService.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(item.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            Text('${item.size} · ${item.color}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6))),
                            const SizedBox(height: 4),
                            Text('Qty: ${item.quantity}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6))),
                          ],
                        ),
                      ),
                      Text(
                          '\Rs.${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              },
            ),

            const Divider(height: 32),

            // Order Totals
            _buildOrderTotalRow('Subtotal', cartService.totalPrice, theme),
            const SizedBox(height: 8),
            _buildOrderTotalRow('Shipping', 0, theme),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildOrderTotalRow('Total', cartService.totalPrice, theme,
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTotalRow(String label, double amount, ThemeData theme,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal
                ? theme.textTheme.bodyLarge
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
        Text('\Rs.${amount.toStringAsFixed(2)}',
            style: isTotal
                ? theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  Future<void> _handlePaypalPayment() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final cartService = Provider.of<CartService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2,
        ),
      ),
    );

    try {
      // Create checkout session
      final checkoutResponse = await http.post(
        Uri.parse(BASE_URL + CREATE_CHECKOUT_ENDPOINT),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.user?.token ?? ''}',
        },
        body: jsonEncode({
          'checkoutItems': cartService.items
              .map((item) => {
                    'productId': item.productId,
                    'name': item.name,
                    'image': item.image,
                    'price': item.price,
                    'quantity': item.quantity,
                    'size': item.size,
                    'color': item.color,
                  })
              .toList(),
          'shippingAddress': {
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'postalCode': _postalCodeController.text,
            'country': _countryController.text,
            'phone': _phoneController.text,
          },
          'paymentMethod': 'Paypal',
          'totalPrice': cartService.totalPrice,
        }),
      );

      if (checkoutResponse.statusCode != 201) {
        throw Exception('Failed to create checkout');
      }

      // final checkoutData = jsonDecode(checkoutResponse.body);
      // final checkoutId = checkoutData['_id'];

      if (!mounted) return;

      Navigator.pop(context); // Remove loading dialog

      // Show PayPal payment screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PaypalPaymentScreen(
      //       checkoutId: checkoutId,
      //       amount: cartService.totalPrice,
      //     ),
      //   ),
      // );
    } catch (e) {
      Navigator.pop(context); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
    }
  }

  Future<void> _handleCODPayment() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final cartService = Provider.of<CartService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2,
        ),
      ),
    );

    try {
      // Create checkout session
      final checkoutResponse = await http.post(
        Uri.parse(BASE_URL + CREATE_CHECKOUT_ENDPOINT),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.user?.token ?? ''}',
        },
        body: jsonEncode({
          'checkoutItems': cartService.items
              .map((item) => {
                    'productId': item.productId,
                    'name': item.name,
                    'image': item.image,
                    'price': item.price,
                    'quantity': item.quantity,
                    'size': item.size,
                    'color': item.color,
                  })
              .toList(),
          'shippingAddress': {
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'postalCode': _postalCodeController.text,
            'country': _countryController.text,
            'phone': _phoneController.text,
          },
          'paymentMethod': 'COD',
          'totalPrice': cartService.totalPrice,
        }),
      );

      if (checkoutResponse.statusCode != 201) {
        throw Exception('Failed to create checkout');
      }

      final checkoutData = jsonDecode(checkoutResponse.body);
      final checkoutId = checkoutData['_id'];

      // Mark as paid (for COD)
      final paymentResponse = await http.put(
        Uri.parse(BASE_URL +
            PROCESS_PAYMENT_ENDPOINT.replaceFirst(':id', checkoutId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.user?.token ?? ''}',
        },
        body: jsonEncode({
          'paymentStatus': 'pending COD',
          'paymentDetails': {'method': 'COD'},
        }),
      );

      if (paymentResponse.statusCode != 200) {
        throw Exception('Failed to process COD payment');
      }

      // Finalize checkout
      final finalizeResponse = await http.post(
        Uri.parse(BASE_URL +
            FINALIZE_CHECKOUT_ENDPOINT.replaceFirst(':id', checkoutId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.user?.token ?? ''}',
        },
      );

      if (finalizeResponse.statusCode != 201) {
        throw Exception('Failed to finalize checkout');
      }

      if (!mounted) return;

      Navigator.pop(context); // Remove loading dialog

      // Navigate to order confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            checkoutId: checkoutId,
            paymentMethod: 'COD',
            totalAmount: cartService.totalPrice,
          ),
        ),
      );

      cartService.clearCart();
    } catch (e) {
      Navigator.pop(context); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
