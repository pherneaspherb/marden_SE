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

    final normalizedOrderType =
        orderType.toLowerCase().contains('laundry')
            ? 'laundry'
            : orderType.toLowerCase().contains('water')
            ? 'waterOrders'
            : orderType.toLowerCase();

    final firstNameFallback = orderData['firstName']?.toString() ?? '';
    final lastNameFallback = orderData['lastName']?.toString() ?? '';
    final customerNameFallback =
        (firstNameFallback + ' ' + lastNameFallback).trim();

    final status =
        orderData['status']?.toString().toLowerCase() ?? 'processing';

    final extrasList = (orderData['extras'] as List<dynamic>?);
    final availedExtras =
        extrasList != null
            ? extrasList.where((e) => e.toString().trim().isNotEmpty).toList()
            : <dynamic>[];

    final containerType = orderData['containerType']?.toString() ?? '';

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
                  SizedBox(width: 48),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),

                  Text('Breakdown', style: sectionTitleStyle),
                  Divider(thickness: 1),
                  SizedBox(height: 8),

                  if (normalizedOrderType == 'laundry') ...[
                    if ((orderData['serviceType']?.toString().isNotEmpty ??
                        false))
                      _buildDetailRow(
                        'Service',
                        orderData['serviceType'].toString(),
                      ),

                    if (availedExtras.isNotEmpty)
                      _buildDetailRow('Others', availedExtras.join(', ')),

                    if ((orderData['weight'] ?? 0) > 0)
                      _buildDetailRow('Weight', '${orderData['weight']}kg'),

                    if (orderData['selectedServices'] != null &&
                        orderData['selectedServices'] is List &&
                        (orderData['selectedServices'] as List).isNotEmpty)
                      ...(orderData['selectedServices'] as List<dynamic>)
                          .where(
                            (service) =>
                                service is String && service.trim().isNotEmpty,
                          )
                          .map<Widget>((service) {
                            final price =
                                orderData['laundryServices'] != null &&
                                        orderData['laundryServices'] is Map &&
                                        (orderData['laundryServices'] as Map)
                                            .containsKey(service)
                                    ? (orderData['laundryServices']
                                            as Map)[service] ??
                                        0
                                    : 0;
                            return _buildDetailRow(
                              service,
                              '₱${NumberFormat('#,##0.00').format(price)}',
                            );
                          }),
                  ],

                  if (normalizedOrderType == 'waterOrders') ...[
                    if (containerType.isNotEmpty)
                      _buildDetailRow('Container Type', containerType),

                    if ((orderData['quantity'] ?? 0) > 0)
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

                  Text('Details', style: sectionTitleStyle),
                  Divider(thickness: 1),
                  SizedBox(height: 8),

                  FutureBuilder<DocumentSnapshot>(
                    future:
                        uid == null
                            ? Future.value(null)
                            : FirebaseFirestore.instance
                                .collection('customers')
                                .doc(uid)
                                .get(),
                    builder: (context, snapshot) {
                      final customerName =
                          snapshot.hasData && snapshot.data!.exists
                              ? ((orderData['firstName'] ??
                                          snapshot.data!['firstName'] ??
                                          '') +
                                      ' ' +
                                      (orderData['lastName'] ??
                                          snapshot.data!['lastName'] ??
                                          ''))
                                  .trim()
                              : customerNameFallback;
                      return _buildDetailRow(
                        'Name',
                        customerName.isNotEmpty
                            ? customerName
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
                      return _buildDetailRow(
                        'Address',
                        _getAddress(
                          orderData,
                          snapshot.hasData
                              ? snapshot.data?.data() as Map<String, dynamic>?
                              : null,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  
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
                          _buildFormattedTotal(orderData),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

  String _buildFormattedTotal(Map<String, dynamic> data) {
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

    Map<String, dynamic>? addressMap;
    if (address is Map) {
      addressMap = Map<String, dynamic>.from(address);
    } else if (userData != null && userData['defaultAddress'] is Map) {
      addressMap = Map<String, dynamic>.from(userData['defaultAddress']);
    }

    if (addressMap != null) {
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
