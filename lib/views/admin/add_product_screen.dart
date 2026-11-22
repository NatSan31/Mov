import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import '../../core/services/firebase_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String _selectedCategory = 'Suplementos';
  bool _isFeatured = false;
  bool _isSaving = false;

  final List<String> _categories = [
    'Suplementos',
    'Accesorios',
    'Ropa Deportiva',
    'Equipamiento',
  ];

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final product = ProductModel(
      id: '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      category: _selectedCategory,
      imageUrl: _imageUrlCtrl.text.trim(),
      stock: int.parse(_stockCtrl.text.trim()),
      isFeatured: _isFeatured,
    );

    final success =
        await context.read<ProductsProvider>().addProduct(product);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto creado con éxito'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al crear el producto'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRealMode = FirebaseService().hasRealCredentials;

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
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isRealMode)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: const Text(
                    '⚠️ Modo demo: los productos se agregarán localmente. Vincula Firebase para persistir en la nube.',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              _buildField('Nombre del producto *', _nameCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 14),
              _buildField('Descripción *', _descCtrl,
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildField('Precio (USD) *', _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                                ? 'Número válido'
                                : null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Stock *', _stockCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || int.tryParse(v) == null
                                ? 'Entero'
                                : null),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildField('URL de imagen *', _imageUrlCtrl,
                  hint: 'https://...',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obligatorio' : null),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Destacado en Inicio'),
                subtitle: const Text('Aparecerá en la sección featured'),
                value: _isFeatured,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProduct,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar Producto'),
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
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
