import 'package:flutter/material.dart';
import 'package:holz_logistik/services/auth_service.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      void showSuccessMessage() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email zum Zurücksetzen des Passworts versandt.'),
          ),
        );
        Navigator.pop(context);
      }

      void showErrorMessage(String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zurücksetzen des Passworts fehlgeschlagen: $error'),
          ),
        );
      }

      authService.resetPassword(_emailController.text).then((_) {
        showSuccessMessage();
      }).catchError((error) {
        showErrorMessage(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passwort zurücksetzen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Email eingeben';
                  }
                  if (!value.contains('@')) {
                    return 'Bitte eine valide Email eingeben';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Passwort zurücksetzen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
