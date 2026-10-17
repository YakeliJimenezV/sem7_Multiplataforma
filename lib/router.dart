import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'providers/inventory_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/app_shell.dart';
import 'widgets/common.dart';

extension InventiNavigation on BuildContext {
  void go(String path) {
    final delegate = Router.of(this).routerDelegate as InventiRouter;
    Router.navigate(this, () => delegate.go(path));
  }
}

class InventiRouteParser extends RouteInformationParser<String> {
  const InventiRouteParser();
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(routeInformation.uri.path);
  @override
  RouteInformation restoreRouteInformation(String configuration) =>
      RouteInformation(uri: Uri.parse(configuration));
}

class InventiRouter extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  InventiRouter(this.controller) {
    location = _guard('/');
    controller.addListener(_refresh);
  }
  final InventoryController controller;
  late String location;
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  String get currentConfiguration => location;

  String _guard(String path) {
    final public = path == '/login' || path == '/register';
    if (!controller.authenticated) return public ? path : '/login';
    return public || path == '/' || path.isEmpty ? '/dashboard' : path;
  }

  void _refresh() {
    location = _guard(location);
    notifyListeners();
  }

  void go(String path) {
    location = _guard(path);
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    go(configuration);
    return SynchronousFuture(null);
  }

  @override
  Future<bool> popRoute() async {
    // Los diálogos se cierran antes de cambiar la pantalla actual.
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop();
      return true;
    }
    if (location == '/login' || location == '/dashboard') return false;
    go(
      location == '/register'
          ? '/login'
          : location.endsWith('/edit')
          ? '/products'
          : '/dashboard',
    );
    return true;
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    super.dispose();
  }

  Widget _screen() {
    if (location == '/login') return const LoginScreen();
    if (location == '/register') return const RegisterScreen();
    Widget? child;
    if (location == '/dashboard') child = const DashboardScreen();
    if (location == '/products') child = const ProductsScreen();
    if (location == '/products/new') child = const ProductFormScreen();
    if (location == '/profile') child = const ProfileScreen();
    final edit = RegExp(r'^/products/([^/]+)/edit$').firstMatch(location);
    if (edit != null) {
      child = ProductFormScreen(
        key: ValueKey(edit.group(1)),
        productId: edit.group(1),
      );
    }
    if (child != null) return AppShell(location: location, child: child);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            title: 'Esta página no existe',
            message: 'Vuelve a tu espacio de Inventi.',
            action: Builder(
              builder: (context) => FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Volver al inicio'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: [MaterialPage<void>(key: ValueKey(location), child: _screen())],
    onDidRemovePage: (_) {},
  );
}
