import 'package:flutter/material.dart';
import 'customerPage.dart';

class SelectUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Marden Hub\nLaundry and Water Refilling',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPage()));
            },
            child: Text('Customer'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white,),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // TODO: Staff Page
            },
            child: Text('Staff'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white,),
          ),
        ],
      ),
    );
  }
}
