class BusinessProfile {
  final String userId;
  final String email;
  final String businessName;
  final String businessAddress;
  final String phone;
  final String currency;
  final double taxRate;

  BusinessProfile({
    required this.userId,
    required this.email,
    required this.businessName,
    required this.businessAddress,
    required this.phone,
    required this.currency,
    required this.taxRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'phone': phone,
      'currency': currency,
      'taxRate': taxRate,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      businessName: map['businessName'] ?? 'EasySell Store',
      businessAddress: map['businessAddress'] ?? '',
      phone: map['phone'] ?? '',
      currency: map['currency'] ?? r'$',
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 10.0,
    );
  }

  BusinessProfile copyWith({
    String? userId,
    String? email,
    String? businessName,
    String? businessAddress,
    String? phone,
    String? currency,
    double? taxRate,
  }) {
    return BusinessProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      phone: phone ?? this.phone,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}
