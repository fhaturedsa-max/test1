class SaleItem {
  final String productId;
  final String name;
  final int quantity;
  final double sellingPrice;
  final double costPrice;

  SaleItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.sellingPrice,
    required this.costPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'costPrice': costPrice,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Sale {
  final String id;
  final String userId;
  final List<SaleItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String timestamp;
  final double amountPaid;
  final double changeReturned;

  Sale({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.timestamp,
    required this.amountPaid,
    required this.changeReturned,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp,
      'amountPaid': amountPaid,
      'changeReturned': changeReturned,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: List<SaleItem>.from(
        (map['items'] as List<dynamic>?)?.map((x) => SaleItem.fromMap(x as Map<String, dynamic>)) ?? [],
      ),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      timestamp: map['timestamp'] ?? DateTime.now().toIso8601String(),
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      changeReturned: (map['changeReturned'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
