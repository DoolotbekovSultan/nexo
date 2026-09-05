class ProductsModel {
  const ProductsModel({required this.id});
  final String id;

  factory ProductsModel.fromJson(Map<String, dynamic> json) {
    return ProductsModel(id: json['id'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
