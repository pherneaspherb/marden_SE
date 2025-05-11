import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final bool isLaundryOrder;

  const ReceiptPage({
    Key? key,
    required this.orderData,
    required this.isLaundryOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timestamp = orderData['createdAt'] != null
        ? (orderData['createdAt'] as Timestamp).toDate()
        : null;
    final totalAmount = isLaundryOrder
        ? orderData['totalAmount'] ?? 0.0
        : orderData['totalPrice'] ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Thank you for being\nwith us.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // Total Paid
              const Text(
                'TOTAL PAID:',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              Text(
                '₱${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B007D),
                ),
              ),
              const SizedBox(height: 30),

              // Breakdown
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              if (isLaundryOrder) ...[
                _buildBreakdownItem(
                  title: 'Service',
                  value: orderData['serviceType'] ?? 'Laundry Service',
                  subValue: orderData['subService'],
                ),
                _buildBreakdownItem(
                  title: 'Extras',
                  value: (orderData['extras'] as List?)?.join(', ') ?? 'None',
                ),
                _buildBreakdownItem(
                  title: 'Weight',
                  value: orderData['weight'] != null
                      ? '${orderData['weight']}kg'
                      : 'N/A',
                ),
              ] else ...[
                _buildBreakdownItem(
                  title: 'Type',
                  value: orderData['type'] ?? 'Water',
                ),
                _buildBreakdownItem(
                  title: 'Quantity',
                  value: '${orderData['quantity'] ?? 0} containers',
                ),
                _buildBreakdownItem(
                  title: 'Container',
                  value: orderData['containerType'] ?? 'N/A',
                ),
                _buildBreakdownItem(
                  title: 'Delivery',
                  value: orderData['deliveryMode'] ?? 'N/A',
                ),
              ],

              const Divider(height: 30),
              _buildBreakdownItem(
                title: 'Total',
                value: '₱${totalAmount.toStringAsFixed(2)}',
                isTotal: true,
              ),
              const SizedBox(height: 30),

              // Order Details
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                timestamp != null
                    ? DateFormat('dd MMM yyyy  hh:mm a').format(timestamp)
                    : 'No date',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              // Download Receipt Button
              ElevatedButton(
                onPressed: () {
                  // Implement download functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B007D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Download Receipt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownItem({
    required String title,
    required String value,
    String? subValue,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: subValue != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    color: isTotal ? const Color(0xFF4B007D) : Colors.black,
                  ),
                ),
                if (subValue != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      subValue,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}