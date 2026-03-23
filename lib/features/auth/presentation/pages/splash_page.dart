import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay to show logo nicely (optional)
    // Artificial delay to show logo for at least 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    
    final isLoggedIn = await AuthService().isLoggedIn();
    if (mounted) {
      if (isLoggedIn) {
        context.go('/');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE0F7FA)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'lib/images/logo.png',
                width: 150, // Slightly larger
                height: 150,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.calculate, size: 100, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Hitungin',
              style: TextStyle(
                fontSize: 40, // Larger font
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Solusi Kasir Pintar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
