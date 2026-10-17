import 'package:flutter/material.dart';
import '../router.dart';
import '../services/local_store.dart';
import '../services/validators.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await InventoryScope.of(context).login(_email.text, _password.text);
    } on AppException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    register: false,
    child: AutofillGroup(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('login-email'),
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
              key: const Key('login-password'),
              controller: _password,
              label: 'Password',
              validator: Validators.password,
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                key: const Key('auth-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 22),
            SubmitButton(
              key: const Key('login-submit'),
              label: 'LOGIN',
              icon: Icons.login,
              onPressed: _submit,
              busy: InventoryScope.of(context).busy,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => showMessage(
                context,
                'La recuperación de contraseña no está disponible en esta aplicación local.',
              ),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(color: InventiColors.muted),
                ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Regístrate'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
