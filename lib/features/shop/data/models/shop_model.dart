import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/shop.dart';

class ShopModel extends Shop {
  @override
  final String name;
  @override
  final String addressLine1;
  @override
  final String addressLine2;
  @override
  final String phoneNumber;
  @override
  final String upiId;
  @override
  final String footerText;
  @override
  final String? logoUrl;

  const ShopModel({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.upiId,
    required this.footerText,
    this.logoUrl,
  }) : super(
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          upiId: upiId,
          footerText: footerText,
          logoUrl: logoUrl,
        );

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    final logo = json['logo_url'] as String?;
    return ShopModel(
      name: json['name'] as String? ?? '',
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      upiId: json['upi_id'] as String? ?? '',
      footerText: json['footer_text'] as String? ?? '',
      logoUrl: (logo != null && logo.isNotEmpty) ? getFullImageUrl(logo) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'phone_number': phoneNumber,
      'upi_id': upiId,
      'footer_text': footerText,
      if (logoUrl != null) 'logo_url': logoUrl,
    };
  }

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
      logoUrl: shop.logoUrl,
    );
  }

  Shop toEntity() => this;
}
