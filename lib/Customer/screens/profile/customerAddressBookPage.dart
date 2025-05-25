import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addCustomerAddressPage.dart';

class CustomerAddressBookPage extends StatefulWidget {
  @override
  _CustomerAddressBookPageState createState() =>
      _CustomerAddressBookPageState();
}

class _CustomerAddressBookPageState extends State<CustomerAddressBookPage> {
  List<Map<String, dynamic>> _savedAddresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance
          .collection('customers')
          .doc(userId);
      final snapshot = await userRef.collection('addresses').get();

      final addresses =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'street': data['street'] ?? '',
              'barangay': data['barangay'] ?? '',
              'municipality': data['municipality'] ?? '',
              'city': data['city'] ?? '',
              'instructions': data['instructions'] ?? '',
              'isDefault': data['isDefault'] ?? false,
            };
          }).toList();

      setState(() {
        _savedAddresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load addresses: $e')));
    }
  }

  void _addNewAddress(Map<String, dynamic> newAddress) {
    setState(() {
      _savedAddresses.add(newAddress);
    });
  }

  void _updateAddress(int index, Map<String, dynamic> updatedAddress) {
    setState(() {
      _savedAddresses[index] = updatedAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Address Book',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddCustomerAddressPage()),
                );

                if (result != null && result is Map<String, dynamic>) {
                  _addNewAddress(result);
                }
              },
              icon: Icon(Icons.add, color: Color(0xFF4B007D)),
              label: Text(
                'Add Address',
                style: TextStyle(
                  color: Color(0xFF4B007D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF4B007D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 24),
            Divider(),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_savedAddresses.isEmpty)
              Center(child: Text('No saved addresses yet.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _savedAddresses.length,
                  itemBuilder: (context, index) {
                    final address = _savedAddresses[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: Colors.black),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${address['street']}, ${address['barangay']}, ${address['municipality']}, ${address['city']}',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                                if (address['instructions'] != null &&
                                    address['instructions']
                                        .toString()
                                        .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Instructions: ${address['instructions']}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: 8),
                                if (address['isDefault'] == true)
                                  OutlinedButton(
                                    onPressed: () {
                                    },
                                    child: Text('Default Address'),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      side: BorderSide(color: Colors.black),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              final editedAddress = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddCustomerAddressPage(
                                        existingAddress: address,
                                      ),
                                ),
                              );

                              if (editedAddress != null &&
                                  editedAddress is Map<String, dynamic>) {
                                _updateAddress(index, editedAddress);
                              }
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
