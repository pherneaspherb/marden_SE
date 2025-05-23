import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCustomerAddressPage extends StatefulWidget {
  final Map<String, dynamic>? existingAddress; // optional parameter

  AddCustomerAddressPage({Key? key, this.existingAddress}) : super(key: key);

  @override
  _AddCustomerAddressPageState createState() => _AddCustomerAddressPageState();
}

class _AddCustomerAddressPageState extends State<AddCustomerAddressPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for address fields
  final _streetController = TextEditingController();
  final _barangayController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _cityController = TextEditingController();
  final _instructionsController = TextEditingController();

  bool _isDefault = false;

  static const Color primaryColor = Color(0xFF4B007D);

  @override
  void initState() {
    super.initState();

    // Prefill fields if editing an existing address
    if (widget.existingAddress != null) {
      final address = widget.existingAddress!;
      _streetController.text = address['street'] ?? '';
      _barangayController.text = address['barangay'] ?? '';
      _municipalityController.text = address['municipality'] ?? '';
      _cityController.text = address['city'] ?? '';
      _instructionsController.text = address['instructions'] ?? '';
      _isDefault = address['isDefault'] ?? false;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _barangayController.dispose();
    _municipalityController.dispose();
    _cityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final addressData = {
      'street': _streetController.text.trim(),
      'barangay': _barangayController.text.trim(),
      'municipality': _municipalityController.text.trim(),
      'city': _cityController.text.trim(),
      'instructions': _instructionsController.text.trim(),
      'isDefault': _isDefault,
    };

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance.collection('customers').doc(userId);

      if (widget.existingAddress != null && widget.existingAddress!['id'] != null) {
        // Update existing address document
        await userRef
            .collection('addresses')
            .doc(widget.existingAddress!['id'])
            .set(addressData, SetOptions(merge: true));
      } else {
        // Add new address to the addresses subcollection
        await userRef.collection('addresses').add(addressData);
      }

      // If this is the default address, update main customer doc
      if (_isDefault) {
        await userRef.set({
          'defaultAddress': addressData,
        }, SetOptions(merge: true));
      }

      // Return to previous screen with address data
      Navigator.pop(context, addressData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving address: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.existingAddress == null ? 'Add Address' : 'Edit Address',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_streetController, "House No. / Street"),
              _buildTextField(_barangayController, "Barangay"),
              _buildTextField(_municipalityController, "Municipality"),
              _buildTextField(_cityController, "City"),

              // Checkbox for default address
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Set default address", style: TextStyle(fontSize: 16)),
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    activeColor: primaryColor,
                  ),
                ],
              ),

              _sectionTitle("Additional Instructions:"),
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type something here...",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.existingAddress == null ? 'Save Address' : 'Update Address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build text fields with validation
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.trim().isEmpty) ? 'This field is required' : null,
      ),
    );
  }

  // Section title helper
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
