import 'tiffin.dart';

class CartItem {
  final String id;
  final Tiffin tiffin;
  int quantity;

  CartItem({
    required this.id,
    required this.tiffin,
    this.quantity = 1,
  });

  double get totalPrice => tiffin.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      tiffin: Tiffin.fromJson(json['tiffin']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tiffin': tiffin.toJson(),
      'quantity': quantity,
    };
  }
}

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => items.isEmpty;

  void addItem(Tiffin tiffin, {int quantity = 1}) {
    final existingItemIndex = items.indexWhere((item) => item.tiffin.id == tiffin.id);
    
    if (existingItemIndex >= 0) {
      items[existingItemIndex].quantity += quantity;
    } else {
      items.add(CartItem(
        id: '${tiffin.id}_${DateTime.now().millisecondsSinceEpoch}',
        tiffin: tiffin,
        quantity: quantity,
      ));
    }
  }

  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  void updateQuantity(String itemId, int quantity) {
    final itemIndex = items.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        removeItem(itemId);
      } else {
        items[itemIndex].quantity = quantity;
      }
    }
  }

  void clear() {
    items.clear();
  }
}