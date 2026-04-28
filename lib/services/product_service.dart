import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/product/data/models/product_model.dart';
import '../core/constants/api_constants.dart';

import 'api_client.dart';

class ProductService {
  ProductService._();
  static final ProductService _instance = ProductService._();
  factory ProductService() => _instance;

  final _dio = ApiClient().dio;

  Future<String?> _toBase64(String? path) async {
    if (path == null || path.isEmpty || path == 'null') return null;

    // If it's a URL, return as-is
    if (path.startsWith('http')) return path;

    // If it's a data URI, return as-is
    if (path.startsWith('data:image')) return path;

    // If it already looks like base64, return as-is.
    if (_looksLikeBase64(path)) {
      // If it's raw base64 without prefix, add it for better server compatibility
      if (!path.startsWith('data:image')) {
        return 'data:image/jpeg;base64,$path';
      }
      return path;
    }

    try {
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('[_toBase64] File does not exist at $path');
        return null;
      }
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('[_toBase64] Failed to read file at $path: $e');
      return null;
    }
  }

  /// Quick heuristic: is [value] likely a raw base64-encoded image?
  bool _looksLikeBase64(String value) {
    if (value.length < 50) return false;
    // Common base64 image prefixes
    if (value.startsWith('/9j/')) return true; // JPEG
    if (value.startsWith('iVBOR')) return true; // PNG
    if (value.startsWith('R0lGOD')) return true; // GIF
    if (value.startsWith('UklGR')) return true; // WEBP
    // General: only base64 characters, no file-system-like structure
    return RegExp(r'^[A-Za-z0-9+/=\s]+$').hasMatch(value);
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get(kProductsEndpoint);
      final responseData = response.data;
      final List<dynamic> data =
          responseData is Map && responseData.containsKey('data')
              ? responseData['data']
              : responseData;
      return data
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _dio.get('$kProductsEndpoint/$id');
      final responseData = response.data;
      final data = responseData is Map && responseData.containsKey('data')
          ? responseData['data']
          : responseData;
      return ProductModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<ProductModel> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get('$kProductsEndpoint/barcode/$barcode');
      final responseData = response.data;
      final data = responseData is Map && responseData.containsKey('data')
          ? responseData['data']
          : responseData;
      return ProductModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final base64Image = await _toBase64(product.image);
      final data = product.toJson();
      
      // Remove ID from payload as server usually generates it
      data.remove('id');
      
      // Log image preview
      final imgPreview = base64Image != null
          ? '${base64Image.substring(0, base64Image.length.clamp(0, 50))}...'
          : 'null';
      debugPrint('[ProductService.create] payload image preview: $imgPreview');
      
      data['image'] = base64Image;

      final response = await _dio.post(
        kProductsEndpoint,
        data: data,
      );
      
      final responseData = response.data;
      final dataResult = responseData is Map && responseData.containsKey('data')
          ? responseData['data']
          : responseData;
          
      return ProductModel.fromJson(dataResult as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ProductService.create] error: ${e.message}');
      throw ApiClient.toApiException(e);
    }
  }

  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    try {
      final imageValue = await _toBase64(product.image);
      final data = product.toJson();

      // If imageValue is a URL, it means the user didn't change the image.
      // We should NOT send the image field at all to avoid confusing the backend.
      if (imageValue != null && imageValue.startsWith('http')) {
        data.remove('image');
        debugPrint('[ProductService.update] image unchanged, removing from payload');
      } else {
        // It's base64 (new image) or null
        data['image'] = imageValue;
      }

      data['_method'] = 'PUT';

      final response = await _dio.post(
        '$kProductsEndpoint/$id',
        data: data,
      );
      
      final responseData = response.data;
      final dataResult = responseData is Map && responseData.containsKey('data')
          ? responseData['data']
          : responseData;
          
      return ProductModel.fromJson(dataResult as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('[ProductService.update] error: ${e.message}');
      throw ApiClient.toApiException(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      // Use POST with _method spoofing for better compatibility
      await _dio.post(
        '$kProductsEndpoint/$id',
        data: {'_method': 'DELETE'},
      );
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
