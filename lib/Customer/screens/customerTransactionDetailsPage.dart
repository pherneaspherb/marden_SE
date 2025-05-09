import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderType;

  const TransactionDetailsPage({
    required this.orderData,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: $orderType', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Amount: ₱${orderData['totalAmount'] ?? 'N/A'}'),
            SizedBox(height: 10),
            Text('Date: ${orderData['timestamp'].toDate()}'),
            SizedBox(height: 10),
            Text('Address: ${orderData['address'] ?? 'N/A'}'),
            SizedBox(height: 10),
            Text('Payment Method: ${orderData['paymentMethod'] ?? 'N/A'}'),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
