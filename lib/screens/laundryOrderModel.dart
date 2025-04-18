class LaundryOrder {
  final String serviceType;
  final List<String> extras;
  final double weight;
  final String deliveryMode;
  final String address;
  final String barangay;
  final String municipality;
  final String city;
  final String paymentMethod;
  final String instructions;
  final double totalAmount;
  final DateTime createdAt;

  LaundryOrder({
    required this.serviceType,
    required this.extras,
    required this.weight,
    required this.deliveryMode,
    required this.address,
    required this.barangay,
    required this.municipality,
    required this.city,
    required this.paymentMethod,
    required this.instructions,
    required this.totalAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceType': serviceType,
      'extras': extras,
      'weight': weight,
      'deliveryMode': deliveryMode,
      'address': address,
      'barangay': barangay,
      'municipality': municipality,
      'city': city,
      'paymentMethod': paymentMethod,
      'instructions': instructions,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
