import 'dart:convert';
import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../services/shop_service.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopService _shopService;

  ShopRepositoryImpl({ShopService? shopService})
      : _shopService = shopService ?? ShopService();

  @override
  Future<Either<Failure, Shop>> getShop() async {
    try {
      final shop = await _shopService.getShop();
      return Right(shop.toEntity());
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        // Return default shop if not found on server
        return const Right(Shop(
            name: 'Dinesh Shop',
            addressLine1: 'Samrajpet, Mecheri',
            addressLine2: 'Salem - 636453',
            phoneNumber: '+917010674588',
            upiId: 'dineshsowndar@oksbi',
            footerText: 'Thank you, Visit again!!!'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    try {
      String? logoUrl = shop.logoUrl;
      
      // If it's a new base64 image (doesn't start with http), upload it first
      if (logoUrl != null && logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
        final Uint8List bytes = base64Decode(logoUrl);
        logoUrl = await _shopService.uploadLogo(bytes);
      }

      final model = ShopModel(
        name: shop.name,
        addressLine1: shop.addressLine1,
        addressLine2: shop.addressLine2,
        phoneNumber: shop.phoneNumber,
        upiId: shop.upiId,
        footerText: shop.footerText,
        logoUrl: logoUrl,
      );
      await _shopService.upsertShop(model);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
