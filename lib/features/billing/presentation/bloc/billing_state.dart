part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final bool isCheckoutLoading;
  final bool checkoutSuccess;
  final String printerMacAddress;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.isCheckoutLoading = false,
    this.checkoutSuccess = false,
    this.printerMacAddress = '',
  });

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    bool? isCheckoutLoading,
    bool? checkoutSuccess,
    String? printerMacAddress,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      isCheckoutLoading: isCheckoutLoading ?? this.isCheckoutLoading,
      checkoutSuccess: checkoutSuccess ?? this.checkoutSuccess,
      printerMacAddress: printerMacAddress ?? this.printerMacAddress,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        error,
        isPrinting,
        printSuccess,
        isCheckoutLoading,
        checkoutSuccess,
        printerMacAddress,
      ];
}
