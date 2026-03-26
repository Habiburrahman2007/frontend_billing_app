import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../features/product/data/models/product_model.dart';
import '../core/constants/api_constants.dart';

import 'api_client.dart';

class ProductService {
  ProductService._();
  static final ProductService _instance = ProductService._();
  factory ProductService() => _instance;

  final _dio = ApiClient().dio;

  Future<String?> _toBase64(String? path) async {
    if (path == null || path.isEmpty) return null;

    // If it already looks like base64 (no path separators), return as-is
    if (!path.contains('/') && !path.contains('\\')) return path;

    try {
      final bytes = await File(path).readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      // Path unreadable (e.g. stale cached path or URL), skip image
      return null;
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get(kProductsEndpoint);
      final responseData = response.data;
      final List<dynamic> data = responseData is Map && responseData.containsKey('data')
          ? responseData['data']
          : responseData;
      return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
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
      throw ApiClient.toApiException(e);
    }
  }

  Future<ProductModel> updateProduct(String id, ProductModel product) async {

    try {
      final base64Image = await _toBase64(product.image);
      // Use POST with _method spoofing for better compatibility on mobile/some servers
      final data = product.toJson();
      data['image'] = base64Image;
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
