import 'package:flutter/material.dart';
import '../router.dart';
import '../models/product.dart';
import '../services/local_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _search = TextEditingController();
  String _category = 'Todas';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(Product product) async {
    final controller = InventoryScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: InventiColors.forest),
        title: const Text('¿Eliminar producto?'),
        content: Text(
          'Se eliminará “${product.name}” de tu inventario. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await controller.deleteProduct(product.id);
      if (mounted) showMessage(context, 'Producto eliminado correctamente.');
    } on AppException catch (error) {
      if (mounted) showMessage(context, error.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final query = _search.text.trim().toLowerCase();
    final products = controller.products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) &&
              (_category == 'Todas' || p.category == _category),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            key: const Key('product-search'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              fillColor: InventiColors.background,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () => setState(_search.clear),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: InventiColors.muted),
              items: [
                for (final category in ['Todas', ...productCategories])
                  DropdownMenuItem(
                    value: category,
                    child: Text(
                      category == 'Todas' ? 'Todas las categorías' : category,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _category = value!),
            ),
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      controller.products.isEmpty
                          ? 'No hay productos registrados'
                          : 'No encontramos productos',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        if (controller.products.isEmpty) {
                          context.go('/products/new');
                        } else {
                          setState(() {
                            _search.clear();
                            _category = 'Todas';
                          });
                        }
                      },
                      child: Text(
                        controller.products.isEmpty
                            ? 'Registrar producto'
                            : 'Limpiar filtros',
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, _) =>
                      const Divider(indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          ProductVisual(product: product, size: 54),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Precio: ${money(product.priceCents)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: InventiColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Stock: ${units(product.stock)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: InventiColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Opciones de ${product.name}',
                            enabled: !controller.busy,
                            icon: const Icon(
                              Icons.more_vert,
                              color: InventiColors.muted,
                            ),
                            onSelected: (action) {
                              if (action == 'edit') {
                                context.go('/products/${product.id}/edit');
                              } else {
                                _delete(product);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
