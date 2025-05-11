import 'package:flutter/material.dart';

class AddCustomerAddressPage extends StatefulWidget {
  @override
  _AddCustomerAddressPageState createState() => _AddCustomerAddressPageState();
}

class _AddCustomerAddressPageState extends State<AddCustomerAddressPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isDefault = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _barangayController.dispose();
    _municipalityController.dispose();
    _cityController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveAddress() {
  if (_formKey.currentState!.validate()) {
    final addressData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phone': _phoneController.text,
      'street': _streetController.text,
      'barangay': _barangayController.text,
      'municipality': _municipalityController.text,
      'city': _cityController.text,
      'instructions': _instructionsController.text,
      'isDefault': _isDefault,
    };

    Navigator.pop(context, addressData); // Send data back
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Add Address',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Personal Information"),
              _buildTextField(_firstNameController, "First Name"),
              _buildTextField(_lastNameController, "Last Name"),
              _buildTextField(
                _phoneController,
                "Phone Number",
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Set default address", style: TextStyle(fontSize: 16)),
                  Radio(
                    value: true,
                    groupValue: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value!;
                      });
                    },
                  ),
                ],
              ),

              _buildTextField(_streetController, "House No. / Street"),
              _buildTextField(_barangayController, "Barangay"),
              _buildTextField(_municipalityController, "Municipality"),
              _buildTextField(_cityController, "City"),
              SizedBox(height: 16),

              _sectionTitle("Additional Instructions:"),
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type something here...",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  child: Text(
                    'Save Address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B007D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          return null;
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
