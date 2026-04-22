const String kBaseUrl = 'https://billing-app.vibedev.my.id/api';

String getFullImageUrl(String path) {
  if (path.isEmpty || path == 'null') return '';

  // 1. If it's already a full URL
  if (path.startsWith('http')) {
    final baseUrl = kBaseUrl.replaceAll('/api', '');
    // Fix common dev environment domain mismatch
    if (path.contains('billing-app.test')) {
      return path.replaceAll('http://billing-app.test', baseUrl);
    }
    return path;
  }

  // 2. If it's a base64 string (either raw or data URI)
  if (path.startsWith('data:image') || _isLikelyBase64(path)) {
    return path;
  }

  // 3. Handle relative paths
  final baseUrl = kBaseUrl.replaceAll('/api', '');

  // Ensure path starts with /storage/ if it's a relative path to a product or logo
  String cleanPath = path;
  
  // If it's just a filename (no directory), assume it's in storage/products/
  if (!cleanPath.contains('/')) {
    cleanPath = 'storage/products/$cleanPath';
  }
  // If it's a path but missing 'storage/' prefix
  else if (!cleanPath.startsWith('http') &&
      !cleanPath.startsWith('data:') &&
      !cleanPath.startsWith('storage/') &&
      !cleanPath.startsWith('/storage/')) {
    
    // If it starts with products/, prepend storage/
    if (cleanPath.startsWith('products/') || cleanPath.startsWith('/products/')) {
      if (cleanPath.startsWith('/')) {
        cleanPath = 'storage$cleanPath';
      } else {
        cleanPath = 'storage/$cleanPath';
      }
    } 
    // Otherwise, just prepend storage/
    else {
      if (cleanPath.startsWith('/')) {
        cleanPath = 'storage$cleanPath';
      } else {
        cleanPath = 'storage/$cleanPath';
      }
    }
  }

  // Final join with base URL
  String fullUrl;
  if (cleanPath.startsWith('/')) {
    fullUrl = '$baseUrl$cleanPath';
  } else {
    fullUrl = '$baseUrl/$cleanPath';
  }

  // Remove potential double slashes (except after http: or https:)
  final protocolIndex = fullUrl.indexOf('://');
  if (protocolIndex != -1) {
    final protocol = fullUrl.substring(0, protocolIndex + 3);
    final rest = fullUrl.substring(protocolIndex + 3);
    return '$protocol${rest.replaceAll('//', '/')}';
  }
  
  return fullUrl.replaceAll('//', '/');
}

/// Heuristic check: is this string likely a raw base64-encoded image?
/// Base64 uses [A-Za-z0-9+/=] and can contain '/' (e.g. JPEG starts with /9j/).
bool _isLikelyBase64(String value) {
  if (value.length < 50) return false;
  // Common base64 image prefixes (raw, without data URI)
  if (value.startsWith('/9j/')) return true; // JPEG
  if (value.startsWith('iVBOR')) return true; // PNG
  if (value.startsWith('R0lGOD')) return true; // GIF
  if (value.startsWith('UklGR')) return true; // WEBP
  // General heuristic: if it's long and only contains base64 chars
  final base64Regex = RegExp(r'^[A-Za-z0-9+/=\s]+$');
  return base64Regex.hasMatch(value);
}

// Auth
const String kLoginEndpoint = '/login';
const String kRegisterEndpoint = '/register';
const String kLogoutEndpoint = '/logout';
const String kMeEndpoint = '/me';

// Shop
const String kShopEndpoint = '/shop';
const String kShopLogoEndpoint = '/shop/logo';

// Products
const String kProductsEndpoint = '/products';
// GET /products/barcode/{barcode}  — constructed dynamically

// Transactions
const String kTransactionsEndpoint = '/transactions';
