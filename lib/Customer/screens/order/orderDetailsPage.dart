import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderType;

  const OrderDetailsPage({
    Key? key,
    required this.orderData,
    required this.orderType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Fallback customer name from orderData (to show immediately)
    final firstNameFallback = orderData['firstName']?.toString() ?? '';
    final lastNameFallback = orderData['lastName']?.toString() ?? '';
    final customerNameFallback =
        (firstNameFallback + ' ' + lastNameFallback).trim();

    final status =
        orderData['status']?.toString().toLowerCase() ?? 'processing';

    // Text style
    final sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Section
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF4B007D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      _getStatusMessage(status),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // To balance IconButton spacing
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),

                  // Breakdown Section
                  Text('Breakdown', style: sectionTitleStyle),
                  Divider(thickness: 1),
                  SizedBox(height: 8),

                  _buildDetailRow(
                    'Service',
                    orderData['serviceType']?.toString() ?? '',
                  ),
                  if (orderType == 'laundry') ...[
                    if ((orderData['extras'] as List<dynamic>?)?.isNotEmpty ??
                        false)
                      _buildDetailRow(
                        'Others',
                        (orderData['extras'] as List<dynamic>).join(', '),
                      ),
                    if (orderData['weight'] != null)
                      _buildDetailRow('Weight', '${orderData['weight']}kg'),
                  ],
                  if (orderType == 'waterOrders') ...[
                    if (orderData['containerType']?.toString().isNotEmpty ??
                        false)
                      _buildDetailRow(
                        'Container Type',
                        orderData['containerType'],
                      ),
                    if (orderData['quantity'] != null)
                      _buildDetailRow(
                        'Quantity',
                        orderData['quantity'].toString(),
                      ),
                  ],
                  if (orderData['deliveryMode']?.toString().isNotEmpty ?? false)
                    _buildDetailRow(
                      'Delivery Mode',
                      orderData['deliveryMode'].toString(),
                    ),
                  if (orderData['instructions']?.toString().isNotEmpty ?? false)
                    _buildDetailRow(
                      'Instructions',
                      orderData['instructions'].toString(),
                    ),
                  if (orderData['paymentMethod']?.toString().isNotEmpty ??
                      false)
                    _buildDetailRow(
                      'Payment Method',
                      orderData['paymentMethod'].toString(),
                    ),

                  SizedBox(height: 24),

                  // Details Section
                  Text('Details', style: sectionTitleStyle),
                  Divider(thickness: 1),
                  SizedBox(height: 8),

                  // Customer Name: FutureBuilder only for the name widget
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        uid == null
                            ? Future.value(null)
                            : FirebaseFirestore.instance
                                .collection('customers')
                                .doc(uid)
                                .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildDetailRow(
                          'Name',
                          customerNameFallback.isNotEmpty
                              ? customerNameFallback
                              : 'Loading name...',
                        );
                      }
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final firstName =
                            orderData['firstName']?.toString() ??
                            userData['firstName']?.toString() ??
                            '';
                        final lastName =
                            orderData['lastName']?.toString() ??
                            userData['lastName']?.toString() ??
                            '';
                        final customerName =
                            (firstName + ' ' + lastName).trim();
                        return _buildDetailRow('Name', customerName);
                      }
                      return _buildDetailRow(
                        'Name',
                        customerNameFallback.isNotEmpty
                            ? customerNameFallback
                            : 'Name not available',
                      );
                    },
                  ),

                  FutureBuilder<DocumentSnapshot>(
                    future:
                        uid == null
                            ? Future.value(null)
                            : FirebaseFirestore.instance
                                .collection('customers')
                                .doc(uid)
                                .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildDetailRow('Address', 'Loading address...');
                      }
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return _buildDetailRow(
                          'Address',
                          _getAddress(orderData, userData),
                        );
                      }
                      return _buildDetailRow(
                        'Address',
                        _getAddress(orderData, null),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Total Amount
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL :',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _buildFormattedTotal(orderData, orderType),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _buildFormattedTotal(Map<String, dynamic> data, String orderType) {
    double total = 0;

    final priceRaw = data['totalPrice'] ?? data['totalAmount'];

    if (priceRaw is int) {
      total = priceRaw.toDouble();
    } else if (priceRaw is double) {
      total = priceRaw;
    } else if (priceRaw is String) {
      total = double.tryParse(priceRaw) ?? 0;
    }

    return '₱${NumberFormat('#,##0.00').format(total)}';
  }

  String _getAddress(
    Map<String, dynamic> orderData,
    Map<String, dynamic>? userData,
  ) {
    final address = orderData['defaultAddress'];

    if (address is Map) {
      final addressMap = Map<String, dynamic>.from(address);
      final components =
          [
            addressMap['street'],
            addressMap['house'],
            addressMap['barangay'],
            addressMap['municipality'],
            addressMap['city'],
          ].where((c) => c != null && c.toString().isNotEmpty).toList();
      return components.join(', ');
    }

    if (address is String && address.trim().length > 10) {
      return address;
    }

    // fallback
    if (userData != null) {
      final fallbackAddress = userData['defaultAddress'];
      if (fallbackAddress is Map) {
        final fallbackMap = Map<String, dynamic>.from(fallbackAddress);
        final components =
            [
              fallbackMap['street'],
              fallbackMap['house'],
              fallbackMap['barangay'],
              fallbackMap['municipality'],
              fallbackMap['city'],
            ].where((c) => c != null && c.toString().isNotEmpty).toList();
        return components.join(', ');
      } else if (fallbackAddress is String &&
          fallbackAddress.trim().isNotEmpty) {
        return fallbackAddress;
      }
    }

    return 'No Address Provided';
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your order is pending';
      case 'processing':
        return 'Your order is being processed';
      case 'completed':
        return 'Your order has been completed';
      case 'delivered':
        return 'Your order has been delivered';
      case 'cancelled':
        return 'Your order has been cancelled';
      default:
        return 'Order Status: $status';
    }
  }
}
