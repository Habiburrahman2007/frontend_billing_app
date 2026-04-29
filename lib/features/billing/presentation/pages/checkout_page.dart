import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../widgets/invoice_widget.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _shouldPrint = true;
  final TextEditingController _cashController = TextEditingController();
  double _cashReceived = 0;

  @override
  void initState() {
    super.initState();
    _cashController.addListener(() {
      setState(() {
        _cashReceived = double.tryParse(_cashController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          context.read<BillingBloc>().add(ClearCartEvent());
          context.go('/');
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left,
                  size: 28, color: Theme.of(context).primaryColor),
              onPressed: () {
                context.read<BillingBloc>().add(ClearCartEvent());
                context.go('/');
              },
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.checkoutSuccess && !state.isPrinting && !state.printSuccess) {
                if (_shouldPrint) {
                  final shopState = context.read<ShopBloc>().state;
                  if (shopState is ShopLoaded) {
                    context.read<BillingBloc>().add(
                        PrintReceiptEvent(
                            shopName: shopState.shop.name,
                            address1: shopState.shop.addressLine1,
                            address2: shopState.shop.addressLine2,
                            phone: shopState.shop.phoneNumber,
                            upiId: shopState.shop.upiId,
                            footerText: shopState.shop.footerText));
                  } else {
                    context.read<BillingBloc>().add(ClearCartEvent());
                    context.go('/');
                  }
                } else {
                  // If printing is disabled, just finish up
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Checkout Successful'),
                      backgroundColor: Colors.green));
                  context.read<BillingBloc>().add(ClearCartEvent());
                  context.go('/');
                }
              }
              if (state.printSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Checkout & Print Successful'),
                    backgroundColor: Colors.green));
                context.read<BillingBloc>().add(ClearCartEvent());
                context.go('/');
              }
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red));
                if (state.checkoutSuccess) {
                    // if checkout succeeded but printing failed, clear and go home anyway
                    context.read<BillingBloc>().add(ClearCartEvent());
                    context.go('/');
                }
              }
            },
            builder: (context, billingState) {
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                String upiId = '';
                String shopName = 'Shop';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            // Table
                            // Invoice Preview
                            InvoiceWidget(
                              shopName: shopName,
                              address1: shopState is ShopLoaded ? shopState.shop.addressLine1 : '',
                              address2: shopState is ShopLoaded ? shopState.shop.addressLine2 : '',
                              phone: shopState is ShopLoaded ? shopState.shop.phoneNumber : '',
                              date: DateTime.now(),
                              items: billingState.cartItems.map((item) => InvoiceItemData(
                                name: item.product.name,
                                quantity: item.quantity,
                                price: item.product.price,
                                subtotal: item.total,
                              )).toList(),
                              totalAmount: billingState.totalAmount,
                              footerText: shopState is ShopLoaded ? shopState.shop.footerText : '',
                              cashReceived: _cashReceived,
                              change: _cashReceived > billingState.totalAmount ? _cashReceived - billingState.totalAmount : 0,
                            ),
                            const SizedBox(height: 120), // padding for bottom fixed bar
                          ],
                        ),
                      ),
                    ),

                    // Bottom Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24),
                            right: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                const SizedBox(height: 15),
                                
                                // Print Toggle
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _shouldPrint 
                                      ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                                      : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _shouldPrint 
                                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                        : Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.print_rounded,
                                            size: 20,
                                            color: _shouldPrint ? Theme.of(context).primaryColor : Colors.grey,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Cetak Struk',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _shouldPrint ? Colors.black87 : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Switch(
                                        value: _shouldPrint,
                                        onChanged: (value) {
                                          setState(() {
                                            _shouldPrint = value;
                                          });
                                        },
                                        activeColor: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'GRAND TOTAL',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[400],
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(billingState.totalAmount),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Cash Input
                                  TextField(
                                    controller: _cashController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Uang Diterima (Tunai)',
                                      prefixText: 'Rp ',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                  if (_cashReceived > billingState.totalAmount) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Kembalian:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                                        Text(
                                          CurrencyFormatter.format(_cashReceived - billingState.totalAmount),
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          PrimaryButton(
                            onPressed: () {
                              if (shopState is ShopLoaded) {
                                context.read<BillingBloc>().add(const CheckoutCart());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Shop details not loaded'),
                                        backgroundColor: Colors.red));
                              }
                            },
                            label: _shouldPrint ? 'Checkout & Print' : 'Selesaikan Pembayaran',
                            icon: _shouldPrint ? Icons.print : Icons.check_circle,
                            isLoading: billingState.isCheckoutLoading || (billingState.isPrinting && _shouldPrint),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ));
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }
}
