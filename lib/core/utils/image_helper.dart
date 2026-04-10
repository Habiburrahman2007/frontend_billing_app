import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';

class ImageHelper {
  ImageHelper._();

  /// Decode raw base64 string, stripping `data:image/...;base64,` prefix if present.
  static Uint8List? tryDecodeBase64(String raw) {
    try {
      String cleaned = raw.replaceAll(RegExp(r'\s+'), '');
      // Strip data URI prefix e.g. "data:image/jpeg;base64,"
      final commaIndex = cleaned.indexOf(',');
      if (commaIndex != -1 && cleaned.startsWith('data:')) {
        cleaned = cleaned.substring(commaIndex + 1);
      }
      return base64Decode(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Build a product image widget from a string that may be:
  /// - A local file path (starts with '/' on iOS/Android, or contains ':\\' on Windows)
  /// - An HTTP/HTTPS URL
  /// - A raw base64 string
  /// - A base64 data URI string (`data:image/...;base64,...`)
  /// - A relative server path (e.g. `/storage/products/...`)
  static Widget buildProductImage(
    String? imageSource, {
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    final fallback = errorWidget ??
        const Icon(Icons.broken_image, color: Colors.grey, size: 40);

    if (imageSource == null || imageSource.isEmpty) return fallback;

    // ── DEBUG: log the first 120 chars so we can see the format ─────────────
    final preview = imageSource.length > 120
        ? '${imageSource.substring(0, 120)}...'
        : imageSource;
    debugPrint('[ImageHelper] image source (${imageSource.length} chars): $preview');

    // ── HTTP/HTTPS URL ───────────────────────────────────────────────────────
    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // ── Local file path ─────────────────────────────────────────────────────
    if (_isLocalFilePath(imageSource)) {
      final file = File(imageSource);
      if (file.existsSync()) {
        return Image.file(file,
            fit: fit, errorBuilder: (_, __, ___) => fallback);
      }
      return fallback;
    }

    // ── Base64 (raw or data URI) ─────────────────────────────────────────────
    final bytes = tryDecodeBase64(imageSource);
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(bytes,
          fit: fit, errorBuilder: (_, __, ___) => fallback);
    }

    // ── Relative server path (e.g. /storage/products/...) ────────────────────
    // As a last resort, try converting it to a full URL via getFullImageUrl
    if (imageSource.startsWith('/storage/') ||
        imageSource.startsWith('storage/') ||
        imageSource.startsWith('products/')) {
      final fullUrl = getFullImageUrl(imageSource);
      if (fullUrl.startsWith('http')) {
        debugPrint('[ImageHelper] converted to URL: $fullUrl');
        return Image.network(
          fullUrl,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
    }

    return fallback;
  }

  /// Check if a string looks like a local file system path
  static bool _isLocalFilePath(String path) {
    // Windows paths: C:\, D:\, etc.
    if (path.contains(':\\')) return true;
    // Android/iOS absolute paths, but NOT server paths like /storage/
    if (path.startsWith('/') &&
        !path.startsWith('/storage/') &&
        !path.startsWith('/products/')) {
      return true;
    }
    return false;
  }
}
