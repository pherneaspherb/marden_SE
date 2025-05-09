import 'package:flutter/material.dart';
import 'selectUserPage.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SelectUserPage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Text(
          'Marden Hub\nLaundry and Water Refilling',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
