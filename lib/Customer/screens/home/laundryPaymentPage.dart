import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customerMainPage.dart';

class LaundryPaymentPage extends StatefulWidget {
  final String serviceType;
  final List<String> extras;
  final double weight;
  final String deliveryMode;

  const LaundryPaymentPage({
    super.key,
    required this.serviceType,
    required this.extras,
    required this.weight,
    required this.deliveryMode,
  });

  @override
  State<LaundryPaymentPage> createState() => _LaundryPaymentPageState();
}

Map<String, dynamic> laundryRates = {};

class _LaundryPaymentPageState extends State<LaundryPaymentPage> {
  final streetController = TextEditingController();
  final barangayController = TextEditingController();
  final municipalityController = TextEditingController();
  final cityController = TextEditingController();
  final instructionsController = TextEditingController();

  double totalAmount = 0.0;
  bool isPlacingOrder = false;
  bool saveAsDefault = false;

  @override
  void initState() {
    super.initState();
    _loadServiceRates().then((_) => _calculateTotal());
    _calculateTotal();
    _loadDefaultAddress();
  }

  Future<void> _loadServiceRates() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('services')
            .doc('laundry')
            .get();
    setState(() {
      laundryRates = doc.data() ?? {};
    });
  }

  void _calculateTotal() {
    double baseRate = 0.0;

    switch (widget.serviceType) {
      case 'Wash & Dry':
        baseRate = (laundryRates['wash_and_dry'] ?? 0).toDouble();
        break;
      case 'Wash Only':
        baseRate = (laundryRates['wash_only'] ?? 0).toDouble();
        break;
      case 'Dry Only':
        baseRate = (laundryRates['dry_only'] ?? 0).toDouble();
        break;
    }

    double extras = 0.0;
    if (widget.extras.contains('Fabric Softener')) {
      extras += (laundryRates['fabric_softener'] ?? 0).toDouble();
    }
    if (widget.extras.contains('Fold')) {
      extras += (laundryRates['fold'] ?? 0).toDouble();
    }

    double weightCharge =
        widget.weight * (laundryRates[''] ?? 0).toDouble();
    double deliveryFee =
        (widget.deliveryMode == 'Deliver')
            ? (laundryRates['deliver'] ?? 0).toDouble()
            : 0.0;

    setState(() {
      totalAmount = baseRate + weightCharge + extras + deliveryFee;
    });
  }

  Future<void> _loadDefaultAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(uid)
              .get();
      final address = doc.data()?['defaultAddress'];

      if (address != null) {
        streetController.text = address['street'] ?? '';
        barangayController.text = address['barangay'] ?? '';
        municipalityController.text = address['municipality'] ?? '';
        cityController.text = address['city'] ?? '';
        setState(() => saveAsDefault = true);
      }
    } catch (e) {
      debugPrint("Error loading address: $e");
    }
  }

  Future<void> _placeOrder() async {
    final addressFields = [
      streetController.text.trim(),
      barangayController.text.trim(),
      municipalityController.text.trim(),
      cityController.text.trim(),
    ];

    if (addressFields.any((e) => e.isEmpty)) {
      _showSnackbar('Please fill out all required address fields.', true);
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnackbar('User not logged in.', true);
      return;
    }

    setState(() => isPlacingOrder = true);

    try {
      final counterRef = FirebaseFirestore.instance
          .collection('counters')
          .doc('laundryOrders');

      final newOrderId = await FirebaseFirestore.instance.runTransaction((
        tx,
      ) async {
        final counterSnap = await tx.get(counterRef);
        int lastNumber = counterSnap.data()?['lastOrderNumber'] ?? 0;
        int nextOrderNumber = lastNumber + 1;

        tx.update(counterRef, {'lastOrderNumber': nextOrderNumber});

        // ORD-2025-0001
        final year = DateTime.now().year;
        return 'ORD-$year-${nextOrderNumber.toString().padLeft(4, '0')}';
      });

      final orderData = {
        'orderId': newOrderId,
        'serviceType': widget.serviceType,
        'extras': widget.extras,
        'weight': widget.weight,
        'deliveryMode': widget.deliveryMode,
        'address': {
          'house': streetController.text.trim(),
          'barangay': barangayController.text.trim(),
          'municipality': municipalityController.text.trim(),
          'city': cityController.text.trim(),
        },
        'paymentMethod': 'Cash',
        'instructions': instructionsController.text.trim(),
        'totalAmount': totalAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      final customerRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(uid);
      final orderRef = customerRef.collection('laundryOrders').doc(newOrderId);
      await orderRef.set(orderData);

      if (saveAsDefault) {
        await customerRef.set({
          'defaultAddress': {
            'street': addressFields[0],
            'barangay': addressFields[1],
            'municipality': addressFields[2],
            'city': addressFields[3],
          },
        }, SetOptions(merge: true));
      }

      _showSuccessDialog();
    } catch (e) {
      _showSnackbar('Failed to place order: $e', true);
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  void _showSnackbar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF4B007D),
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your order has been processed.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please track your order.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => CustomerMainPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4B007D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Done", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B007D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Laundry Hub',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: streetController,
              label: 'House No. / Street',
            ),
            _buildTextField(controller: barangayController, label: 'Barangay'),
            _buildTextField(
              controller: municipalityController,
              label: 'Municipality',
            ),
            _buildTextField(controller: cityController, label: 'City'),
            CheckboxListTile(
              title: const Text('Save as default address'),
              value: saveAsDefault,
              onChanged: (val) => setState(() => saveAsDefault = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: This business currently accepts Cash on Delivery (COD) only.',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Additional Instructions (Optional)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: instructionsController,
              label: 'e.g. Leave at front door',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₱ ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isPlacingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B007D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child:
                  isPlacingOrder
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Place an Order',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
