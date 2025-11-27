import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../services/data_service.dart';

class UserController extends ChangeNotifier {
  User? _user;
  List<Order> _orders = [];
  bool _isLoggedIn = false;

  User? get user => _user;
  List<Order> get orders => _orders;
  bool get isLoggedIn => _isLoggedIn;

  UserController() {
    _initializeUser();
  }

  void _initializeUser() {
    _user = DataService.getSampleUser();
    _orders = DataService.getSampleOrders();
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateUser({
    String? name,
    String? email,
    String? phone,
  }) {
    if (_user != null) {
      if (name != null) _user!.name = name;
      if (email != null) _user!.email = email;
      if (phone != null) _user!.phone = phone;
      notifyListeners();
    }
  }

  void addAddress(DeliveryAddress address) {
    if (_user != null) {
      _user!.addresses.add(address);
      notifyListeners();
    }
  }

  void updateAddress(String addressId, DeliveryAddress updatedAddress) {
    if (_user != null) {
      final index = _user!.addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        _user!.addresses[index] = updatedAddress;
        notifyListeners();
      }
    }
  }

  void removeAddress(String addressId) {
    if (_user != null) {
      _user!.addresses.removeWhere((addr) => addr.id == addressId);
      notifyListeners();
    }
  }

  void setDefaultAddress(String addressId) {
    if (_user != null) {
      for (var address in _user!.addresses) {
        address.isDefault = address.id == addressId;
      }
      notifyListeners();
    }
  }

  void addPaymentMethod(PaymentMethod method) {
    if (_user != null) {
      _user!.paymentMethods.add(method);
      notifyListeners();
    }
  }

  void updatePaymentMethod(String methodId, PaymentMethod updatedMethod) {
    if (_user != null) {
      final index = _user!.paymentMethods.indexWhere((method) => method.id == methodId);
      if (index != -1) {
        _user!.paymentMethods[index] = updatedMethod;
        notifyListeners();
      }
    }
  }

  void removePaymentMethod(String methodId) {
    if (_user != null) {
      _user!.paymentMethods.removeWhere((method) => method.id == methodId);
      notifyListeners();
    }
  }

  void setDefaultPaymentMethod(String methodId) {
    if (_user != null) {
      for (var method in _user!.paymentMethods) {
        method.isDefault = method.id == methodId;
      }
      notifyListeners();
    }
  }

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = _orders[orderIndex];
      final updatedOrder = Order(
        id: order.id,
        items: order.items,
        totalAmount: order.totalAmount,
        status: status,
        orderDate: order.orderDate,
        deliveryAddress: order.deliveryAddress,
        paymentMethod: order.paymentMethod,
        estimatedDelivery: order.estimatedDelivery,
      );
      _orders[orderIndex] = updatedOrder;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _orders.clear();
    _isLoggedIn = false;
    notifyListeners();
  }
}