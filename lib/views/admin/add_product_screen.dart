import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../core/services/firebase_service.dart';

/// Controlador de estado para el formulario sin utilizar setState (Regla estricta: Provider)
class AddProductFormState extends ChangeNotifier {
  String _selectedCategory = 'Suplementos';
  String get selectedCategory => _selectedCategory;

  bool _isFeatured = false;
  bool get isFeatured => _isFeatured;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setFeatured(bool value) {
    _isFeatured = value;
    notifyListeners();
  }

  void setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddProductFormState(),
      child: const _AddProductContent(),
    );
  }
}

class _AddProductContent extends StatelessWidget {
  const _AddProductContent();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final stockCtrl = TextEditingController();

    final formState = context.watch<AddProductFormState>();
    final isRealMode = FirebaseService().hasRealCredentials;

    final categories = const [
      'Suplementos',
      'Accesorios',
      'Ropa Deportiva',
      'Equipamiento',
    ];

    Future<void> saveProduct() async {
      if (!formKey.currentState!.validate()) return;
      formState.setSaving(true);

      final product = ProductModel(
        id: '',
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.parse(priceCtrl.text.trim()),
        category: formState.selectedCategory,
        imageUrl: imageUrlCtrl.text.trim(),
        stock: int.parse(stockCtrl.text.trim()),
        isFeatured: formState.isFeatured,
      );

      final success = await context.read<ProductsProvider>().addProduct(product);

      formState.setSaving(false);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Producto creado y guardado en Firestore con éxito'),
              backgroundColor: AppColors.secondary,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error al guardar el producto en Firestore'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin – Nuevo Producto'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                isRealMode ? '🔥 Firebase' : '📱 Demo',
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: isRealMode
                  ? AppColors.secondary.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                context: context,
                label: 'Nombre del producto *',
                controller: nameCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                context: context,
                label: 'Descripción *',
                controller: descCtrl,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      context: context,
                      label: 'Precio (USD) *',
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Número válido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      context: context,
                      label: 'Stock *',
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Entero' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildField(
                context: context,
                label: 'URL de imagen *',
                controller: imageUrlCtrl,
                hint: 'https://images.unsplash.com/...',
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: formState.selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) formState.setCategory(v);
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Destacado en Inicio'),
                subtitle: const Text('Aparecerá en la sección de recomendados'),
                value: formState.isFeatured,
                activeColor: AppColors.primary,
                onChanged: (v) => formState.setFeatured(v),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: formState.isSaving ? null : saveProduct,
                icon: formState.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(formState.isSaving ? 'Guardando en Firestore...' : 'Guardar Producto en Firestore'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
