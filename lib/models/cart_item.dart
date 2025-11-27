import 'tiffin.dart';

class CartItem {
  final String id;
  final Tiffin tiffin;
  final int quantity;

  CartItem({
    required this.id,
    required this.tiffin,
    required this.quantity,
  });

  double get totalPrice => tiffin.price * quantity;

  CartItem copyWith({
    String? id,
    Tiffin? tiffin,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      tiffin: tiffin ?? this.tiffin,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tiffin': tiffin.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      tiffin: Tiffin.fromJson(json['tiffin'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
}
