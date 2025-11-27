import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/tiffin.dart';

class CartController extends ChangeNotifier {
  final Cart _cart = Cart(items: []);

  Cart get cart => _cart;
  List<CartItem> get items => _cart.items;
  double get totalAmount => _cart.totalAmount;
  int get itemCount => _cart.itemCount;
  bool get isEmpty => _cart.isEmpty;

  void addToCart(Tiffin tiffin, {int quantity = 1}) {
    _cart.addItem(tiffin, quantity: quantity);
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _cart.removeItem(itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    _cart.updateQuantity(itemId, quantity);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  CartItem? getItem(String tiffinId) {
    try {
      return _cart.items.firstWhere((item) => item.tiffin.id == tiffinId);
    } catch (e) {
      return null;
    }
  }

  int getQuantity(String tiffinId) {
    final item = getItem(tiffinId);
    return item?.quantity ?? 0;
  }

  bool hasItem(String tiffinId) {
    return getItem(tiffinId) != null;
  }
}