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

  double totalAmount = 0.0;
  bool isPlacingOrder = false;
  bool saveAsDefault = false;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    _loadDefaultAddress(); // Load default address during initialization
  }

  void _calculateTotal() {
    const baseRate = 50.0;
    const softenerFee = 10.0;
    const foldFee = 15.0;

    double total = widget.weight * baseRate;
    if (widget.extras.contains('Fabric Softener')) total += softenerFee;
    if (widget.extras.contains('Fold')) total += foldFee;

    setState(() => totalAmount = total);
  }

  Future<void> _loadDefaultAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final customerDoc = await FirebaseFirestore.instance.collection('customers').doc(uid).get();
      final defaultAddress = customerDoc.data()?['defaultAddress'];

      if (defaultAddress != null) {
        streetController.text = defaultAddress['street'] ?? '';
        barangayController.text = defaultAddress['barangay'] ?? '';
        municipalityController.text = defaultAddress['municipality'] ?? '';
        cityController.text = defaultAddress['city'] ?? '';
        setState(() {
          saveAsDefault = true;
        });
      }
    } catch (e) {
      print("Failed to load default address: $e");
    }
  }

  Future<void> _placeOrder() async {
    final street = streetController.text.trim();
    final barangay = barangayController.text.trim();
    final municipality = municipalityController.text.trim();
    final city = cityController.text.trim();

    if (street.isEmpty || barangay.isEmpty || municipality.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all required address fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not logged in.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final orderData = {
      'serviceType': widget.serviceType,
      'extras': widget.extras,
      'weight': widget.weight,
      'deliveryMode': widget.deliveryMode,
      'address': street,
      'barangay': barangay,
      'municipality': municipality,
      'city': city,
      'paymentMethod': 'Cash',
      'instructions': instructionsController.text.trim(),
      'totalAmount': totalAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Pending',
    };

    try {
      setState(() => isPlacingOrder = true);

      final customerRef = FirebaseFirestore.instance.collection('customers').doc(uid);

      await customerRef.collection('laundryOrders').add(orderData);

      if (saveAsDefault) {
        await customerRef.set({
          'defaultAddress': {
            'street': street,
            'barangay': barangay,
            'municipality': municipality,
            'city': city,
          }
        }, SetOptions(merge: true));
      }

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      setState(() => isPlacingOrder = false);
    }
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
              SizedBox(height: 20),
              Text('Your order has been processed.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text('Please track your order.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center),
              SizedBox(height: 30),
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
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Done", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
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
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Laundry Hub',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text('Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildTextField(controller: streetController, label: 'House No. / Street'),
            _buildTextField(controller: barangayController, label: 'Barangay'),
            _buildTextField(controller: municipalityController, label: 'Municipality'),
            _buildTextField(controller: cityController, label: 'City'),

            CheckboxListTile(
              title: Text('Save as default address'),
              value: saveAsDefault,
              onChanged: (val) => setState(() => saveAsDefault = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            SizedBox(height: 20),
            Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: This business currently accepts Cash on Delivery (COD) only.',
                    style: TextStyle(color: Colors.orange[800], fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₱ ${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              child: isPlacingOrder
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Place an Order', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
