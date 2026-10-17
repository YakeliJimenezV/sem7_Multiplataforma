import 'package:flutter/material.dart';
import '../services/local_store.dart';
import '../services/validators.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _edit() {
    final user = InventoryScope.of(context).user;
    _name.text = user?.name ?? '';
    _phone.text = user?.phone ?? '';
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    try {
      await InventoryScope.of(context).updateProfile(_name.text, _phone.text);
      if (mounted) {
        setState(() => _editing = false);
        showMessage(context, 'Tu perfil se actualizó correctamente.');
      }
    } on AppException catch (error) {
      if (mounted) showMessage(context, error.message, error: true);
    }
  }

  Widget _detail(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      children: [
        Icon(icon, size: 21, color: InventiColors.muted),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, color: InventiColors.muted),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final user = controller.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: InventiColors.mintLight,
                  child: Text(
                    user?.name.characters.first.toUpperCase() ?? 'I',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: InventiColors.forest,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    tooltip: 'Editar perfil',
                    style: IconButton.styleFrom(
                      backgroundColor: InventiColors.mint,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(30, 30),
                      padding: const EdgeInsets.all(6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: controller.busy ? null : _edit,
                    icon: const Icon(Icons.edit, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.name ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: InventiColors.muted),
          ),
          const SizedBox(height: 28),
          _detail(Icons.person_outline, 'Nombre', user?.name ?? ''),
          const Divider(),
          _detail(Icons.mail_outline, 'Email', user?.email ?? ''),
          const Divider(),
          _detail(Icons.phone_outlined, 'Teléfono', user?.phone ?? ''),
          const Divider(),
          _detail(Icons.badge_outlined, 'Roles', 'Usuario'),
          const Divider(),
          const SizedBox(height: 28),
          if (!_editing)
            OutlinedButton(
              onPressed: controller.busy ? null : _edit,
              child: const Text('EDITAR PERFIL'),
            )
          else
            Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('profile-name'),
                    controller: _name,
                    validator: (v) => Validators.requiredText(v),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('profile-phone'),
                    controller: _phone,
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  const SizedBox(height: 20),
                  SubmitButton(
                    key: const Key('profile-save'),
                    label: 'GUARDAR CAMBIOS',
                    icon: Icons.check,
                    onPressed: _save,
                    busy: controller.busy,
                  ),
                  TextButton(
                    onPressed: controller.busy
                        ? null
                        : () => setState(() => _editing = false),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
