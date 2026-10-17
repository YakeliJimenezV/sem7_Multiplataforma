import 'package:flutter/material.dart';
import '../router.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final options = [
      ('Registrar Productos', Icons.shopping_cart_outlined, '/products/new'),
      ('Listar Productos', Icons.list_alt, '/products'),
      ('Perfil', Icons.person_outline, '/profile'),
      ('Logout', Icons.logout, '/login'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: options.length,
      separatorBuilder: (_, _) => const Divider(indent: 20, endIndent: 20),
      itemBuilder: (context, index) {
        final option = options[index];
        final logout = index == 3;
        return ListTile(
          leading: Icon(
            option.$2,
            color: logout ? InventiColors.red : InventiColors.ink,
          ),
          title: Text(option.$1, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right, size: 22),
          enabled: !logout || !controller.busy,
          onTap: () => logout ? signOut(context) : context.go(option.$3),
        );
      },
    );
  }
}
