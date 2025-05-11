import 'package:flutter/material.dart';
import 'addCustomerAddressPage.dart';

class CustomerAddressBookPage extends StatefulWidget {
  @override
  _CustomerAddressBookPageState createState() => _CustomerAddressBookPageState();
}

class _CustomerAddressBookPageState extends State<CustomerAddressBookPage> {
  Map<String, dynamic>? _savedAddress;

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
                  MaterialPageRoute(
                    builder: (_) => AddCustomerAddressPage(),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _savedAddress = result;
                  });
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

            if (_savedAddress != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.black),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_savedAddress!['firstName']} ${_savedAddress!['lastName']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_savedAddress!['phone']),
                        SizedBox(height: 4),
                        Text(
                          '${_savedAddress!['street']}, ${_savedAddress!['barangay']}, ${_savedAddress!['municipality']}, ${_savedAddress!['city']}',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            // Set default address logic if needed
                          },
                          child: Text('Default Address'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            side: BorderSide(color: Colors.black),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Optional: navigate to edit page
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
              )
            ]
          ],
        ),
      ),
    );
  }
}
