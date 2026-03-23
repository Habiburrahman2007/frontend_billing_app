import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/product_usecases.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/create_transaction.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final CreateTransaction? _createTransaction;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    CreateTransaction? createTransaction,
  })  : _createTransaction = createTransaction,
        super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<CheckoutCart>(_onCheckoutCart);
    on<LoadPrinterSettings>(_onLoadPrinterSettings);
    on<SetPrinterMacAddress>(_onSetPrinterMacAddress);
  }

  Future<void> _onLoadPrinterSettings(
    LoadPrinterSettings event,
    Emitter<BillingState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mac = prefs.getString('printer_mac') ?? '';
      debugPrint('Loaded printer MAC address: $mac');
      emit(state.copyWith(printerMacAddress: mac));
    } catch (e) {
      debugPrint('Failed to load printer settings: $e');
    }
  }

  Future<void> _onSetPrinterMacAddress(
    SetPrinterMacAddress event,
    Emitter<BillingState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('printer_mac', event.macAddress);
      debugPrint('Saved printer MAC address: ${event.macAddress}');
      emit(state.copyWith(printerMacAddress: event.macAddress));
    } catch (e) {
      debugPrint('Failed to save printer MAC address: $e');
    }
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) =>
          emit(state.copyWith(error: 'Product not found: ${event.barcode}')),
      (product) {
        add(AddProductToCartEvent(product));
      },
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    // Clear error when adding
    final cleanState = state.copyWith(clearError: true);

    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      if (existingItem.quantity < existingItem.product.stock) {
        final backendItems = List<CartItem>.from(cleanState.cartItems);
        backendItems[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
        emit(cleanState.copyWith(cartItems: backendItems, clearError: true));
      } else {
        emit(cleanState.copyWith(error: 'Not enough stock available'));
      }
    } else {
      if (event.product.stock > 0) {
        final newItem = CartItem(product: event.product);
        emit(cleanState.copyWith(cartItems: [...cleanState.cartItems, newItem], clearError: true));
      } else {
        emit(cleanState.copyWith(error: 'Product is out of stock'));
      }
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final item = state.cartItems[index];
      if (event.quantity <= item.product.stock) {
        final items = List<CartItem>.from(state.cartItems);
        items[index] = items[index].copyWith(quantity: event.quantity);
        emit(state.copyWith(cartItems: items));
      } else {
        emit(state.copyWith(error: 'Not enough stock available'));
      }
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(cartItems: [], clearError: true, checkoutSuccess: false));
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = state.printerMacAddress;
      if (savedMac.isNotEmpty) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(error: 'Failed to auto-connect to printer!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(error: 'Printer not connected inside Settings!', clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(isPrinting: true, clearError: true));
    try {
      await printerHelper.printReceipt(
        shopName: event.shopName,
        address1: event.address1,
        address2: event.address2,
        phone: event.phone,
        items: state.cartItems.map((item) => {
          'name': item.product.name,
          'qty': item.quantity,
          'price': item.product.price,
          'total': item.total,
        }).toList(),
        total: state.totalAmount,
        footer: event.footerText,
      );
      emit(state.copyWith(isPrinting: false, printSuccess: true));
      emit(state.copyWith(printSuccess: false));
    } catch (e) {
      emit(state.copyWith(isPrinting: false, error: 'Failed to print: $e'));
      emit(state.copyWith(clearError: true));
    }
  }

  Future<void> _onCheckoutCart(
    CheckoutCart event,
    Emitter<BillingState> emit,
  ) async {
    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(isCheckoutLoading: true, clearError: true, checkoutSuccess: false));
    
    try {
      final transactionItems = state.cartItems.map((item) => TransactionItem(
        productId: item.product.id,
        productName: item.product.name,
        productPrice: item.product.price,
        quantity: item.quantity,
        subtotal: item.total,
      )).toList();

      final transaction = Transaction(
        totalAmount: state.totalAmount,
        items: transactionItems,
        note: event.note,
      );

      if (_createTransaction != null) {
        final result = await _createTransaction!(transaction);
        result.fold(
          (failure) => emit(state.copyWith(
            isCheckoutLoading: false, 
            error: failure.message
          )),
          (_) {
            emit(state.copyWith(
              isCheckoutLoading: false,
              checkoutSuccess: true,
            ));
          }
        );
      } else {
        // Fallback if no use case injected
        emit(state.copyWith(
          isCheckoutLoading: false,
          checkoutSuccess: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isCheckoutLoading: false,
        error: e.toString()
      ));
    }
  }
}
