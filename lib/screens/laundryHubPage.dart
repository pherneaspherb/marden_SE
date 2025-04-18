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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              selectedService = label;
            });
          },
          icon: Icon(icon, color: isSelected ? Colors.white : Colors.black),
          label: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            minimumSize: Size(90, 70),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        title: Text('Laundry Hub'),
        backgroundColor: Colors.deepPurple,
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
