import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/inventory_controller.dart';
import '../services/local_store.dart';
import '../theme/app_theme.dart';

class InventoryScope extends InheritedNotifier<InventoryController> {
  const InventoryScope({
    super.key,
    required InventoryController controller,
    required super.child,
  }) : super(notifier: controller);
  static InventoryController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InventoryScope>()!.notifier!;
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      content: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      showCloseIcon: true,
    ),
  );
}

Future<void> signOut(BuildContext context) async {
  try {
    await InventoryScope.of(context).logout();
  } on AppException catch (error) {
    if (context.mounted) showMessage(context, error.message, error: true);
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.light = false, this.compact = false});
  final bool light;
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: light
              ? Colors.white.withValues(alpha: .16)
              : InventiColors.mint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.inventory_2_outlined,
          color: light ? Colors.white : InventiColors.forest,
          size: 25,
        ),
      ),
      if (!compact) ...[
        const SizedBox(width: 11),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'inventi',
              style: TextStyle(
                fontSize: 29,
                letterSpacing: -1.2,
                fontWeight: FontWeight.w800,
                color: light ? Colors.white : InventiColors.forest,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = Colors.white,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: InventiColors.line),
    ),
    child: child,
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final String title;
  final String subtitle;
  final Widget? action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: InventiColors.muted)),
        ],
      );
      if (constraints.maxWidth < 620) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text,
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: text),
          if (action != null) ...[const SizedBox(width: 20), action!],
        ],
      );
    },
  );
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.onSubmitted,
    this.newPassword = false,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final bool newPassword;
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: hidden,
    validator: widget.validator,
    onFieldSubmitted: widget.onSubmitted,
    autocorrect: false,
    enableSuggestions: false,
    autofillHints: [
      widget.newPassword ? AutofillHints.newPassword : AutofillHints.password,
    ],
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: const Icon(Icons.lock_outline, size: 20),
      suffixIcon: IconButton(
        tooltip: hidden
            ? 'Mostrar ${widget.label.toLowerCase()}'
            : 'Ocultar ${widget.label.toLowerCase()}',
        onPressed: () => setState(() => hidden = !hidden),
        icon: Icon(
          hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
      ),
    ),
  );
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.busy,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool busy;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: busy ? null : onPressed,
    icon: busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Icon(icon, size: 20),
    label: Text(busy ? 'Un momento…' : label),
  );
}

class ProductVisual extends StatelessWidget {
  const ProductVisual({super.key, required this.product, this.size = 72});
  final Product product;
  final double size;
  static IconData iconFor(Product product) {
    final name = product.name.toLowerCase();
    if (name.contains('laptop')) return Icons.laptop_mac_outlined;
    if (name.contains('mouse')) return Icons.mouse_outlined;
    if (name.contains('teclado')) return Icons.keyboard_outlined;
    if (name.contains('monitor')) return Icons.desktop_windows_outlined;
    return switch (product.category) {
      'Tecnología' => Icons.devices_other_outlined,
      'Oficina' => Icons.edit_note_outlined,
      'Hogar' => Icons.chair_outlined,
      'Accesorios' => Icons.watch_outlined,
      _ => Icons.inventory_2_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      iconFor(product),
      size: size * .48,
      color: InventiColors.forest,
    );
    Widget visual = fallback;
    if (product.imageBase64 != null) {
      try {
        visual = Image.memory(
          base64Decode(product.imageBase64!),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, _, _) => fallback,
        );
      } catch (_) {
        visual = fallback;
      }
    }
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: InventiColors.mintLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: visual,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: InventiColors.forest,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
