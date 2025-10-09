import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasError = false;
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create a custom shake animation that goes back and forth
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _shakeController!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController?.dispose();
    super.dispose();
  }

  void _playShakeAnimation() {
    _shakeController?.reset();
    _shakeController?.forward();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Clear any previous error state
      setState(() => _hasError = false);

      // The error handling is done via ref.listen in the build method
      await ref.read(authProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Only handle errors when they appear (not on initial load)
      if (previous != null && next.error != null && previous.error != next.error) {
        // Check if user needs to verify email
        final error = next.error!;
        if (error.toLowerCase().contains('not confirmed') ||
            error.toLowerCase().contains('user is not confirmed')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please verify your email first'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Verify',
                textColor: Colors.white,
                onPressed: () {
                  context.push(
                    '/verify-email',
                    extra: _emailController.text.trim(),
                  );
                },
              ),
            ),
          );
        } else {
          // Handle incorrect credentials - trigger error state and animation
          setState(() {
            _hasError = true;
          });

          _playShakeAnimation();

          // Clear password after a brief delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _passwordController.clear();
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }

      // Navigate to home on successful authentication
      if (next.isAuthenticated && previous?.isAuthenticated == false) {
        context.go('/');
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Transform.translate(
                    offset: const Offset(30, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ventus',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Satoshi',
                              ),
                        ),
                        Transform.translate(
                          offset: const Offset(-20, 0),
                          child: Image.asset(
                            'assets/images/ventus_transparent.png',
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Text(
                      'Wake up accountability',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: _shakeAnimation ?? const AlwaysStoppedAnimation(0),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation?.value ?? 0, 0),
                        child: child,
                      );
                    },
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Theme.of(context).primaryColor,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: _hasError ? Colors.red : null,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _shakeAnimation ?? const AlwaysStoppedAnimation(0),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation?.value ?? 0, 0),
                        child: child,
                      );
                    },
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Theme.of(context).primaryColor,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: _hasError ? Colors.red : null,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: _hasError ? Colors.red : null,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text('Don\'t have an account? Sign up'),
                  ),
                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
