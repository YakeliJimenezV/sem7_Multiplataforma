import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/inventory_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

class InventiApp extends StatefulWidget {
  const InventiApp({super.key, required this.controller, this.initialLocation});
  final InventoryController controller;
  final String? initialLocation;
  @override
  State<InventiApp> createState() => _InventiAppState();
}

class _InventiAppState extends State<InventiApp> {
  late final _router = InventiRouter(widget.controller);
  late final _routeInformation = PlatformRouteInformationProvider(
    initialRouteInformation: RouteInformation(
      uri: Uri.parse(
        widget.initialLocation ??
            WidgetsBinding.instance.platformDispatcher.defaultRouteName,
      ),
    ),
  );
  late final _config = RouterConfig<String>(
    routerDelegate: _router,
    routeInformationParser: const InventiRouteParser(),
    routeInformationProvider: _routeInformation,
    backButtonDispatcher: RootBackButtonDispatcher(),
  );
  @override
  void dispose() {
    _router.dispose();
    _routeInformation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InventoryScope(
    controller: widget.controller,
    child: MaterialApp.router(
      title: 'Inventi · Todo en su lugar',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) => _MobileViewport(child: child!),
      locale: const Locale('es', 'PE'),
      supportedLocales: const [Locale('es', 'PE')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _config,
    ),
  );
}

class InventiBootstrap extends StatelessWidget {
  const InventiBootstrap({super.key, required this.controller});
  final InventoryController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      if (controller.ready) return InventiApp(controller: controller);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        builder: (context, child) => _MobileViewport(child: child!),

        home: Scaffold(
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Brand(),
                    const SizedBox(height: 30),
                    if (controller.initializationError == null) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      const Text('Preparando tu espacio…'),
                    ] else ...[
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 40,
                        color: InventiColors.forest,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        controller.initializationError!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: controller.initialize,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _MobileViewport extends StatelessWidget {
  const _MobileViewport({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: InventiColors.background,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final framed =
            constraints.maxWidth > 440 && constraints.maxHeight > 600;
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: framed ? 16 : 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 860),
              child: LayoutBuilder(
                builder: (context, phoneConstraints) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(size: phoneConstraints.biggest),
                  child: ColoredBox(color: Colors.white, child: child),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
