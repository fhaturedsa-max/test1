import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../models/sale.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);
    final currency = service.profile?.currency ?? r'$';
    final sales = service.sales;

    double totalRevenue = 0.0;
    double totalCost = 0.0;
    
    for (var sale in sales) {
      totalRevenue += sale.totalAmount;
      for (var item in sale.items) {
        totalCost += item.costPrice * item.quantity;
      }
    }

    double totalProfit = totalRevenue - totalCost;
    double grossMarginPercentage = totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;
    double averageOrderValue = sales.isNotEmpty ? totalRevenue / sales.length : 0.0;

    final Map<String, double> catShare = {};
    for (var s in sales) {
      for (var item in s.items) {
        String category = "General";
        try {
          final prod = service.products.firstWhere((p) => p.id == item.productId);
          category = prod.category;
        } catch (_) {}
        
        catShare[category] = (catShare[category] ?? 0.0) + (item.sellingPrice * item.quantity);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Business Analytics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.extrabold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Real-time overview of outlet sales, costs and profit metrics",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _buildStatCard(
                  title: "Total Revenue",
                  value: "$currency${totalRevenue.toStringAsFixed(2)}",
                  icon: Icons.pie_chart_rounded,
                  color: Colors.emerald,
                ),
                _buildStatCard(
                  title: "Net Profit Margin",
                  value: "$currency${totalProfit.toStringAsFixed(2)}",
                  icon: Icons.trending_up,
                  color: Colors.blueAccent,
                ),
                _buildStatCard(
                  title: "Gross Margin",
                  value: "${grossMarginPercentage.toStringAsFixed(1)}%",
                  icon: Icons.percent_rounded,
                  color: Colors.amber[800]!,
                ),
                _buildStatCard(
                  title: "Average Order Value",
                  value: "$currency${averageOrderValue.toStringAsFixed(2)}",
                  icon: Icons.receipt_long_rounded,
                  color: Colors.indigoAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Revenue Share by Category",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 24),
                          catShare.isEmpty
                              ? Container(
                                  height: 200,
                                  alignment: Alignment.center,
                                  child: const Text("Perform more transaction sales to view chart data", style: TextStyle(color: Color(0xFF94A3B8))),
                                )
                              : SizedBox(
                                  height: 220,
                                  child: PieChart(
                                    PieChartData(
                                      sections: catShare.entries.map((ent) {
                                        final colorsPalette = [
                                          Colors.emerald,
                                          Colors.blueAccent,
                                          Colors.amber,
                                          Colors.indigoAccent,
                                          Colors.pinkAccent,
                                          Colors.purple,
                                        ];
                                        final idx = catShare.keys.toList().indexOf(ent.key) % colorsPalette.length;

                                        return PieChartSectionData(
                                          value: ent.value,
                                          title: "${ent.key}\n${currency}${ent.value.toStringAsFixed(0)}",
                                          color: colorsPalette[idx],
                                          radius: 80,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        );
                                      }).toList(),
                                      centerSpaceRadius: 0,
                                      sectionsSpace: 2,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  flex: 2,
                  child: Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Product Stock Catalog Insights",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 16),
                          service.products.isEmpty
                              ? const SizedBox(
                                  height: 200,
                                  child: Center(child: Text("Empty stock inventory")),
                                )
                              : Container(
                                  constraints: const BoxConstraints(maxHeight: 250),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: (service.products.length).clamp(0, 5),
                                    itemBuilder: (context, idx) {
                                      final p = service.products[idx];
                                      final isLow = p.stock < 10;

                                      return Container(
                                        margin: const EdgeInsets.bottom(12),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                p.imageUrl,
                                                width: 36,
                                                height: 36,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                                  const SizedBox(height: 2),
                                                  Text("Selling Price: $currency${p.sellingPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isLow ? Colors.redAccent.withOpacity(0.1) : Colors.emerald.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "${p.stock} Units Left",
                                                style: TextStyle(
                                                  color: isLow ? Colors.redAccent : Colors.emerald,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.black, fontSize: 16, color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
