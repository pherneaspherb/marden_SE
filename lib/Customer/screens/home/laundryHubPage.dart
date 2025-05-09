import 'package:flutter/material.dart';
import 'laundryPaymentPage.dart';

class LaundryHubPage extends StatefulWidget {
  @override
  _LaundryHubPageState createState() => _LaundryHubPageState();
}

class _LaundryHubPageState extends State<LaundryHubPage> {
  String selectedService = '';
  bool addSoftener = false;
  bool foldClothes = false;
  double weight = 0.0;
  String deliveryMode = '';

  void _incrementWeight() {
    setState(() {
      weight += 1;
    });
  }

  void _decrementWeight() {
    setState(() {
      if (weight > 0) weight -= 1;
    });
  }

  Widget _buildServiceButton(String label, IconData icon) {
    final isSelected = selectedService == label;

    Gradient? gradient;
    if (label == 'Wash & Dry') {
      gradient = LinearGradient(colors: [Colors.white, Colors.green]);
    } else if (label == 'Wash Only') {
      gradient = LinearGradient(colors: [Colors.white, Colors.blue]);
    } else if (label == 'Dry Only') {
      gradient = LinearGradient(colors: [Colors.white, Colors.orange]);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedService = label;
            });
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: isSelected ? gradient : null,
              color: isSelected ? null : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? Colors.white : Colors.black),
                SizedBox(width: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToPayment() {
    if (selectedService.isEmpty || weight <= 0 || deliveryMode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please complete all selections before proceeding."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LaundryPaymentPage(
          serviceType: selectedService,
          extras: [
            if (addSoftener) 'Fabric Softener',
            if (foldClothes) 'Fold',
          ],
          weight: weight,
          deliveryMode: deliveryMode,
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
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Text(
                'Select a service',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  _buildServiceButton('Wash & Dry', Icons.local_laundry_service),
                  _buildServiceButton('Wash Only', Icons.local_drink),
                  _buildServiceButton('Dry Only', Icons.wb_sunny),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Extra services',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: Text('Fabric Softener'),
                value: addSoftener,
                onChanged: (value) => setState(() => addSoftener = value!),
              ),
              CheckboxListTile(
                title: Text('Fold'),
                value: foldClothes,
                onChanged: (value) => setState(() => foldClothes = value!),
              ),
              SizedBox(height: 20),
              Text(
                'Weight (kg)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _decrementWeight,
                    icon: Icon(Icons.remove_circle),
                  ),
                  Text(weight.toStringAsFixed(1), style: TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: _incrementWeight,
                    icon: Icon(Icons.add_circle),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Mode of Delivery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                title: Text('Pick Up'),
                value: 'Pick Up',
                groupValue: deliveryMode,
                onChanged: (value) =>
                    setState(() => deliveryMode = value.toString()),
              ),
              RadioListTile(
                title: Text('Deliver'),
                value: 'Deliver',
                groupValue: deliveryMode,
                onChanged: (value) =>
                    setState(() => deliveryMode = value.toString()),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _goToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
