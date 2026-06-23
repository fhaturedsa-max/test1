import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _costController = TextEditingController();
  final _sellController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _catalogSearch = "";

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _skuController.clear();
    _barcodeController.clear();
    _categoryController.clear();
    _costController.clear();
    _sellController.clear();
    _stockController.clear();
    _imageUrlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);
    final profile = service.profile;
    final currency = profile?.currency ?? r'$';

    final list = service.products.where((p) {
      return p.name.toLowerCase().contains(_catalogSearch.toLowerCase()) ||
          p.sku.toLowerCase().contains(_catalogSearch.toLowerCase()) ||
          p.category.toLowerCase().contains(_catalogSearch.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Stock Catalog Manager",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.extrabold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Discharging ${service.products.length} active articles in stock catalog",
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => service.seedInitialProducts(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("Load Seed Catalog"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditModal(context, service, null),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Register Article"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.emerald,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              onChanged: (v) => setState(() => _catalogSearch = v),
              decoration: InputDecoration(
                hintText: "Filter catalog items by name, category or SKU...",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.emerald, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.widgets_outlined, size: 48, color: Colors.slate[300]),
                          const SizedBox(height: 12),
                          const Text(
                            "Your stock inventory is empty",
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      elevation: 0,
                      child: ListView.separated(
                        separatorBuilder: (c, idx) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                        itemCount: list.length,
                        itemBuilder: (context, idx) {
                          final p = list[idx];
                          final bool lowStock = p.stock < 10;
                          final bool outOfStock = p.stock == 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    p.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Container(
                                      width: 48,
                                      height: 48,
                                      color: const Color(0xFFF1F5F9),
                                      child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              p.category,
                                              style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "SKU: ${p.sku}",
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Cost: $currency${p.costPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Sell: $currency${p.sellingPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(fontWeight: FontWeight.extrabold, fontSize: 13, color: Colors.emerald),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Stock Level", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          "${p.stock} units",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: outOfStock
                                                ? Colors.red
                                                : lowStock
                                                    ? Colors.amber[800]
                                                    : const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          outOfStock
                                              ? Icons.cancel_rounded
                                              : lowStock
                                                  ? Icons.error_outline_rounded
                                                  : Icons.check_circle_outline_rounded,
                                          size: 14,
                                          color: outOfStock
                                              ? Colors.red
                                              : lowStock
                                                  ? Colors.amber[800]
                                                  : Colors.emerald,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 16),

                                IconButton(
                                  onPressed: () => _showAddEditModal(context, service, p),
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(context, service, p.id),
                                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditModal(BuildContext context, FirebaseService service, Product? targetProduct) {
    if (targetProduct != null) {
      _nameController.text = targetProduct.name;
      _skuController.text = targetProduct.sku;
      _barcodeController.text = targetProduct.barcode;
      _categoryController.text = targetProduct.category;
      _costController.text = targetProduct.costPrice.toString();
      _sellController.text = targetProduct.sellingPrice.toString();
      _stockController.text = targetProduct.stock.toString();
      _imageUrlController.text = targetProduct.imageUrl;
    } else {
      _clearForm();
    }

    final isNew = targetProduct == null;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
          title: Text(
            isNew ? "Register New Product" : "Edit Stock Article Details",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.black, fontSize: 16),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(labelText: "Product Title Name", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                    validator: (v) => v == null || v.isEmpty ? "Require name" : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skuController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(labelText: "SKU SKU Code", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                          validator: (v) => v == null || v.isEmpty ? "Require SKU" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _barcodeController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(labelText: "Barcode Code", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(labelText: "Category Grouping", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                    validator: (v) => v == null || v.isEmpty ? "Require category" : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(labelText: "Cost Price", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                          validator: (v) => v == null || double.tryParse(v) == null ? "Invalid double" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _sellController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(labelText: "Selling Price", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                          validator: (v) => v == null || double.tryParse(v) == null ? "Invalid double" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(labelText: "Units stock", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                          validator: (v) => v == null || int.tryParse(v) == null ? "Invalid stock" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(labelText: "Image Thumbnail URL", labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel editing", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                if (isNew) {
                  await service.addProduct(
                    _nameController.text.trim(),
                    _skuController.text.trim(),
                    _barcodeController.text.trim(),
                    _categoryController.text.trim(),
                    double.parse(_costController.text),
                    double.parse(_sellController.text),
                    int.parse(_stockController.text),
                    _imageUrlController.text.trim(),
                  );
                } else {
                  await service.updateProduct(
                    targetProduct.copyWith(
                      name: _nameController.text.trim(),
                      sku: _skuController.text.trim(),
                      barcode: _barcodeController.text.trim(),
                      category: _categoryController.text.trim(),
                      costPrice: double.parse(_costController.text),
                      sellingPrice: double.parse(_sellController.text),
                      stock: int.parse(_stockController.text),
                      imageUrl: _imageUrlController.text.trim(),
                    ),
                  );
                }
                Navigator.pop(ctx);
                _clearForm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.emerald, foregroundColor: Colors.black85),
              child: Text(isNew ? "Create SKU" : "Apply Changes"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, FirebaseService service, String productId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("Delete Product", style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to permanently delete this product from the stock registry? This is irreversible.", style: TextStyle(color: Color(0xFF94A3B8))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.deleteProduct(productId);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Confirm Delete"),
            ),
          ],
        );
      },
    );
  }
}
