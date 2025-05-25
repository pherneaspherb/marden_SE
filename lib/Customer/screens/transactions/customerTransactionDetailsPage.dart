import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderType;

  static const _purpleColor = Color(0xFF4B007D);

  const TransactionDetailsPage({
    super.key,
    required this.orderData,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    // Parse timestamp (supporting Firestore Timestamp or DateTime)
    final timestampRaw = orderData['createdAt'] ?? orderData['timestamp'];
    final DateTime? dateTime = _parseTimestamp(timestampRaw);
    final formattedDate = dateTime != null
        ? DateFormat('dd MMM yyyy  hh:mm a').format(dateTime)
        : 'N/A';

    // Total amount differs by order type
    final totalAmount = (orderType.toLowerCase() == 'laundry')
        ? (orderData['totalAmount'] ?? 0)
        : (orderData['totalPrice'] ?? 0);

    const sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purple Header
            Container(
              decoration: const BoxDecoration(
                color: _purpleColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Transaction Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance IconButton width
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breakdown Section
                  const Text('Breakdown', style: sectionTitleStyle),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),

                  // Conditional details based on order type
                  if (orderType.toLowerCase() == 'laundry') ..._buildLaundryDetails(),
                  if (orderType.toLowerCase() == 'water') ..._buildWaterDetails(),

                  const SizedBox(height: 24),

                  // Order Details Section
                  const Text('Order Details', style: sectionTitleStyle),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),

                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  // Total Paid Container
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL PAID:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₱${(totalAmount as num).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to parse Firestore Timestamp or DateTime
  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    try {
      // Firestore Timestamp has toDate()
      final toDateMethod = timestamp.toDate;
      if (toDateMethod is Function) {
        return timestamp.toDate();
      }
    } catch (_) {}
    return null;
  }

  /// Builds laundry-specific details with prices
  List<Widget> _buildLaundryDetails() {
    final List<Widget> widgets = [];

    // Show services with prices
    if (orderData['services'] != null && orderData['services'] is List) {
      for (var service in orderData['services']) {
        final name = service['name'] ?? 'Service';
        final price = service['price'] ?? 0;
        widgets.add(_buildServicePriceRow(name, price));
      }
    } else {
      // fallback if no list, just show serviceType without price
      widgets.add(_buildDetailRow('Service', orderData['serviceType'] ?? 'Laundry'));
    }

    // Show extras with prices if present
    if (orderData['extras'] != null && orderData['extras'] is List && (orderData['extras'] as List).isNotEmpty) {
      for (var extra in orderData['extras']) {
        if (extra is Map<String, dynamic>) {
          final name = extra['name'] ?? 'Extra';
          final price = extra['price'] ?? 0;
          widgets.add(_buildServicePriceRow(name, price));
        } else if (extra is String) {
          // if extras is just a list of strings without price
          widgets.add(_buildDetailRow('Extra', extra));
        }
      }
    }

    if (orderData['weight'] != null) {
      widgets.add(_buildDetailRow('Weight', '${orderData['weight']} kg'));
    }

    if (orderData['deliveryMode'] != null) {
      widgets.add(_buildDetailRow('Delivery Mode', orderData['deliveryMode']));
    }

    return widgets;
  }

  /// Builds water-specific details with prices
  List<Widget> _buildWaterDetails() {
    final List<Widget> widgets = [];

    // Show types with prices if available
    if (orderData['items'] != null && orderData['items'] is List) {
      for (var item in orderData['items']) {
        final name = item['name'] ?? 'Water';
        final price = item['price'] ?? 0;
        final quantity = item['quantity'] ?? 1;
        widgets.add(_buildServicePriceRow('$name x $quantity', price * quantity));
      }
    } else {
      // fallback if no items list, just show type without price
      widgets.add(_buildDetailRow('Type', orderData['type'] ?? 'Water'));
    }

    if (orderData['containerType'] != null) {
      widgets.add(_buildDetailRow('Container Type', orderData['containerType']));
    }

    if (orderData['deliveryMode'] != null) {
      widgets.add(_buildDetailRow('Delivery Mode', orderData['deliveryMode']));
    }

    return widgets;
  }

  /// Helper method to build label-value row (for non-price fields)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build service/extra + price row
  Widget _buildServicePriceRow(String service, num price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          Text(
            '₱${price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
