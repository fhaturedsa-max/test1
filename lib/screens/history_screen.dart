import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/sale.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _historyQuery = "";

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);
    final currency = service.profile?.currency ?? r'$';
    final sales = service.sales;

    final filteredHistory = sales.where((s) {
      final matchesQuery = s.id.toLowerCase().contains(_historyQuery.toLowerCase()) ||
          s.paymentMethod.toLowerCase().contains(_historyQuery.toLowerCase());
      return matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transaction Archive",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.extrabold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Review complete sales records & handle refunds/restoring stocks",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            TextField(
              onChanged: (v) => setState(() => _historyQuery = v),
              decoration: InputDecoration(
                hintText: "Search receipts by invoice ID (e.g., INV-...) or payment methods...",
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
              child: filteredHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.slate[300]),
                          const SizedBox(height: 12),
                          const Text(
                            "No matching sale records found",
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
                        separatorBuilder: (c, i) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, idx) {
                          final s = filteredHistory[idx];

                          final dt = DateTime.parse(s.timestamp);
                          final prettyDate = DateFormat('yyyy-MM-dd HH:mm').format(dt);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.emerald.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_rounded, color: Colors.emerald),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  s.id,
                                  style: const TextStyle(fontWeight: FontWeight.black, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    s.paymentMethod,
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Date: $prettyDate  •  ${s.items.length} items logged",
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "$currency${s.totalAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.black, fontSize: 15, color: Colors.emerald),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF64748B)),
                                  tooltip: "View Details",
                                  onPressed: () => _showDetailsModal(context, s, currency),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.replay_rounded, color: Colors.redAccent),
                                  tooltip: "Refund & Restore stock",
                                  onPressed: () => _confirmRefund(context, service, s),
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

  void _showDetailsModal(BuildContext context, Sale sale, String currency) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          surfaceTintColor: Colors.transparent,
          title: Text(sale.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.black)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text("Purchased Articles:", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...sale.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text(
                          "${item.name} x${item.quantity}",
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        Text(
                          "$currency${(item.sellingPrice * item.quantity).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(color: Color(0xFF334155), height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text("Subtotal:", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    Text("$currency${sale.subtotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text("Tax:", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    Text("$currency${sale.taxAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text("Savings/Discount:", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                    Text("-$currency${sale.discountAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(color: Color(0xFF334155), height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text("GRAND TOTAL BILL:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.black, fontSize: 14)),
                    Text("$currency${sale.totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.emerald, fontWeight: FontWeight.black, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text("Tender Paid:", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    Text("$currency${sale.amountPaid.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text("Change Returned:", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    Text("$currency${sale.changeReturned.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Dismiss Receipt Details"),
            ),
          ],
        );
      },
    );
  }

  void _confirmRefund(BuildContext context, FirebaseService service, Sale sale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("Refund Transaction", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to perform a full refund on invoice ${sale.id}? "
            "This will permanently delete the invoice summary and RESTORE all stock units back to shelf storage.",
            style: const TextStyle(color: Color(0xFF94A3B8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.refundTransaction(sale);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Refund successful. Quantities restored back to inventory."),
                    backgroundColor: Colors.emerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Process Refund"),
            ),
          ],
        );
      },
    );
  }
}
