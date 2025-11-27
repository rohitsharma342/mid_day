import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: Consumer<UserController>(
        builder: (context, userController, child) {
          final user = userController.user;
          
          if (user == null) {
            return const Center(
              child: Text('Please login to view profile'),
            );
          }

          return SingleChildScrollView(
            padding: AppConstants.defaultPadding,
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildProfileOptions(context, userController),
                const SizedBox(height: 24),
                _buildOrderHistory(context, userController),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppConstants.primaryColor,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.phone,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, UserController userController) {
    return Column(
      children: [
        _buildOptionTile(
          icon: Icons.location_on,
          title: 'Delivery Addresses',
          subtitle: '${userController.user?.addresses.length ?? 0} addresses',
          onTap: () {
            _showAddressesDialog(context, userController);
          },
        ),
        _buildOptionTile(
          icon: Icons.payment,
          title: 'Payment Methods',
          subtitle: '${userController.user?.paymentMethods.length ?? 0} methods',
          onTap: () {
            _showPaymentMethodsDialog(context, userController);
          },
        ),
        _buildOptionTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications settings coming soon!'),
              ),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help & Support coming soon!'),
              ),
            );
          },
        ),
        _buildOptionTile(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            _showAboutDialog(context);
          },
        ),
        _buildOptionTile(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () {
            _showLogoutDialog(context, userController);
          },
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppConstants.primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOrderHistory(BuildContext context, UserController userController) {
    final orders = userController.orders;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...orders.take(3).map((order) => Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status),
                ),
              ),
              title: Text(
                'Order #${order.id.substring(order.id.length - 6)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${order.totalAmount.toStringAsFixed(0)}'),
                  Text(
                    _getStatusDisplayName(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showOrderDetails(context, order);
              },
            ),
          )),
      ],
    );
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.outForDelivery:
        return Colors.blue;
      case OrderStatus.preparing:
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping;
      case OrderStatus.preparing:
      case OrderStatus.confirmed:
        return Icons.restaurant;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  void _showAddressesDialog(BuildContext context, UserController userController) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delivery Addresses'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userController.user?.addresses.length ?? 0,
            itemBuilder: (context, index) {
              final address = userController.user!.addresses[index];
              return ListTile(
                leading: Icon(
                  address.isDefault ? Icons.home : Icons.location_on,
                  color: AppConstants.primaryColor,
                ),
                title: Text(address.label),
                subtitle: Text('${address.fullAddress}, ${address.city}'),
                trailing: address.isDefault
                    ? const Chip(
                        label: Text('Default'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsDialog(BuildContext context, UserController userController) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Payment Methods'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userController.user?.paymentMethods.length ?? 0,
            itemBuilder: (context, index) {
              final method = userController.user!.paymentMethods[index];
              return ListTile(
                leading: Icon(
                  method.type == 'card' ? Icons.credit_card : Icons.account_balance_wallet,
                  color: AppConstants.primaryColor,
                ),
                title: Text(method.displayName),
                subtitle: Text(method.details),
                trailing: method.isDefault
                    ? const Chip(
                        label: Text('Default'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: AppConstants.tagline,
      children: [
        const SizedBox(height: 16),
        const Text(
          'A traditional tiffin delivery app that brings authentic homestyle meals to your doorstep.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, UserController userController) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              userController.logout();
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                ),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order details screen coming soon!'),
      ),
    );
  }
}