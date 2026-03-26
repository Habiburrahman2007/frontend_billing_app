import 'dart:io';
import 'dart:convert';
import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

// ── Formatter: integer with dot thousand-separators (no decimal) ──────────────
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final formatted = _addDots(digits);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addDots(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _price;
  late int _stock;
  File? _imageFile;
  final _picker = ImagePicker();
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _stock = widget.product.stock;

    // Format initial price as dot-separated integer (no decimals)
    final rawPrice = widget.product.price.toInt().toString();
    _priceController = TextEditingController(
      text: _addDots(rawPrice),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String _addDots(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // ── Image picker: show bottom sheet with Gallery / Camera options ──────────
  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Pilih Sumber Gambar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: AppTheme.primaryColor),
                ),
                title: const Text('Pilih dari Galeri'),
                subtitle: const Text('Gunakan foto dari galeri HP'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.teal),
                ),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Ambil foto langsung dengan kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        barcode: widget.product.barcode,
        price: _price,
        stock: _stock,
        image: _imageFile?.path ?? widget.product.image,
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 32, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('Edit Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image Picker ──────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _imageFile != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_imageFile!,
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    bottom: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.edit,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              )
                            : widget.product.image != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: widget.product.image!
                                                    .startsWith('/') ||
                                                widget.product.image!
                                                    .contains(':\\')
                                            ? Image.file(
                                                File(widget.product.image!),
                                                fit: BoxFit.cover)
                                            : Image.memory(
                                                base64Decode(widget.product
                                                    .image!
                                                    .replaceAll(
                                                        RegExp(r'\s+'), '')),
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err,
                                                    stack) =>
                                                  const Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey),
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(Icons.edit,
                                              color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo,
                                          size: 36, color: Colors.grey[500]),
                                      const SizedBox(height: 8),
                                      Text('Tambah Foto',
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Text('Galeri / Kamera',
                                          style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 10)),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Barcode (read-only) ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner,
                            color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BARCODE',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.7))),
                            const SizedBox(height: 2),
                            Text(widget.product.barcode,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Product Name ──────────────────────────────────────────
                  const InputLabel(text: 'Product Name'),
                  TextFormField(
                    initialValue: _name,
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Please enter a name'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),

                  // ── Price (integer, dot-separated thousands) ──────────────
                  const InputLabel(text: 'Price'),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandSeparatorFormatter()],
                    decoration: const InputDecoration(
                      prefixText: 'Rp ',
                    ),
                    validator: AppValidators.price,
                    onSaved: (value) {
                      final cleaned =
                          (value ?? '').replaceAll('.', '');
                      _price = double.tryParse(cleaned) ?? 0;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Stock ─────────────────────────────────────────────────
                  const InputLabel(text: 'Current Stock'),
                  TextFormField(
                    initialValue: _stock.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0',
                    ),
                    validator:
                        AppValidators.required('Please enter stock amount'),
                    onSaved: (value) => _stock = int.parse(value!),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state.status == ProductStatus.success &&
                state.message == 'Product updated successfully') {
              context.pop();
            } else if (state.status == ProductStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text(state.message ?? 'Update failed'),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return PrimaryButton(
              onPressed:
                  state.status == ProductStatus.loading ? null : _submit,
              icon: state.status == ProductStatus.loading
                  ? null
                  : Icons.save,
              label: state.status == ProductStatus.loading
                  ? 'Saving...'
                  : 'Save Changes',
            );
          },
        ));
  }
}
