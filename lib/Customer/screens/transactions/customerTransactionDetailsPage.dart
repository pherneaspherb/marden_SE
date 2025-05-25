import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String orderType;

  const TransactionDetailsPage({
    super.key,
    required this.orderData,
    required this.orderType,
  });

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  static const _purpleColor = Color(0xFF4B007D);
  Map<String, dynamic> servicePrices = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServicePrices();
  }

  Future<void> _fetchServicePrices() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(widget.orderType.toLowerCase())
              .get();

      if (doc.exists) {
        setState(() {
          servicePrices = doc.data() ?? {};
          isLoading = false;
        });
      } else {
        setState(() {
          servicePrices = {};
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching service prices: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _buildTransactionUI();
  }

  Widget _buildTransactionUI() {
    final timestampRaw =
        widget.orderData['createdAt'] ?? widget.orderData['timestamp'];
    final DateTime? dateTime = _parseTimestamp(timestampRaw);
    final formattedDate =
        dateTime != null
            ? DateFormat('dd MMM yyyy  hh:mm a').format(dateTime)
            : 'N/A';

    final totalAmount =
        (widget.orderType.toLowerCase() == 'laundry')
            ? (widget.orderData['totalAmount'] ?? 0)
            : (widget.orderData['totalPrice'] ?? 0);

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
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Breakdown', style: sectionTitleStyle),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),

                  if (widget.orderType.toLowerCase() == 'laundry')
                    ..._buildLaundryDetails(),
                  if (widget.orderType.toLowerCase() == 'water')
                    ..._buildWaterDetails(),

                  const SizedBox(height: 24),
                  const Text('Order Details', style: sectionTitleStyle),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),

                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
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

  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    try {
      final toDateMethod = timestamp.toDate;
      if (toDateMethod is Function) {
        return timestamp.toDate();
      }
    } catch (_) {}
    return null;
  }

  List<Widget> _buildLaundryDetails() {
    final widgets = <Widget>[];

    final selectedService = _toSnakeCase(
      widget.orderData['serviceType']?.toString() ?? '',
    );
    final selectedExtras =
        (widget.orderData['extras'] as List<dynamic>? ?? [])
            .map((e) => _toSnakeCase(e.toString()))
            .toList();
    final deliveryMode = _toSnakeCase(
      widget.orderData['deliveryMode']?.toString() ?? '',
    );
    final weight = widget.orderData['weight'];

    // Main service
    if (servicePrices.containsKey(selectedService)) {
      final price = servicePrices[selectedService];
      if (price != null) {
        widgets.add(
          _buildServicePriceRow(_formatServiceLabel(selectedService), price),
        );
      }
    }

    // Extras
    for (final extra in selectedExtras) {
      if (extra != selectedService && servicePrices.containsKey(extra)) {
        final price = servicePrices[extra];
        if (price != null) {
          widgets.add(_buildServicePriceRow(_formatServiceLabel(extra), price));
        }
      }
    }

    // Per kg
    final perKgPrice = servicePrices['per_kilogram'] ?? 0;
    if (weight != null && weight is num && weight > 0 && perKgPrice != null) {
      final totalWeightPrice = weight * perKgPrice;
      widgets.add(
        _buildServicePriceRow('Weight (${weight} kg)', totalWeightPrice),
      );
    }

    // Delivery fee
    if (deliveryMode == 'pickup' && servicePrices.containsKey('pickup')) {
      widgets.add(_buildServicePriceRow('Pickup', servicePrices['pickup']!));
    } else if (deliveryMode == 'deliver' &&
        servicePrices.containsKey('deliver')) {
      widgets.add(_buildServicePriceRow('Deliver', servicePrices['deliver']!));
    }

    return widgets;
  }

  List<Widget> _buildWaterDetails() {
    final widgets = <Widget>[];

    final deliveryMode = _toSnakeCase(
      widget.orderData['deliveryMode']?.toString() ?? '',
    );

    final containerRaw = widget.orderData['containerType']?.toString() ?? '';
    String container;

    switch (containerRaw.toLowerCase()) {
      case 'jug':
      case 'jug container':
        container = 'jug_container';
        break;
      case 'tube':
      case 'tube container':
        container = 'tube_container';
        break;
      default:
        container = _toSnakeCase(containerRaw);
    }

    final qtyRaw = widget.orderData['quantity'];
    final qty =
        (qtyRaw is num) ? qtyRaw : int.tryParse(qtyRaw?.toString() ?? '') ?? 0;

    print('Water breakdown debug:');
    print('  containerRaw: $containerRaw');
    print('  container (snake_case): $container');
    print('  quantity: $qty');
    print('  servicePrices keys: ${servicePrices.keys.toList()}');

    if (qty > 0 && servicePrices.containsKey(container)) {
      final unitPriceRaw = servicePrices[container];
      final unitPrice =
          unitPriceRaw is num
              ? unitPriceRaw.toDouble()
              : double.tryParse(unitPriceRaw.toString()) ?? 0;

      final total = unitPrice * qty;

      widgets.add(
        _buildServicePriceRow(
          '${_formatServiceLabel(containerRaw)} x $qty',
          total,
        ),
      );
    } else {
      print(
        'No container price or zero quantity; skipping container breakdown',
      );
    }

    if (deliveryMode == 'pickup' && servicePrices.containsKey('pickup')) {
      final pickupRaw = servicePrices['pickup'];
      final pickupPrice =
          pickupRaw is num
              ? pickupRaw.toDouble()
              : double.tryParse(pickupRaw.toString()) ?? 0;

      widgets.add(_buildServicePriceRow('Pickup', pickupPrice));
    } else if (deliveryMode == 'deliver' &&
        servicePrices.containsKey('deliver')) {
      final deliverRaw = servicePrices['deliver'];
      final deliverPrice =
          deliverRaw is num
              ? deliverRaw.toDouble()
              : double.tryParse(deliverRaw.toString()) ?? 0;

      widgets.add(_buildServicePriceRow('Deliver', deliverPrice));
    }

    return widgets;
  }

  Widget _buildServicePriceRow(String service, num price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '₱${price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  String _formatServiceLabel(String key) {
    return key
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  String _toSnakeCase(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'\s+'), '_');
  }
}
