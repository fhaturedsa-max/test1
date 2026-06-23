class Product {
  final String id;
  final String userId;
  final String name;
  final String sku;
  final String barcode;
  final String category;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final String imageUrl;
  final String updatedAt;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.category,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    required this.imageUrl,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'imageUrl': imageUrl,
      'updatedAt': updatedAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      barcode: map['barcode'] ?? '',
      category: map['category'] ?? 'General',
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      updatedAt: map['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Product copyWith({
    String? id,
    String? userId,
    String? name,
    String? sku,
    String? barcode,
    String? category,
    double? costPrice,
    double? sellingPrice,
    int? stock,
    String? imageUrl,
    String? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
