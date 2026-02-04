import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../components/auth_button.dart';
import '../components/auth_card.dart';
import '../components/auth_header.dart';
import '../components/auth_text_field.dart';
import '../components/theme_toggle_button.dart';
import '../../../events/presentation/pages/dashboard_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _cardScale;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequestedEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (_, __, ___) => const DashboardPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
              ),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.black87, Colors.black, Colors.grey.shade900]
                  : [Colors.blue.shade200, Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _cardScale,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: AuthCard(
                          isDark: isDark,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ScaleTransition(
                                  scale: _cardScale,
                                  child: Image.asset(
                                    'assets/images/app_logo.png',
                                    height: 80,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.lock,
                                              size: 80,
                                              color: Colors.blue,
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const AuthHeader(subtitle: "Login to continue"),
                                const SizedBox(height: 28),
                                AuthTextField(
                                  controller: _emailController,
                                  icon: Icons.email,
                                  label: "Email",
                                  isDark: isDark,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v == null || v.isEmpty
                                      ? "Enter email"
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                AuthTextField(
                                  controller: _passwordController,
                                  icon: Icons.lock,
                                  label: "Password",
                                  isDark: isDark,
                                  obscure: true,
                                  validator: (v) => v == null || v.isEmpty
                                      ? "Enter password"
                                      : null,
                                ),
                                const SizedBox(height: 30),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final loading = state is AuthLoading;

                                    return AuthButton(
                                      onPressed: loading
                                          ? null
                                          : _onLoginPressed,
                                      label: "Login",
                                      isLoading: loading,
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),

                                const SizedBox(height: 20),
                                Divider(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                              milliseconds: 700,
                                            ),
                                            pageBuilder: (_, __, ___) =>
                                                const SignUpPage(),
                                            transitionsBuilder:
                                                (_, animation, __, child) {
                                                  final slideAnimation =
                                                      Tween<Offset>(
                                                        begin: const Offset(
                                                          1,
                                                          0,
                                                        ),
                                                        end: Offset.zero,
                                                      ).animate(
                                                        CurvedAnimation(
                                                          parent: animation,
                                                          curve: Curves
                                                              .easeInOutCubic,
                                                        ),
                                                      );

                                                  final fadeAnimation =
                                                      animation.drive(
                                                        Tween<double>(
                                                          begin: 0,
                                                          end: 1,
                                                        ).chain(
                                                          CurveTween(
                                                            curve: Curves
                                                                .easeInOutQuart,
                                                          ),
                                                        ),
                                                      );

                                                  return SlideTransition(
                                                    position: slideAnimation,
                                                    child: FadeTransition(
                                                      opacity: fadeAnimation,
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
