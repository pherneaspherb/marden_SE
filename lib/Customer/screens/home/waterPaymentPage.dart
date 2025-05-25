import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerMainPage.dart';

class WaterPaymentPage extends StatefulWidget {
  final String selectedContainer;
  final String deliveryMode;
  final int quantity;
  final double totalPrice;

  const WaterPaymentPage({
    Key? key,
    required this.selectedContainer,
    required this.deliveryMode,
    required this.quantity,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<WaterPaymentPage> createState() => _WaterPaymentPageState();
}

class _WaterPaymentPageState extends State<WaterPaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final streetController = TextEditingController();
  final barangayController = TextEditingController();
  final municipalityController = TextEditingController();
  final cityController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isPlacingOrder = false;
  bool saveAsDefault = false;

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isPlacingOrder = true);

    try {
      final customerRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid);
      final ordersRef = customerRef.collection('waterOrders');

      final countersRef = FirebaseFirestore.instance
          .collection('counters')
          .doc('waterOrders');

      int newOrderNumber = await FirebaseFirestore.instance.runTransaction((
        transaction,
      ) async {
        final snapshot = await transaction.get(countersRef);

        if (!snapshot.exists) {
          throw Exception('Counter document does not exist!');
        }

        int current = snapshot.get('lastOrderNumber') ?? 0;
        int updated = current + 1;

        transaction.update(countersRef, {'lastOrderNumber': updated});

        return updated;
      });

      final currentYear = DateTime.now().year;
      final formattedOrderId =
          'ORD-$currentYear-${newOrderNumber.toString().padLeft(4, '0')}';

      final orderData = {
        'orderId': formattedOrderId,
        'type': 'Water',
        'containerType': widget.selectedContainer,
        'quantity': widget.quantity,
        'totalPrice': widget.totalPrice,
        'deliveryMode': widget.deliveryMode,
        'address': {
          'house': streetController.text.trim(),
          'barangay': barangayController.text.trim(),
          'municipality': municipalityController.text.trim(),
          'city': cityController.text.trim(),
        },
        'paymentMethod': 'Cash',
        'instructions': _instructionsController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await ordersRef.add(orderData);

      if (saveAsDefault) {
        await customerRef.update({
          'defaultAddress': {
            'street': streetController.text.trim(),
            'barangay': barangayController.text.trim(),
            'municipality': municipalityController.text.trim(),
            'city': cityController.text.trim(),
          },
        });
      }

      _showSuccessDialog();
    } catch (e) {
      _showSnackbar(
        'Failed to place order. Please try again later.',
        isError: true,
      );
    } finally {
      setState(() => _isPlacingOrder = false);
    }
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
      }
    } catch (e) {
      debugPrint("Error loading address: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
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
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: streetController,
                  label: 'House No. / Street',
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter house/street'
                              : null,
                ),
                _buildTextField(
                  controller: barangayController,
                  label: 'Barangay',
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter barangay'
                              : null,
                ),
                _buildTextField(
                  controller: municipalityController,
                  label: 'Municipality',
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter municipality'
                              : null,
                ),
                _buildTextField(
                  controller: cityController,
                  label: 'City',
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter city'
                              : null,
                ),
                CheckboxListTile(
                  title: const Text('Save as default address'),
                  value: saveAsDefault,
                  onChanged:
                      (val) => setState(() => saveAsDefault = val ?? false),
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
                _buildTextField(
                  controller: _instructionsController,
                  label: 'Additional Instructions (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₱ ${widget.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isPlacingOrder ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B007D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child:
                      _isPlacingOrder
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Place an Order',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
