import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    final user = Provider.of<UserController>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppConstants.primaryColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Addresses'),
            Tab(text: 'Payments'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildAddressesTab(),
          _buildPaymentsTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final user = userController.user;
        if (user == null) return const Center(child: Text('No user data'));

        return SingleChildScrollView(
          padding: AppConstants.defaultPadding,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: _isEditing,
                  validator: (value) => Validators.validateRequired(value, 'Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  enabled: _isEditing,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  enabled: _isEditing,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isEditing ? _saveProfile : _enableEditing,
                        child: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelEditing,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressesTab() {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final addresses = userController.user?.addresses ?? [];

        return Column(
          children: [
            Expanded(
              child: addresses.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.location_on,
                      title: 'No delivery addresses',
                      subtitle: 'Add your delivery address for quick checkout',
                    )
                  : ListView.builder(
                      padding: AppConstants.defaultPadding,
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: address.isDefault
                                  ? AppConstants.primaryColor
                                  : Colors.grey[300],
                              child: Icon(
                                Icons.location_on,
                                color: address.isDefault ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              address.label,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${address.fullAddress}\n${address.city}, ${address.state} - ${address.pincode}',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'default':
                                    userController.setDefaultAddress(address.id);
                                    break;
                                  case 'edit':
                                    _showAddressDialog(userController, address: address);
                                    break;
                                  case 'delete':
                                    _showDeleteConfirmation(
                                      context,
                                      'Delete Address',
                                      'Are you sure you want to delete this address?',
                                      () => userController.removeAddress(address.id),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                if (!address.isDefault)
                                  const PopupMenuItem(
                                    value: 'default',
                                    child: Text('Set as Default'),
                                  ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: AppConstants.defaultPadding,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddressDialog(userController),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final paymentMethods = userController.user?.paymentMethods ?? [];

        return Column(
          children: [
            Expanded(
              child: paymentMethods.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.payment,
                      title: 'No payment methods',
                      subtitle: 'Add a payment method for quick checkout',
                    )
                  : ListView.builder(
                      padding: AppConstants.defaultPadding,
                      itemCount: paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = paymentMethods[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: method.isDefault
                                  ? AppConstants.primaryColor
                                  : Colors.grey[300],
                              child: Icon(
                                _getPaymentIcon(method.type),
                                color: method.isDefault ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              method.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(method.details),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'default':
                                    userController.setDefaultPaymentMethod(method.id);
                                    break;
                                  case 'edit':
                                    _showPaymentDialog(userController, method: method);
                                    break;
                                  case 'delete':
                                    _showDeleteConfirmation(
                                      context,
                                      'Delete Payment Method',
                                      'Are you sure you want to delete this payment method?',
                                      () => userController.removePaymentMethod(method.id),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                if (!method.isDefault)
                                  const PopupMenuItem(
                                    value: 'default',
                                    child: Text('Set as Default'),
                                  ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: AppConstants.defaultPadding,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(userController),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payment Method'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final orders = userController.orders;

        if (orders.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long,
            title: 'No orders yet',
            subtitle: 'Your order history will appear here',
          );
        }

        return ListView.builder(
          padding: AppConstants.defaultPadding,
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.substring(order.id.length - 6)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status.displayName,
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order.items.length} item${order.items.length > 1 ? 's' : ''} • ₹${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ordered on ${_formatDate(order.orderDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showOrderDetails(order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConstants.primaryColor,
                              side: BorderSide(color: AppConstants.primaryColor),
                            ),
                            child: const Text('View Details'),
                          ),
                        ),
                        if (order.status == OrderStatus.pending) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Cancel order functionality
                                userController.updateOrderStatus(order.id, OrderStatus.cancelled);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: AppConstants.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _enableEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    final user = Provider.of<UserController>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userController = Provider.of<UserController>(context, listen: false);
      userController.updateUser(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<UserController>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddressDialog(UserController userController, {DeliveryAddress? address}) {
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController(text: address?.label ?? '');
    final addressController = TextEditingController(text: address?.fullAddress ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final stateController = TextEditingController(text: address?.state ?? '');
    final pincodeController = TextEditingController(text: address?.pincode ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(address == null ? 'Add Address' : 'Edit Address'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Label (Home, Office, etc.)'),
                    validator: (value) => Validators.validateRequired(value, 'Label'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Full Address'),
                    validator: (value) => Validators.validateRequired(value, 'Address'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (value) => Validators.validateRequired(value, 'City'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: stateController,
                          decoration: const InputDecoration(labelText: 'State'),
                          validator: (value) => Validators.validateRequired(value, 'State'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: pincodeController,
                    decoration: const InputDecoration(labelText: 'Pincode'),
                    validator: (value) => Validators.validateRequired(value, 'Pincode'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newAddress = DeliveryAddress(
                    id: address?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
                    label: labelController.text,
                    fullAddress: addressController.text,
                    city: cityController.text,
                    state: stateController.text,
                    pincode: pincodeController.text,
                    isDefault: address?.isDefault ?? false,
                  );

                  if (address == null) {
                    userController.addAddress(newAddress);
                  } else {
                    userController.updateAddress(address.id, newAddress);
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(UserController userController, {PaymentMethod? method}) {
    final formKey = GlobalKey<FormState>();
    final displayNameController = TextEditingController(text: method?.displayName ?? '');
    final detailsController = TextEditingController(text: method?.details ?? '');
    String selectedType = method?.type ?? 'card';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(method == null ? 'Add Payment Method' : 'Edit Payment Method'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Payment Type'),
                      items: const [
                        DropdownMenuItem(value: 'card', child: Text('Credit/Debit Card')),
                        DropdownMenuItem(value: 'upi', child: Text('UPI')),
                        DropdownMenuItem(value: 'netbanking', child: Text('Net Banking')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: displayNameController,
                      decoration: const InputDecoration(labelText: 'Display Name'),
                      validator: (value) => Validators.validateRequired(value, 'Display Name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: detailsController,
                      decoration: InputDecoration(
                        labelText: selectedType == 'card'
                            ? 'Card Number (last 4 digits)'
                            : selectedType == 'upi'
                                ? 'UPI ID'
                                : 'Bank Account Details',
                      ),
                      validator: (value) => Validators.validateRequired(value, 'Details'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newMethod = PaymentMethod(
                        id: method?.id ?? 'pay_${DateTime.now().millisecondsSinceEpoch}',
                        type: selectedType,
                        displayName: displayNameController.text,
                        details: detailsController.text,
                        isDefault: method?.isDefault ?? false,
                      );

                      if (method == null) {
                        userController.addPaymentMethod(newMethod);
                      } else {
                        userController.updatePaymentMethod(method.id, newMethod);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order #${order.id.substring(order.id.length - 6)}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Status: ${order.status.displayName}'),
                const SizedBox(height: 8),
                Text('Order Date: ${_formatDate(order.orderDate)}'),
                const SizedBox(height: 8),
                Text('Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.tiffin.name} x ${item.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '₹${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.account_balance_wallet;
      case 'netbanking':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.outForDelivery:
        return AppConstants.primaryColor;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}