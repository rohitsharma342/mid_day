class Tiffin {
  final String id;
  final String name;
  final String description;
  final double price;
  final String metalType;
  final List<String> images;
  final bool isTrending;
  final String category;
  final double rating;
  final int reviewCount;

  Tiffin({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.metalType,
    required this.images,
    this.isTrending = false,
    required this.category,
    this.rating = 4.0,
    this.reviewCount = 0,
  });

  factory Tiffin.fromJson(Map<String, dynamic> json) {
    return Tiffin(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      metalType: json['metalType'],
      images: List<String>.from(json['images']),
      isTrending: json['isTrending'] ?? false,
      category: json['category'],
      rating: json['rating']?.toDouble() ?? 4.0,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'metalType': metalType,
      'images': images,
      'isTrending': isTrending,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}