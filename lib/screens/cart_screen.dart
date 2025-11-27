import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../controllers/user_controller.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          Consumer<CartController>(
            builder: (context, cartController, child) {
              if (cartController.isEmpty) return const SizedBox();
              return TextButton(
                onPressed: () {
                  _showClearCartDialog(context, cartController);
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartController>(
        builder: (context, cartController, child) {
          if (cartController.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: AppConstants.defaultPadding,
                  itemCount: cartController.items.length,
                  itemBuilder: (context, index) {
                    final item = cartController.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CartItemWidget(
                        item: item,
                        onQuantityChanged: (quantity) {
                          cartController.updateQuantity(item.id, quantity);
                        },
                        onRemove: () {
                          cartController.removeFromCart(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.tiffin.name} removed from cart'),
                              backgroundColor: Colors.red[600],
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _buildCartSummary(context, cartController),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious tiffins to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Browse Tiffins'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartController cartController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items (${cartController.itemCount})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${cartController.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Fee',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                cartController.totalAmount >= 200 ? 'FREE' : '₹30',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cartController.totalAmount >= 200 
                      ? AppConstants.primaryColor 
                      : Colors.black,
                ),
              ),
            ],
          ),
          if (cartController.totalAmount < 200) ..[
            const SizedBox(height: 4),
            Text(
              'Add ₹${(200 - cartController.totalAmount).toStringAsFixed(0)} more for free delivery',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${_calculateTotal(cartController.totalAmount).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _proceedToCheckout(context, cartController);
              },
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(double subtotal) {
    double deliveryFee = subtotal >= 200 ? 0 : 30;
    return subtotal + deliveryFee;
  }

  void _showClearCartDialog(BuildContext context, CartController cartController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cartController.clearCart();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart cleared'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout(BuildContext context, CartController cartController) {
    final userController = Provider.of<UserController>(context, listen: false);
    
    if (!userController.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to proceed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create order
    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(cartController.items),
      totalAmount: _calculateTotal(cartController.totalAmount),
      status: OrderStatus.pending,
      orderDate: DateTime.now(),
      deliveryAddress: userController.user!.addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => userController.user!.addresses.first,
      ),
      paymentMethod: userController.user!.paymentMethods.firstWhere(
        (method) => method.isDefault,
        orElse: () => userController.user!.paymentMethods.first,
      ),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 2)),
    );

    userController.addOrder(order);
    cartController.clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppConstants.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Order Placed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${order.id}'),
              const SizedBox(height: 8),
              Text('Total: ₹${order.totalAmount.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              Text('Estimated delivery: ${_formatTime(order.estimatedDelivery!)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}