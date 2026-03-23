import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/error/api_exception.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Map<String, dynamic>? _fieldErrors;
  String? _generalError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _generalError = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _generalError = null;
      _fieldErrors = null;
    });

    try {
      await AuthService().register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (mounted) {
        context.go('/');
      }
    } on ApiException catch (e) {
      setState(() {
        _generalError = e.message;
        _fieldErrors = e.errors;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _generalError = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _getFieldError(String field, String? fallbackError) {
    if (_fieldErrors != null && _fieldErrors![field] != null) {
      final errors = _fieldErrors![field];
      if (errors is List && errors.isNotEmpty) return errors.first.toString();
    }
    return fallbackError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 const Icon(Icons.person_add_alt_1_outlined, size: 64, color: Color(0xFF00BCD4)),
                const SizedBox(height: 32),
                
                if (_generalError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _generalError!,
                      style: TextStyle(color: Colors.red.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const InputLabel(text: 'Full Name'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    errorText: _getFieldError('name', null),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                const InputLabel(text: 'Email'),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    errorText: _getFieldError('email', null),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                const InputLabel(text: 'Password'),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    errorText: _getFieldError('password', null),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                const InputLabel(text: 'Confirm Password'),
                TextFormField(
                  controller: _confirmPasswordCtrl,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  onPressed: _register,
                  label: 'Register',
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Already have an account? Login here.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
