import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerMainPage.dart';

class WaterPaymentPage extends StatefulWidget {
  final String selectedContainer;
  final double totalPrice;
  final String deliveryMode;

  const WaterPaymentPage({
    Key? key,
    required this.selectedContainer,
    required this.totalPrice,
    required this.deliveryMode,
  }) : super(key: key);

  @override
  State<WaterPaymentPage> createState() => _WaterPaymentPageState();
}

class _WaterPaymentPageState extends State<WaterPaymentPage> {
  final _houseController = TextEditingController();
  final _barangayController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _cityController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isPlacingOrder = false;

  Future<void> _placeOrder() async {
    if (_houseController.text.isEmpty ||
        _barangayController.text.isEmpty ||
        _municipalityController.text.isEmpty ||
        _cityController.text.isEmpty) {
      _showSnackbar('Please complete all address fields.', isError: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final orderData = {
      'containerType': widget.selectedContainer,
      'totalPrice': widget.totalPrice,
      'deliveryMode': widget.deliveryMode,
      'address': {
        'house': _houseController.text,
        'barangay': _barangayController.text,
        'municipality': _municipalityController.text,
        'city': _cityController.text,
      },
      'paymentMethod': 'Cash',
      'instructions': _instructionsController.text,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    setState(() => _isPlacingOrder = true);

    try {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('waterOrders')
          .add(orderData);

      _showSuccessDialog();
    } catch (e) {
      _showSnackbar('Failed to place order');
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepPurple,
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
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Water Delivery',
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
            const Text('Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTextField(controller: _houseController, label: 'House No. / Street'),
            _buildTextField(controller: _barangayController, label: 'Barangay'),
            _buildTextField(controller: _municipalityController, label: 'Municipality'),
            _buildTextField(controller: _cityController, label: 'City'),
            const SizedBox(height: 20),

            const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₱ ${widget.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isPlacingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isPlacingOrder
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Place an Order', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
