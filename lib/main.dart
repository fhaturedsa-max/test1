import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/firebase_service.dart';
import 'screens/login_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('easysell_cache');
  await Hive.openBox('easysell_sandbox_products');
  await Hive.openBox('easysell_sandbox_sales');

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase bootstrap skipped or offline: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseService()),
      ],
      child: const SariBulanApp(),
    ),
  );
}

class SariBulanApp extends StatelessWidget {
  const SariBulanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV. SARI BULAN POS Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.emerald,
          brightness: Brightness.light,
          primary: Colors.emerald,
          background: const Color(0xFFF8FAFC),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
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
      home: const AuthRouteGate(),
    );
  }
}

class AuthRouteGate extends StatelessWidget {
  const AuthRouteGate({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);

    if (service.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, color: Colors.emerald, size: 48),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Colors.emerald),
              SizedBox(height: 12),
              Text(
                "Loading terminal configurations...",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      );
    }

    if (service.user == null && !service.isSandbox) {
      return const LoginScreen();
    }

    return const TerminalDashboardWrapper();
  }
}

class TerminalDashboardWrapper extends StatefulWidget {
  const TerminalDashboardWrapper({super.key});

  @override
  State<TerminalDashboardWrapper> createState() => _TerminalDashboardWrapperState();
}

class _TerminalDashboardWrapperState extends State<TerminalDashboardWrapper> {
  int _activeTabIndex = 0;

  final List<Widget> _views = [
    const CheckoutScreen(),
    const InventoryScreen(),
    const AnalyticsScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);
    final profile = service.profile;

    final isSandbox = service.isSandbox;
    final outletName = profile?.businessName ?? "CV. SARI BULAN Outlet";
    final outletTax = profile?.taxRate ?? 10.0;
    final outletCurrency = profile?.currency ?? r"$";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.emerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.emerald, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Sari ",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.black),
                    ),
                    const Text(
                      "Bulan",
                      style: TextStyle(color: Colors.emerald, fontSize: 16, fontWeight: FontWeight.black),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSandbox ? Colors.indigoAccent.withOpacity(0.1) : Colors.emerald.withOpacity(0.1),
                        border: Border.all(color: isSandbox ? Colors.indigoAccent.withOpacity(0.2) : Colors.emerald.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isSandbox ? "Guest Demo" : "Sync Live",
                        style: TextStyle(
                          color: isSandbox ? Colors.indigoAccent : Colors.emerald,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "$outletName (Tax $outletTax%, Cur $outletCurrency)",
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _buildSyncIndicator(service),
          const SizedBox(width: 16),
          _buildLogoutButton(context, service),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _activeTabIndex,
            onDestinationSelected: (idx) {
              setState(() {
                _activeTabIndex = idx;
              });
            },
            backgroundColor: Colors.white,
            elevation: 1,
            labelType: NavigationRailLabelType.all,
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.black, fontSize: 12),
            unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11),
            selectedIconTheme: const IconThemeData(color: Colors.emerald),
            unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart_rounded),
                label: Text("Register"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.layers_outlined),
                selectedIcon: Icon(Icons.layers_rounded),
                label: Text("Inventory"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded),
                label: Text("Insights"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: Text("Receipts"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: Text("Settings"),
              ),
            ],
          ),
          Expanded(
            child: _views[_activeTabIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator(FirebaseService service) {
    if (service.isSyncing) {
      return const Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.emerald),
          ),
          SizedBox(width: 6),
          Text(
            "Syncing...",
            style: TextStyle(color: Colors.emerald, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
    return const Row(
      children: [
        Icon(Icons.check_circle_rounded, color: Colors.emerald, size: 14),
        SizedBox(width: 6),
        Text(
          "Updated Live",
          style: TextStyle(color: Colors.emerald, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, FirebaseService service) {
    return ElevatedButton.icon(
      onPressed: () async {
        await service.disconnectAll();
      },
      icon: const Icon(Icons.logout_rounded, size: 12),
      label: const Text("Sign Out"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );
  }
}
