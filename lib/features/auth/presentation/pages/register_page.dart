import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zoozi_wallet/core/router/app_router.dart';
import 'package:zoozi_wallet/core/utils/extensions/context_extension.dart';
import 'package:zoozi_wallet/di/di.dart';

import '../bloc/auth_bloc.dart';
import '../../../../core/utils/validators/form_validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authBloc = getIt<AuthBloc>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      _authBloc.add(
        RegisterEvent(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          context: context,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is AuthAuthenticated) {
          context.go(AppRouter.home);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    l.createAccount,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.signUp,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nameController,
                    hintText: l.fullName,
                    prefixIcon: Icons.person_outline,
                    validator: (value) =>
                        FormValidators.validateName(value, context),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    hintText: l.email,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        FormValidators.validateEmail(value, context),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: l.password,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (value) =>
                        FormValidators.validatePassword(value, context),
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: l.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) =>
                        FormValidators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                      context,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _toggleConfirmPasswordVisibility,
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    bloc: _authBloc,
                    builder: (context, state) {
                      return CustomButton(
                        text: l.register,
                        onPressed: _handleRegister,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l.haveAccount,
                        style: const TextStyle(),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(l.login),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
