import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/business_profile.dart';
import '../models/product.dart';
import '../models/sale.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  BusinessProfile? _profile;
  List<Product> _products = [];
  List<Sale> _sales = [];
  bool _isLoading = true;
  bool _isSandbox = false;
  bool _isSyncing = false;

  StreamSubscription? _productsSubscription;
  StreamSubscription? _salesSubscription;

  User? get user => _user;
  BusinessProfile? get profile => _profile;
  List<Product> get products => _products;
  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  bool get isSandbox => _isSandbox;
  bool get isSyncing => _isSyncing;

  FirebaseService() {
    _init();
  }

  Future<void> _init() async {
    var box = await Hive.openBox('easysell_cache');
    final isSandboxCached = box.get('is_sandbox', defaultValue: false);

    if (isSandboxCached) {
      _isSandbox = true;
      final sandboxUserId = box.get('sandbox_uid', defaultValue: 'sandbox_user');
      
      _profile = BusinessProfile(
        userId: sandboxUserId,
        email: 'guest@saribulan.pos',
        businessName: box.get('business_name', defaultValue: 'Sari Bulan Guest Outlet'),
        businessAddress: box.get('business_address', defaultValue: 'Suite 101, Retail Hub Plaza'),
        phone: box.get('business_phone', defaultValue: '+99 555 1010'),
        currency: box.get('business_currency', defaultValue: r'$'),
        taxRate: box.get('business_tax', defaultValue: 10.0),
      );

      _user = null;
      _isLoading = false;
      notifyListeners();
      _loadSandboxData(sandboxUserId);
    } else {
      _auth.authStateChanges().listen((User? user) async {
        _user = user;
        if (user != null) {
          _isSandbox = false;
          await loadUserProfile(user.uid);
          _listenToCloudData(user.uid);
        } else {
          _profile = null;
          _products = [];
          _sales = [];
          _cancelSubscriptions();
        }
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<void> loadUserProfile(String uid) async {
    try {
      final docSnap = await _db.collection('users').doc(uid).get();
      if (docSnap.exists) {
        _profile = BusinessProfile.fromMap(docSnap.data()!);
      } else {
        final defaultProfile = BusinessProfile(
          userId: uid,
          email: _auth.currentUser?.email ?? 'outlet@saribulan.pos',
          businessName: 'CV. SARI BULAN Outlet',
          businessAddress: 'No. 1 Retail Center Plaza',
          phone: '+1 (555) 0184',
          currency: r'$',
          taxRate: 10.0,
        );
        await _db.collection('users').doc(uid).set(defaultProfile.toMap());
        _profile = defaultProfile;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading user parameters: $e");
    }
  }

  Future<void> loginAsGuest() async {
    _isSandbox = true;
    _user = null;
    
    var box = await Hive.openBox('easysell_cache');
    await box.put('is_sandbox', true);
    await box.put('sandbox_uid', 'sandbox_user');

    _profile = BusinessProfile(
      userId: 'sandbox_user',
      email: 'guest@saribulan.com',
      businessName: 'Sari Bulan Guest Outlet',
      businessAddress: 'Suite 101, Retail Hub Plaza',
      phone: '+44 020 7496',
      currency: r'$',
      taxRate: 10.0,
    );

    _isLoading = false;
    notifyListeners();
    await _loadSandboxData('sandbox_user');
  }

  void _listenToCloudData(String uid) {
    _cancelSubscriptions();
    _isSyncing = true;
    notifyListeners();

    _productsSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('products')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
      
      if (_products.isEmpty) {
        seedInitialProducts();
      }
      _isSyncing = false;
      notifyListeners();
    }, onError: (err) {
      debugPrint("Error loading catalog: $err");
      _isSyncing = false;
      notifyListeners();
    });

    _salesSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('sales')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _sales = snapshot.docs.map((doc) => Sale.fromMap(doc.data())).toList();
      notifyListeners();
    }, onError: (err) {
      debugPrint("Error loading sale receipts: $err");
    });
  }

  Future<void> seedInitialProducts() async {
    final uid = _isSandbox ? 'sandbox_user' : _user?.uid;
    if (uid == null) return;

    final defaults = [
      Product(
        id: 'prod_1',
        userId: uid,
        name: 'Organic Whole Espresso Beans',
        sku: 'OEB-500G',
        barcode: '840129038',
        category: 'Coffee & Brews',
        costPrice: 8.50,
        sellingPrice: 16.00,
        stock: 45,
        imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?q=80&w=300&auto=format&fit=crop',
        updatedAt: DateTime.now().toIso8601String(),
      ),
      Product(
        id: 'prod_2',
        userId: uid,
        name: 'Barista Oat Milk (Premium)',
        sku: 'BOM-1L',
        barcode: '320145920',
        category: 'Beverage Mixers',
        costPrice: 1.80,
        sellingPrice: 4.50,
        stock: 120,
        imageUrl: 'https://images.unsplash.com/photo-1596431760011-5544d0d1b94d?q=80&w=300&auto=format&fit=crop',
        updatedAt: DateTime.now().toIso8601String(),
      ),
      Product(
        id: 'prod_3',
        userId: uid,
        name: 'Raw Honey Squeeze Bottle',
        sku: 'RHB-350G',
        barcode: '592015849',
        category: 'Condiments',
        costPrice: 3.20,
        sellingPrice: 7.95,
        stock: 30,
        imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?q=80&w=300&auto=format&fit=crop',
        updatedAt: DateTime.now().toIso8601String(),
      ),
      Product(
        id: 'prod_4',
        userId: uid,
        name: 'Double Choc SoftBaked Cookie',
        sku: 'DCC-90G',
        barcode: '741295031',
        category: 'Breads & Cakes',
        costPrice: 0.90,
        sellingPrice: 2.50,
        stock: 65,
        imageUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?q=80&w=300&auto=format&fit=crop',
        updatedAt: DateTime.now().toIso8601String(),
      ),
      Product(
        id: 'prod_5',
        userId: uid,
        name: 'Reusable Stainless Straw Straw',
        sku: 'RSS-6P',
        barcode: '661029158',
        category: 'Accessories',
        costPrice: 4.00,
        sellingPrice: 12.00,
        stock: 18,
        imageUrl: 'https://images.unsplash.com/photo-1574102604677-494dff9da3e1?q=80&w=300&auto=format&fit=crop',
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];

    if (_isSandbox) {
      _products = defaults;
      await _saveSandboxProductsToDisk();
    } else {
      for (var p in defaults) {
        await _db
            .collection('users')
            .doc(uid)
            .collection('products')
            .doc(p.id)
            .set(p.toMap());
      }
    }
    notifyListeners();
  }

  Future<void> _loadSandboxData(String sandboxUid) async {
    var productsBox = await Hive.openBox('easysell_sandbox_products');
    var salesBox = await Hive.openBox('easysell_sandbox_sales');

    if (productsBox.isEmpty) {
      await seedInitialProducts();
    } else {
      _products = productsBox.values.map((v) => Product.fromMap(Map<String, dynamic>.from(v))).toList();
    }

    if (salesBox.isNotEmpty) {
      _sales = salesBox.values.map((v) => Sale.fromMap(Map<String, dynamic>.from(v))).toList();
      _sales.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else {
      _sales = [];
    }
    notifyListeners();
  }

  Future<void> _saveSandboxProductsToDisk() async {
    var productsBox = await Hive.openBox('easysell_sandbox_products');
    await productsBox.clear();
    for (var p in _products) {
      await productsBox.put(p.id, p.toMap());
    }
  }

  Future<void> _saveSandboxSalesToDisk() async {
    var salesBox = await Hive.openBox('easysell_sandbox_sales');
    await salesBox.clear();
    for (var s in _sales) {
      await salesBox.put(s.id, s.toMap());
    }
  }

  Future<void> addProduct(String name, String sku, String barcode, String category, double cost, double sell, int stock, String imageUrl) async {
    final uid = _isSandbox ? 'sandbox_user' : _user?.uid;
    if (uid == null) return;

    final newId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
    final product = Product(
      id: newId,
      userId: uid,
      name: name,
      sku: sku,
      barcode: barcode,
      category: category,
      costPrice: cost,
      sellingPrice: sell,
      stock: stock,
      imageUrl: imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=300&auto=format&fit=crop' : imageUrl,
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (_isSandbox) {
      _products.insert(0, product);
      await _saveSandboxProductsToDisk();
      notifyListeners();
    } else {
      await _db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(newId)
          .set(product.toMap());
    }
  }

  Future<void> updateProduct(Product updated) async {
    final uid = _isSandbox ? 'sandbox_user' : _user?.uid;
    if (uid == null) return;

    final newer = updated.copyWith(updatedAt: DateTime.now().toIso8601String());

    if (_isSandbox) {
      final index = _products.indexWhere((p) => p.id == updated.id);
      if (index >= 0) {
        _products[index] = newer;
        await _saveSandboxProductsToDisk();
        notifyListeners();
      }
    } else {
      await _db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(updated.id)
          .set(newer.toMap());
    }
  }

  Future<void> deleteProduct(String productId) async {
    final uid = _isSandbox ? 'sandbox_user' : _user?.uid;
    if (uid == null) return;

    if (_isSandbox) {
      _products.removeWhere((p) => p.id == productId);
      await _saveSandboxProductsToDisk();
      notifyListeners();
    } else {
      await _db
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(productId)
          .delete();
    }
  }

  Future<void> checkout(List<SaleItem> items, double subtotal, double tax, double discount, double total, String method, double paid, double change) async {
    final uid = _isSandbox ? 'sandbox_user' : _user?.uid;
    if (uid == null || _profile == null) return;

    final invoiceId = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    final freshSale = Sale(
      id: invoiceId,
      userId: uid,
      items: items,
      subtotal: subtotal,
      taxAmount: tax,
      discountAmount: discount,
      totalAmount: total,
      paymentMethod: method,
      timestamp: DateTime.now().toIso8601String(),
      amountPaid: paid,
      changeReturned: change,
    );

    if (_isSandbox) {
      _sales.insert(0, freshSale);
      await _saveSandboxSalesToDisk();

      for (var sold in items) {
        final prodIdx = _products.indexWhere((p) => p.id == sold.productId);
        if (prodIdx >= 0) {
          final prod = _products[prodIdx];
          final newStock = (prod.stock - sold.quantity).clamp(0, 99999);
          _products[prodIdx] = prod.copyWith(stock: newStock);
        }
      }
      await _saveSandboxProductsToDisk();
      notifyListeners();
    } else {
      final batch = _db.batch();

      final saleRef = _db.collection('users').doc(uid).collection('sales').doc(invoiceId);
      batch.set(saleRef, freshSale.toMap());

      for (var sold in items) {
        final docRef = _db.collection('users').doc(uid).collection('products').doc(sold.productId);
        batch.update(docRef, {
          'stock': FieldValue.increment(-sold.quantity),
          'updatedAt': DateTime.now().toIso8601String()
        });
      }

      await batch.commit();
    }
  }

  Future<void> refundTransaction(Sale sale) async {
    final uid = _isSandbox ? 'sandbox_user' : _user?.uid;
    if (uid == null) return;

    if (_isSandbox) {
      _sales.removeWhere((s) => s.id == sale.id);
      await _saveSandboxSalesToDisk();

      for (var item in sale.items) {
        final prodIdx = _products.indexWhere((p) => p.id == item.productId);
        if (prodIdx >= 0) {
          final prod = _products[prodIdx];
          _products[prodIdx] = prod.copyWith(stock: prod.stock + item.quantity);
        }
      }
      await _saveSandboxProductsToDisk();
      notifyListeners();
    } else {
      final batch = _db.batch();

      final saleRef = _db.collection('users').doc(uid).collection('sales').doc(sale.id);
      batch.delete(saleRef);

      for (var item in sale.items) {
        final docRef = _db.collection('users').doc(uid).collection('products').doc(item.productId);
        batch.update(docRef, {
          'stock': FieldValue.increment(item.quantity),
          'updatedAt': DateTime.now().toIso8601String()
        });
      }

      await batch.commit();
    }
  }

  Future<void> updateSettings(String name, String address, String phone, String currency, double tax) async {
    final uid = _isSandbox ? 'sandbox_user' : _user?.uid;
    if (uid == null || _profile == null) return;

    final updated = _profile!.copyWith(
      businessName: name,
      businessAddress: address,
      phone: phone,
      currency: currency,
      taxRate: tax,
    );

    if (_isSandbox) {
      _profile = updated;
      var box = await Hive.openBox('easysell_cache');
      await box.put('business_name', name);
      await box.put('business_address', address);
      await box.put('business_phone', phone);
      await box.put('business_currency', currency);
      await box.put('business_tax', tax);
      notifyListeners();
    } else {
      await _db.collection('users').doc(uid).set(updated.toMap());
      _profile = updated;
      notifyListeners();
    }
  }

  Future<void> disconnectAll() async {
    _cancelSubscriptions();
    _isSandbox = false;

    var box = await Hive.openBox('easysell_cache');
    await box.delete('is_sandbox');
    await box.delete('sandbox_uid');

    if (_auth.currentUser != null) {
      await _auth.signOut();
    }

    _user = null;
    _profile = null;
    _products = [];
    _sales = [];
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _productsSubscription?.cancel();
    _salesSubscription?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
