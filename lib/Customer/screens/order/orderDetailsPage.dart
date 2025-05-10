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

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('customers').doc(uid).get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        final firstName = orderData['firstName']?.toString() ?? userData?['firstName']?.toString() ?? '';
        final lastName = orderData['lastName']?.toString() ?? userData?['lastName']?.toString() ?? '';
        final customerName = (firstName + ' ' + lastName).trim().isNotEmpty
            ? (firstName + ' ' + lastName).trim()
            : 'Customer Name';

        final status = orderData['status']?.toString()?.toLowerCase() ?? 'processing';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF4B007D),
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              'Order Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        _getStatusMessage(status),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      if (orderData['orderNumber'] != null)
                        Text(
                          'ORDER #${orderData['orderNumber']}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text('Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildDetailRow('Service', orderData['serviceType']?.toString() ?? ''),
                if (orderType == 'laundry') ...[
                  if ((orderData['extras'] as List<dynamic>?)?.isNotEmpty ?? false)
                    _buildDetailRow('Others', (orderData['extras'] as List<dynamic>).join(', ')),
                  if (orderData['weight'] != null)
                    _buildDetailRow('Weight', '${orderData['weight']}kg'),
                ],
                if (orderType == 'water') ...[
                  if (orderData['containerType']?.toString().isNotEmpty ?? false)
                    _buildDetailRow('Container Type', orderData['containerType']),
                  if (orderData['quantity'] != null)
                    _buildDetailRow('Quantity', orderData['quantity'].toString()),
                ],
                if (orderData['deliveryMode']?.toString().isNotEmpty ?? false)
                  _buildDetailRow('Delivery Mode', orderData['deliveryMode'].toString()),
                if (orderData['instructions']?.toString().isNotEmpty ?? false)
                  _buildDetailRow('Instructions', orderData['instructions'].toString()),
                if (orderData['paymentMethod']?.toString().isNotEmpty ?? false)
                  _buildDetailRow('Payment Method', orderData['paymentMethod'].toString()),
                SizedBox(height: 16),
                Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildDetailRow('Name', customerName),
                _buildDetailRow('Address', _getAddress(orderData, userData)),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('TOTAL :', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      SizedBox(height: 4),
                      Text(
                        '₱${NumberFormat('#,##0.00').format(orderData['totalAmount'] ?? orderData['totalPrice'] ?? 0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B007D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getAddress(Map<String, dynamic> orderData, Map<String, dynamic>? userData) {
    final address = orderData['address'];

    if (address is Map) {
      final addressMap = Map<String, dynamic>.from(address);
      final components = [
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

    // Use fallback from user data
    final fallbackAddress = userData?['defaultAddress'];
    if (fallbackAddress is Map) {
      final fallbackMap = Map<String, dynamic>.from(fallbackAddress);
      final components = [
        fallbackMap['street'],
        fallbackMap['house'],
        fallbackMap['barangay'],
        fallbackMap['municipality'],
        fallbackMap['city'],
      ].where((c) => c != null && c.toString().isNotEmpty).toList();
      return components.join(', ');
    } else if (fallbackAddress is String && fallbackAddress.trim().isNotEmpty) {
      return fallbackAddress;
    }

    return 'No Address Provided';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your order is pending.';
      case 'processing':
        return 'Your order is being processed.';
      case 'completed':
        return 'Your order has been completed.';
      case 'delivered':
        return 'Your order has been delivered.';
      case 'cancelled':
        return 'Your order has been cancelled.';
      default:
        return 'Order Status: $status';
    }
  }
}
