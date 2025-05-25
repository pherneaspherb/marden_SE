import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  double totalAmount = 0.0;

  Map<String, dynamic> laundryPrices = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLaundryPrices();
  }

  Future<void> _loadLaundryPrices() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('services')
            .doc('laundry')
            .get();
    if (doc.exists) {
      setState(() {
        laundryPrices = doc.data() ?? {};
        isLoading = false;
      });
    }
  }

  void _incrementWeight() {
    if (weight < 7) {
      setState(() {
        weight += 1;
        _calculateTotal();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maximum allowed weight is 7 kg."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _decrementWeight() {
    setState(() {
      if (weight > 0) {
        weight -= 1;
        _calculateTotal();
      }
    });
  }

  void _calculateTotal() {
    double baseRate = 0.0;
    if (selectedService == 'Wash & Dry')
      baseRate = (laundryPrices['wash_and_dry'] ?? 0).toDouble();
    if (selectedService == 'Wash Only')
      baseRate = (laundryPrices['wash_only'] ?? 0).toDouble();
    if (selectedService == 'Dry Only')
      baseRate = (laundryPrices['dry_only'] ?? 0).toDouble();

    double extras = 0.0;
    if (addSoftener)
      extras += (laundryPrices['fabric_softener'] ?? 0).toDouble();
    if (foldClothes) extras += (laundryPrices['fold'] ?? 0).toDouble();

    double perKiloRate = (laundryPrices['per_kilogram'] ?? 0).toDouble();
    double weightCharge = weight * perKiloRate;

    double delivery =
        (deliveryMode == 'Deliver')
            ? (laundryPrices['deliver'] ?? 0).toDouble()
            : 0.0;

    setState(() {
      totalAmount = baseRate + weightCharge + extras + delivery;
    });
  }

  Widget _buildServiceButton(String label, IconData icon) {
    final isSelected = selectedService == label;

    Gradient? gradient;
    if (label == 'Wash & Dry') {
      gradient = LinearGradient(colors: [Colors.teal, Colors.green]);
    } else if (label == 'Wash Only') {
      gradient = LinearGradient(colors: [Colors.lightBlue, Colors.blue]);
    } else if (label == 'Dry Only') {
      gradient = LinearGradient(colors: [Colors.orange, Colors.deepOrange]);
    }

    final priceKey =
        {
          'Wash & Dry': 'wash_and_dry',
          'Wash Only': 'wash_only',
          'Dry Only': 'dry_only',
        }[label];

    final price = (laundryPrices[priceKey] ?? 0).toDouble();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedService = label;
              _calculateTotal();
            });
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: isSelected ? gradient : null,
              color: isSelected ? null : Colors.deepPurple[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? Colors.white : Colors.black),
                SizedBox(width: 6),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₱$price',
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
        builder:
            (context) => LaundryPaymentPage(
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF4B007D),
          title: Text('Laundry Hub', style: TextStyle(color: Colors.white)),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
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
                  _buildServiceButton(
                    'Wash & Dry',
                    Icons.local_laundry_service,
                  ),
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
                secondary: Text(
                  '₱${(laundryPrices['fabric_softener'] ?? 0).toString()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                value: addSoftener,
                onChanged:
                    (value) => setState(() {
                      addSoftener = value!;
                      _calculateTotal();
                    }),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              CheckboxListTile(
                title: Text('Fold'),
                secondary: Text(
                  '₱${(laundryPrices['fold'] ?? 0).toString()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                value: foldClothes,
                onChanged:
                    (value) => setState(() {
                      foldClothes = value!;
                      _calculateTotal();
                    }),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
              SizedBox(height: 20),
              Text(
                'Weight',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '₱${(laundryPrices['per_kilogram'] ?? 0)} per kilogram (max. 7 kg)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: false,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: weight.toStringAsFixed(1),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _decrementWeight,
                    icon: Icon(Icons.remove_circle),
                  ),
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
                onChanged:
                    (value) => setState(() {
                      deliveryMode = value.toString();
                      _calculateTotal();
                    }),
              ),
              RadioListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deliver'),
                    Text(
                      '₱${(laundryPrices['deliver'] ?? 0).toString()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                value: 'Deliver',
                groupValue: deliveryMode,
                onChanged:
                    (value) => setState(() {
                      deliveryMode = value.toString();
                      _calculateTotal();
                    }),
              ),
              SizedBox(height: 30),
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
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _goToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B007D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
