import 'package:flutter/material.dart';
import '../router.dart';
import '../models/product.dart';
import '../services/image_service.dart';
import '../services/local_store.dart';
import '../services/validators.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final String? productId;
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  String _category = productCategories.first;
  String? _image;
  bool _loaded = false;
  bool _picking = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final product = widget.productId == null
        ? null
        : InventoryScope.of(context).productById(widget.productId!);
    if (product != null) {
      _name.text = product.name;
      _description.text = product.description;
      _price.text = (product.priceCents / 100).toStringAsFixed(2);
      _stock.text = product.stock.toString();
      _category = product.category;
      _image = product.imageBase64;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _price, _stock]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final image = await ImageService().pick();
      if (image != null && mounted) setState(() => _image = image);
    } catch (error) {
      if (mounted) {
        showMessage(
          context,
          error is AppException
              ? error.message
              : 'No pudimos abrir la imagen. Inténtalo de nuevo.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    try {
      await InventoryScope.of(context).saveProduct(
        id: widget.productId,
        name: _name.text,
        description: _description.text,
        price: _price.text,
        stock: _stock.text,
        category: _category,
        imageBase64: _image,
      );
      if (!mounted) return;
      context.go('/products');
      showMessage(
        context,
        widget.productId == null
            ? 'Producto registrado correctamente.'
            : 'Producto actualizado correctamente.',
      );
    } on AppException catch (error) {
      if (mounted) showMessage(context, error.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final editing = widget.productId != null;
    if (editing && controller.productById(widget.productId!) == null) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: EmptyState(
          title: 'Producto no disponible',
          message: 'El producto no existe en tu inventario o ya fue eliminado.',
          action: FilledButton(
            onPressed: () => context.go('/products'),
            child: const Text('Volver a productos'),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: InventiColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: InventiColors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _picking || controller.busy ? null : _pick,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      if (_image == null)
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 36,
                          color: InventiColors.muted,
                        )
                      else
                        ProductVisual(
                          size: 72,
                          product: Product(
                            id: '',
                            ownerId: '',
                            name: _name.text,
                            description: '',
                            priceCents: 0,
                            stock: 0,
                            category: _category,
                            imageBase64: _image,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _picking
                            ? 'Abriendo…'
                            : _image == null
                            ? 'Seleccionar imagen'
                            : 'Cambiar imagen',
                        style: const TextStyle(
                          color: InventiColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_image != null)
              TextButton(
                onPressed: controller.busy
                    ? null
                    : () => setState(() => _image = null),
                child: const Text('Quitar imagen'),
              ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('product-name'),
              controller: _name,
              validator: (v) => Validators.requiredText(v),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('product-description'),
              controller: _description,
              validator: (v) => Validators.requiredText(v, max: 500),
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('product-price'),
              controller: _price,
              validator: Validators.price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixText: 'S/ ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('product-stock'),
              controller: _stock,
              validator: Validators.stock,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Stock'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('product-category'),
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: [
                for (final category in productCategories)
                  DropdownMenuItem(value: category, child: Text(category)),
              ],
              onChanged: controller.busy
                  ? null
                  : (value) => setState(() => _category = value!),
              validator: (value) =>
                  value == null ? 'Selecciona una categoría.' : null,
            ),
            const SizedBox(height: 24),
            SubmitButton(
              key: const Key('product-save'),
              label: 'GUARDAR',
              icon: Icons.check,
              onPressed: _save,
              busy: controller.busy || _picking,
            ),
          ],
        ),
      ),
    );
  }
}
