import 'package:flutter/material.dart';
import 'waterPaymentPage.dart';

class WaterStationPage extends StatefulWidget {
  @override
  _WaterStationPageState createState() => _WaterStationPageState();
}

class _WaterStationPageState extends State<WaterStationPage> {
  String _selectedContainer = 'Tube';
  int _quantity = 1;
  String _deliveryMode = 'Pick Up';

  double _getContainerPrice(String container) {
    switch (container) {
      case 'Jug':
        return 25.0;
      case 'Tube':
      default:
        return 25.0;
    }
  }

  double get totalPrice {
    double baseTotal = _getContainerPrice(_selectedContainer) * _quantity;
    if (_deliveryMode == 'Deliver') {
      baseTotal += 15.0; // Delivery fee
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
        builder: (context) => WaterPaymentPage(
          selectedContainer: _selectedContainer,
          quantity: _quantity,
          deliveryMode: _deliveryMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text('Deliver'),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'PHP ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _selectedContainer = label),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Color(0xFF4B007D) : Colors.deepPurple[100],
            foregroundColor: Colors.white,
            minimumSize: Size(130, 100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                label == 'Tube' ? Icons.water_drop : Icons.local_drink,
                size: 30,
              ),
              SizedBox(height: 8),
              Text('$label Container'),
            ],
          ),
        ),
        SizedBox(height: 6),
        Text(
          'PHP ${_getContainerPrice(label).toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
