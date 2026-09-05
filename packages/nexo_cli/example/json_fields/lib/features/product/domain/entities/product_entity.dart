class ProductEntity {
  const ProductEntity({
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
}
