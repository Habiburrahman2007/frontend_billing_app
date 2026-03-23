import '../../domain/entities/product.dart';

class ProductModel extends Product {
  @override
  final String id;
  @override
  final String name;
  @override
  final String barcode;
  @override
  final double price;
  @override
  final int stock;
  @override
  final String? image;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.image,
  }) : super(
          id: id,
          name: name,
          barcode: barcode,
          price: price,
          stock: stock,
          image: image,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      stock: json['stock'] is int ? json['stock'] as int : int.parse(json['stock']?.toString() ?? '0'),
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'stock': stock,
      'image': image,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      stock: product.stock,
      image: product.image,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
      image: image,
    );
  }
}
