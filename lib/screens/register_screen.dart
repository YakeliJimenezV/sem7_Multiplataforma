import 'package:flutter/material.dart';
import '../router.dart';
import '../services/local_store.dart';
import '../services/validators.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_layout.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  String? _error;
  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await InventoryScope.of(context).register(
        name: _name.text,
        email: _email.text,
        phone: _phone.text,
        password: _password.text,
        confirmation: _confirmation.text,
      );
      if (!mounted) return;
      context.go('/login');
      showMessage(context, '¡Tu cuenta está lista! Ya puedes iniciar sesión.');
    } on AppException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    register: true,
    child: AutofillGroup(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('register-name'),
              controller: _name,
              validator: (value) => Validators.requiredText(value),
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('register-email'),
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.mail_outline, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('register-phone'),
              controller: _phone,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
              key: const Key('register-password'),
              controller: _password,
              label: 'Contraseña',
              newPassword: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            PasswordField(
              key: const Key('register-confirmation'),
              controller: _confirmation,
              label: 'Confirmar contraseña',
              newPassword: true,
              validator: (value) =>
                  Validators.confirmPassword(value, _password.text),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            SubmitButton(
              key: const Key('register-submit'),
              label: 'REGISTRARSE',
              icon: Icons.person_add_alt_1_outlined,
              onPressed: _submit,
              busy: InventoryScope.of(context).busy,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  '¿Ya tienes cuenta?',
                  style: TextStyle(color: InventiColors.muted),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Inicia sesión'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
