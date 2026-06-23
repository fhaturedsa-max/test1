import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/product.dart';
import '../models/sale.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Map<String, int> _cart = {};
  String _searchQuery = "";
  String _selectedCategory = "All";
  double _discountPercentage = 0.0;

  final TextEditingController _amountPaidController = TextEditingController();

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    final currentQty = _cart[product.id] ?? 0;
    if (product.stock <= currentQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Insufficient stock for ${product.name}!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _cart[product.id] = currentQty + 1;
    });
  }

  void _removeFromCart(Product product) {
    final currentQty = _cart[product.id] ?? 0;
    if (currentQty <= 1) {
      setState(() {
        _cart.remove(product.id);
      });
    } else {
      setState(() {
        _cart[product.id] = currentQty - 1;
      });
    }
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _discountPercentage = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);
    final profile = service.profile;
    final currency = profile?.currency ?? r'$';
    final taxRate = profile?.taxRate ?? 10.0;

    final categories = ["All", ...service.products.map((p) => p.category).toSet().toList()];

    final filteredProducts = service.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.barcode.contains(_searchQuery);
      final matchesCat = _selectedCategory == "All" || p.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    double subtotal = 0.0;
    _cart.forEach((pid, qty) {
      final product = service.products.firstWhere((p) => p.id == pid);
      subtotal += product.sellingPrice * qty;
    });

    final taxAmount = subtotal * (taxRate / 100);
    final discountAmount = subtotal * (_discountPercentage / 100);
    final totalAmount = (subtotal + taxAmount - discountAmount).clamp(0.0, 999999.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Register Terminal",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (service.products.isNotEmpty) {
                            final p = service.products.first;
                            _addToCart(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Simulated barcode scan: Added '${p.name}'"),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors.emerald,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                        label: const Text("Simulate Scan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.emerald,
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search custom items, SKU or scan barcode...",
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
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1E293B),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, color: Colors.slate[300], size: 48),
                                const SizedBox(height: 12),
                                const Text(
                                  "No products found",
                                  style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              childAspectRatio: 0.76,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, idx) {
                              final p = filteredProducts[idx];
                              final currentInCart = _cart[p.id] ?? 0;
                              final inStock = p.stock - currentInCart;

                              return Card(
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: InkWell(
                                  onTap: inStock > 0 ? () => _addToCart(p) : null,
                                  borderRadius: BorderRadius.circular(16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                p.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, o, s) => Container(
                                                  color: const Color(0xFFF1F5F9),
                                                  child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                                                ),
                                              ),
                                              if (inStock <= 0)
                                                Container(
                                                  color: Colors.black54,
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                    "OUT OF STOCK",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                )
                                              else if (currentInCart > 0)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.emerald,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      "x$currentInCart",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "$currency${p.sellingPrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.emerald,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.between,
                                                children: [
                                                  Text(
                                                    p.sku,
                                                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                                  ),
                                                  Text(
                                                    "$inStock left",
                                                    style: TextStyle(
                                                      fontSize: 9.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: inStock < 5 ? Colors.redAccent : const Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          Container(width: 1, color: const Color(0xFFE2E8F0)),

          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        Text(
                          "Active Basket (${_cart.values.fold(0, (a, b) => a + b)})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        if (_cart.isNotEmpty)
                          IconButton(
                            onPressed: _clearCart,
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.rose),
                            tooltip: "Clear basket",
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_basket_outlined, size: 48, color: Color(0xFFCBD5E1)),
                                SizedBox(height: 12),
                                Text(
                                  "Basket is currently empty",
                                  style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            children: _cart.entries.map((ent) {
                              final p = service.products.firstWhere((prod) => prod.id == ent.key);
                              final qty = ent.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "$currency${p.sellingPrice.toStringAsFixed(2)} x $qty",
                                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "$currency${(p.sellingPrice * qty).toStringAsFixed(2)}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => _removeFromCart(p),
                                          icon: const Icon(Icons.remove, size: 16),
                                          style: IconButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(24, 24),
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _addToCart(p),
                                          icon: const Icon(Icons.add, size: 16),
                                          style: IconButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(24, 24),
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_cart.isNotEmpty) ...[
                          Row(
                            children: [
                              const Text("Add Discount:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              const SizedBox(width: 8),
                              DropdownButton<double>(
                                value: _discountPercentage,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                onChanged: (val) {
                                  if (val != null) setState(() => _discountPercentage = val);
                                },
                                items: [0.0, 5.0, 10.0, 15.0, 20.0, 50.0].map((d) {
                                  return DropdownMenuItem<double>(
                                    value: d,
                                    child: Text("${d.toInt()}% Off"),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            const Text("Subtotal", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text("$currency${subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text("Standard Tax ($taxRate%)", style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                            Text("$currency${taxAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (discountAmount > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              const Text("Discount Applied", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                              Text("-$currency${discountAmount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            ],
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            const Text("TOTAL INVOICE", style: TextStyle(fontWeight: FontWeight.black, fontSize: 14)),
                            Text(
                              "$currency${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.black, fontSize: 18, color: Colors.emerald),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _cart.isEmpty
                                ? null
                                : () => _showPaymentModal(context, totalAmount, service, profile?.currency ?? r'$'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.emerald,
                              foregroundColor: const Color(0xFF0F172A),
                              disabledBackgroundColor: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(
                                child: null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Proceed to Charge",
                              style: TextStyle(fontWeight: FontWeight.extrabold, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentModal(BuildContext context, double totalVal, FirebaseService service, String currency) {
    _amountPaidController.text = totalVal.toStringAsFixed(2);
    String selectedMethod = "Cash";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double amtPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
            final double changeDue = (amtPaid - totalVal).clamp(0.0, 9999999.0);

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              surfaceTintColor: Colors.transparent,
              title: const Text("Receive Payment Method", style: TextStyle(color: Colors.white, fontWeight: FontWeight.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Total Invoice Bill: $currency${totalVal.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.emerald),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: ["Cash", "Card", "QR QR Code", "Mobile pay"].map((m) {
                      final isSel = selectedMethod == m;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: InkWell(
                            onTap: () => setModalState(() => selectedMethod = m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.emerald : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSel ? Colors.emerald : const Color(0xFF334155)),
                              ),
                              child: Text(
                                m,
                                style: TextStyle(
                                  color: isSel ? const Color(0xFF0F172A) : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _amountPaidController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Received Tender Amount ($currency)",
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.emerald),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "Change Returned back: $currency${changeDue.toStringAsFixed(2)}",
                    style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel transaction", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: amtPaid < totalVal
                      ? null
                      : () async {
                          final List<SaleItem> invoiceItems = [];
                          _cart.forEach((pid, qty) {
                            final prod = service.products.firstWhere((p) => p.id == pid);
                            invoiceItems.add(SaleItem(
                              productId: pid,
                              name: prod.name,
                              quantity: qty,
                              sellingPrice: prod.sellingPrice,
                              costPrice: prod.costPrice,
                            ));
                          });

                          await service.checkout(
                            invoiceItems,
                            totalVal - (totalVal * (service.profile?.taxRate ?? 10.0) / 100),
                            totalVal * ((service.profile?.taxRate ?? 10.0) / 100),
                            totalVal * (_discountPercentage / 100),
                            totalVal,
                            selectedMethod,
                            amtPaid,
                            changeDue,
                          );

                          Navigator.pop(ctx);
                          _clearCart();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Checkout success! Receipt generated & stock updated."),
                              backgroundColor: Colors.emerald,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.emerald, foregroundColor: Colors.black85),
                  child: const Text("Confirm Sale", style: TextStyle(fontWeight: FontWeight.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
