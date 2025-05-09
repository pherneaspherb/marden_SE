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
    required this.serviceType,
    required this.extras,
    required this.weight,
    required this.deliveryMode,
  });

  @override
  _LaundryPaymentPageState createState() => _LaundryPaymentPageState();
}

class _LaundryPaymentPageState extends State<LaundryPaymentPage> {
  final streetController = TextEditingController();
  final barangayController = TextEditingController();
  final municipalityController = TextEditingController();
  final cityController = TextEditingController();
  final instructionsController = TextEditingController();

  String paymentMethod = '';
  double totalAmount = 0.0;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _calculateTotal() {
    const double baseRate = 50.0;
    const double softenerFee = 10.0;
    const double foldFee = 15.0;

    double total = widget.weight * baseRate;
    if (widget.extras.contains('Fabric Softener')) total += softenerFee;
    if (widget.extras.contains('Fold')) total += foldFee;

    setState(() => totalAmount = total);
  }

  Future<void> _placeOrder() async {
    print('Place order clicked'); // 🖨️

    if (streetController.text.isEmpty ||
        barangayController.text.isEmpty ||
        municipalityController.text.isEmpty ||
        cityController.text.isEmpty ||
        paymentMethod.isEmpty) {
      print('Validation failed: Address fields or payment missing'); // 🖨️
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all address fields and select a payment method.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    print('Fetched uid: $uid'); // 🖨️

    if (uid == null) {
      print('UID is null, user not logged in'); // 🖨️
      return;
    }

    final orderData = {
      'serviceType': widget.serviceType,
      'extras': widget.extras,
      'weight': widget.weight,
      'deliveryMode': widget.deliveryMode,
      'address': streetController.text,
      'barangay': barangayController.text,
      'municipality': municipalityController.text,
      'city': cityController.text,
      'paymentMethod': paymentMethod,
      'instructions': instructionsController.text,
      'totalAmount': totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Pending',
    };

    try {
      setState(() => isPlacingOrder = true);
      print('Attempting to save orderData to Firestore'); // 🖨️

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .collection('laundryOrders')
          .add(orderData);

      setState(() => isPlacingOrder = false);
      print('Order placed successfully'); // 🖨️

      _showSuccessDialog();
    } catch (e) {
      setState(() => isPlacingOrder = false);
      print('Failed to place order: $e'); // 🖨️
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order')));
    }
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
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your order has been processed.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please track your order.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => CustomerMainPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Done", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Laundry Hub',
          style: TextStyle(
            fontFamily: 'Poppins', // Replace with the actual font family name
            fontWeight: FontWeight.w600, // You can use w400, w500, w700, etc.
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
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
            SizedBox(height: 20),
            Text(
              'Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildRadioOption('Cash', Icons.money),
            SizedBox(height: 20),
            Text('Additional Instructions:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            TextField(
              controller: instructionsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type something here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₱ ${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: isPlacingOrder ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child:
                  isPlacingOrder
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Place an Order', style: TextStyle(fontSize: 16)),
            ),
          ],
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

  Widget _buildRadioOption(String title, IconData icon) {
    return RadioListTile(
      title: Row(children: [Icon(icon), SizedBox(width: 10), Text(title)]),
      value: title,
      groupValue: paymentMethod,
      onChanged: (val) => setState(() => paymentMethod = val.toString()),
    );
  }
}
