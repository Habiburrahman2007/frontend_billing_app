import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../core/constants/api_constants.dart';

import 'api_client.dart';

class ShopService {
  ShopService._();
  static final ShopService _instance = ShopService._();
  factory ShopService() => _instance;

  final _dio = ApiClient().dio;

  Future<ShopModel> getShop() async {
    try {
      final response = await _dio.get(kShopEndpoint);
      final data = response.data['data'] ?? response.data;
      return ShopModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      // If 404, we can let it throw or handle it in repo. We'll throw.
      throw ApiClient.toApiException(e);
    }
  }

  Future<ShopModel> upsertShop(ShopModel shop) async {
    try {
      // Assuming POST creates or updates shop details for the authed user.
      final response = await _dio.post(
        kShopEndpoint,
        data: shop.toJson(),
      );
      final data = response.data['data'] ?? response.data;
      return ShopModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }

  Future<String> uploadLogo(Uint8List imageBytes) async {
    try {
      final base64String = 'data:image/png;base64,${base64Encode(imageBytes)}';
      final response = await _dio.post(
        kShopLogoEndpoint,
        data: {'logo': base64String},
      );
      
      final data = response.data['data'] ?? response.data;
      return data['logo_url'] as String;
    } on DioException catch (e) {
      throw ApiClient.toApiException(e);
    }
  }
}
