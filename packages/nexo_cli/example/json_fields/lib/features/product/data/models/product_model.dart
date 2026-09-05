class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    required this.tags,
  });

  final String id;
  final String name;
  final double price;
  final bool isActive;
  final List<dynamic> tags;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
      tags: json['tags'] as List<dynamic>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'isActive': isActive,
      'tags': tags,
    };
  }
}
