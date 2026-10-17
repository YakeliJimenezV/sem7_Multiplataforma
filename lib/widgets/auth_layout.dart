import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child, required this.register});
  final Widget child;
  final bool register;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 56).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  register
                      ? Icons.person_add_alt_1
                      : Icons.shopping_bag_outlined,
                  size: 64,
                  color: InventiColors.mint,
                ),
                const SizedBox(height: 16),
                Text(
                  register ? 'Crear Cuenta' : 'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  register
                      ? 'Regístrate para comenzar'
                      : 'Ingresa tus credenciales para continuar',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: InventiColors.muted,
                  ),
                ),
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
