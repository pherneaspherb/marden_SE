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
  _WaterPaymentPageState createState() => _WaterPaymentPageState();
}

class _WaterPaymentPageState extends State<WaterPaymentPage> {
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  String _selectedPaymentMethod = 'Cash';
  bool isDefaultAddress = false;
  bool _isLoading = false;

  Future<void> _saveWaterOrderToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

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
      'paymentMethod': _selectedPaymentMethod,
      'instructions': _instructionsController.text,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('waterOrders')
        .add(orderData);
  }

  void _placeOrder() async {
    if (_houseController.text.isEmpty ||
        _barangayController.text.isEmpty ||
        _municipalityController.text.isEmpty ||
        _cityController.text.isEmpty) {
      _showMissingFieldsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _saveWaterOrderToFirestore();

      setState(() {
        _isLoading = false;
      });

      showOrderConfirmationDialog(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to place order: $e');
    }
  }

  void _showMissingFieldsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incomplete Address'),
        content: Text('Please fill in all required address fields to proceed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showOrderConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Color(0xFFF7ECFF),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  radius: 30,
                  child: Icon(Icons.check, color: Colors.white, size: 30),
                ),
                SizedBox(height: 16),
                Text(
                  'Your order has been processed.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Please track your order.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => CustomerMainPage()),
                      (route) => false,
                    );
                  },
                  child: Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
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
        title: Text('Water Station'),
        backgroundColor: Colors.deepPurple,
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Set default address'),
                Spacer(),
                Checkbox(
                  value: isDefaultAddress,
                  onChanged: (value) {
                    setState(() {
                      isDefaultAddress = value!;
                    });
                  },
                ),
              ],
            ),
            _buildTextField('House No. / Street', _houseController),
            _buildTextField('Barangay', _barangayController),
            _buildTextField('Municipality', _municipalityController),
            _buildTextField('City', _cityController),
            SizedBox(height: 20),
            Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(
              title: Row(
                children: [
                  Icon(Icons.attach_money),
                  SizedBox(width: 8),
                  Text('Cash'),
                ],
              ),
              value: 'Cash',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile(
              title: Row(
                children: [
                  Icon(Icons.phone_android),
                  SizedBox(width: 8),
                  Text('G-Cash'),
                ],
              ),
              value: 'G-Cash',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Additional Instructions:',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type something here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₱${widget.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Place an Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}