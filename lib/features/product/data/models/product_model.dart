import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
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
    // Try both 'image' and 'image_url' fields
    final rawImage = json['image'] as String? ?? json['image_url'] as String?;
    
    // Handle "null" string from some APIs
    final image = (rawImage == 'null') ? null : rawImage;

    final preview = (image != null && image.length > 100)
        ? '${image.substring(0, 100)}... [total ${image.length} chars]'
        : image;
    debugPrint('[ProductModel.fromJson] raw image from server: $preview');

    final resolvedImage =
        (image != null && image.isNotEmpty) ? getFullImageUrl(image) : null;
    debugPrint('[ProductModel.fromJson] resolved image: $resolvedImage');

    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.parse(json['stock']?.toString() ?? '0'),
      image: resolvedImage,
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
