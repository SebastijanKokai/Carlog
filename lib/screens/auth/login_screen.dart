import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carlog/extensions/theme_extensions.dart';
import 'package:carlog/widgets/submit_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authenticateUser();
    } on FirebaseAuthException catch (e) {
      _handleLoginError(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _authenticateUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void _handleLoginError(dynamic error) {
    if (!mounted) return;

    String errorMessage = 'Došlo je do greške prilikom prijave';

    if (error is FirebaseAuthException) {
      errorMessage = _getAuthErrorMessage(error.code);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Nije pronađen korisnik sa ovom email adresom';
      case 'wrong-password':
        return 'Pogrešna lozinka';
      case 'invalid-email':
        return 'Nevažeća email adresa';
      case 'user-disabled':
        return 'Korisnički nalog je onemogućen';
      default:
        return 'Došlo je do greške prilikom prijave';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LoginHeader(),
                  const SizedBox(height: 32),
                  _LoginFormFields(
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  const SizedBox(height: 24),
                  SubmitButton(
                    isLoading: _isLoading,
                    onPressed: _login,
                    text: 'Prijavi se',
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

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.directions_car,
          size: 80,
          color: context.primaryColor,
        ),
        const SizedBox(height: 32),
        Text(
          'Dobro došli',
          style: context.headlineStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _LoginFormFields({
    required this.emailController,
    required this.passwordController,
  });

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unesite email adresu';
    }
    if (!value.contains('@')) {
      return 'Unesite validnu email adresu';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unesite lozinku';
    }
    if (value.length < 6) {
      return 'Lozinka mora imati najmanje 6 karaktera';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: context.inputBorder,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Lozinka',
            border: context.inputBorder,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
          validator: _validatePassword,
        ),
      ],
    );
  }
}
