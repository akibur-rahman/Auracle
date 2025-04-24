import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/common/widgets/custom_button.dart';
import '../../../core/common/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      // This would handle authentication in a real app
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Password: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Back Text
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),

                  // Email Input
                  CustomTextField(
                    hintText: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  CustomTextField(
                    hintText: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _signIn(),
                  ),
                  const SizedBox(height: 32),

                  // Sign In Button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _signIn,
                    isLoading: _isLoading,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  const SizedBox(height: 24),

                  // Google Sign In Button
                  CustomButton(
                    text: 'Continue with Google',
                    onPressed: () {
                      // Handle Google sign in
                    },
                    backgroundColor: Colors.grey[800],
                    icon: Image.network(
                      'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                      width: 24,
                      height: 24,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata, size: 24),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
