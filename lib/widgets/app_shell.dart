import 'package:flutter/material.dart';
import '../router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    final menu = location == '/dashboard';
    final products = location == '/products';
    final form = location.startsWith('/products/');
    final title = menu
        ? 'Menú'
        : products
        ? 'Productos'
        : form
        ? (location.endsWith('/edit')
              ? 'Editar Producto'
              : 'Registrar Producto')
        : 'Perfil';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: menu ? 'Menú' : 'Volver',
          icon: Icon(menu ? Icons.menu : Icons.arrow_back),
          onPressed: () => context.go(form ? '/products' : '/dashboard'),
        ),
        title: Text(title),
        actions: [
          if (products)
            IconButton(
              tooltip: 'Registrar Producto',
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/products/new'),
            ),
        ],
      ),
      body: SafeArea(top: false, child: child),
    );
  }
}
