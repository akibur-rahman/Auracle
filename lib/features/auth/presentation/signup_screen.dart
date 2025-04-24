import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/common/widgets/custom_button.dart';
import '../../../core/common/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      // This would handle registration in a real app
      debugPrint('Username: ${_usernameController.text}');
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
                  // Create Account Text
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your musical journey',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),

                  // Username Input
                  CustomTextField(
                    hintText: 'Username',
                    controller: _usernameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _signUp(),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Button
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: _signUp,
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
                      'https://www.googleapis.com/download/storage/v1/b/gweb-uniblog-publish-prod/o/images%2FdDdBl-QoTM8w_hE_YUzQeg.png?generation=1637834187242249&alt=media',
                      width: 24,
                      height: 24,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata, size: 24),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign In'),
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
