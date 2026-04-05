import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

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
  static Widget buildProductImage(
    String? imageSource, {
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    final fallback = errorWidget ??
        const Icon(Icons.broken_image, color: Colors.grey, size: 40);

    if (imageSource == null || imageSource.isEmpty) return fallback;

    // ── DEBUG: log the first 100 chars so we can see the format ─────────────
    debugPrint('[ImageHelper] image prefix: ${imageSource.substring(0, imageSource.length.clamp(0, 100))}');

    // ── Local file path ─────────────────────────────────────────────────────
    if (imageSource.startsWith('/') || imageSource.contains(':\\')) {
      final file = File(imageSource);
      if (file.existsSync()) {
        return Image.file(file, fit: fit,
            errorBuilder: (_, __, ___) => fallback);
      }
      return fallback;
    }

    // ── HTTP/HTTPS URL ───────────────────────────────────────────────────────
    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // ── Base64 (raw or data URI) ─────────────────────────────────────────────
    final bytes = tryDecodeBase64(imageSource);
    if (bytes != null) {
      return Image.memory(bytes, fit: fit,
          errorBuilder: (_, __, ___) => fallback);
    }

    return fallback;
  }
}
