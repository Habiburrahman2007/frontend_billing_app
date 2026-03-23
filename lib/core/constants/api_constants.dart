const String kBaseUrl = 'https://billing-app.vibedev.my.id/api';

String getFullImageUrl(String path) {
  if (path.isEmpty) return '';
  
  final baseUrl = kBaseUrl.replaceAll('/api', '');

  // If the path is already a full URL, we should check if it's the "ghost" domain from local dev
  if (path.startsWith('http')) {
    if (path.contains('billing-app.test')) {
      return path.replaceAll('http://billing-app.test', baseUrl);
    }
    return path;
  }
  
  if (path.startsWith('/')) {
    return '$baseUrl$path';
  }
  return '$baseUrl/$path';
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
