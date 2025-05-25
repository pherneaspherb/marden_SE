import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waterPaymentPage.dart';

class WaterStationPage extends StatefulWidget {
  @override
  _WaterStationPageState createState() => _WaterStationPageState();
}

class _WaterStationPageState extends State<WaterStationPage> {
  String _selectedContainer = 'Tube';
  int _quantity = 1;
  String _deliveryMode = 'Pick Up';

  Map<String, dynamic>? _waterPrices;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWaterPrices();
  }

  Future<void> _fetchWaterPrices() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('services')
            .doc('water')
            .get();

    setState(() {
      _waterPrices = doc.data();
      _loading = false;
    });
  }

  double _getContainerPrice(String container) {
    if (_waterPrices == null) return 0;
    if (container == 'Jug') {
      return (_waterPrices?['jug_container'] ?? 0).toDouble();
    } else {
      return (_waterPrices?['tube_container'] ?? 0).toDouble();
    }
  }

  double get totalPrice {
    if (_waterPrices == null) return 0;
    double baseTotal = _getContainerPrice(_selectedContainer) * _quantity;
    if (_deliveryMode == 'Deliver') {
      baseTotal += (_waterPrices?['deliver'] ?? 0).toDouble();
    }
    return baseTotal;
  }

  bool get isOrderFormValid =>
      _selectedContainer.isNotEmpty &&
      _quantity > 0 &&
      _deliveryMode.isNotEmpty;

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WaterPaymentPage(
              selectedContainer: _selectedContainer,
              quantity: _quantity,
              deliveryMode: _deliveryMode,
              totalPrice: totalPrice, // pass the computed total price here
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF4B007D),
          title: Text("Water Station", style: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Water Station',
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
                'Select a container',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildContainerButton('Tube'),
                  _buildContainerButton('Jug'),
                ],
              ),
              SizedBox(height: 24),
              Text('Others', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Quantity'),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                      }
                    },
                  ),
                  Text('$_quantity', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Mode of Delivery',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                title: Text('Pick Up'),
                value: 'Pick Up',
                groupValue: _deliveryMode,
                onChanged: (value) => setState(() => _deliveryMode = value!),
              ),
              RadioListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deliver'),
                    Text(
                      '₱${(_waterPrices?['deliver'] ?? 0).toString()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                value: 'Deliver',
                groupValue: _deliveryMode,
                onChanged: (value) => setState(() => _deliveryMode = value!),
              ),
              SizedBox(height: 24),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '₱ ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isOrderFormValid ? _proceedToPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B007D),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContainerButton(String label) {
    final bool isSelected = _selectedContainer == label;

    Gradient? gradient;
    if (label == 'Tube') {
      gradient = LinearGradient(colors: [Colors.blueAccent, Colors.indigo]);
    } else if (label == 'Jug') {
      gradient = LinearGradient(colors: [Colors.lightBlue, Colors.blue]);
    }

    double price = _getContainerPrice(label);

    return InkWell(
      onTap: () => setState(() => _selectedContainer = label),
      child: Container(
        width: 130,
        height: 100,
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.deepPurple[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'Tube' ? Icons.water_drop : Icons.local_drink,
              size: 30,
              color: isSelected ? Colors.white : Colors.black,
            ),
            SizedBox(height: 8),
            Text(
              '$label Container',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '₱${price.toStringAsFixed(2)}',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
