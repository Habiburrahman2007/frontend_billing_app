import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String upiId;
  final String footerText;
  final String? logoUrl;

  const Shop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
    this.logoUrl,
  });

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? upiId,
    String? footerText,
    String? logoUrl,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      footerText: footerText ?? this.footerText,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  List<Object?> get props =>
      [name, addressLine1, addressLine2, phoneNumber, upiId, footerText, logoUrl];
}
