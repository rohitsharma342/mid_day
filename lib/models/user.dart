class User {
  final String id;
  String name;
  String email;
  String phone;
  List<DeliveryAddress> addresses;
  List<PaymentMethod> paymentMethods;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.addresses = const [],
    this.paymentMethods = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((address) => DeliveryAddress.fromJson(address))
          .toList() ?? [],
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((method) => PaymentMethod.fromJson(method))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'paymentMethods': paymentMethods.map((method) => method.toJson()).toList(),
    };
  }
}

class DeliveryAddress {
  final String id;
  String label;
  String fullAddress;
  String city;
  String state;
  String pincode;
  bool isDefault;

  DeliveryAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'],
      label: json['label'],
      fullAddress: json['fullAddress'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }
}

class PaymentMethod {
  final String id;
  String type; // 'card', 'upi', 'netbanking'
  String displayName;
  String details;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.details,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      displayName: json['displayName'],
      details: json['details'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'displayName': displayName,
      'details': details,
      'isDefault': isDefault,
    };
  }
}