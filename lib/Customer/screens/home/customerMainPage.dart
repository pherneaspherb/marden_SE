import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'customerHomePage.dart';
import '../order/customerOrdersPage.dart';
import '../transactions/customerTransactionsPage.dart';
import '../profile/customerProfilePage.dart';

class CustomerMainPage extends StatefulWidget {
  @override
  _CustomerMainPageState createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _hasUserData = false;

  final List<Widget> _pages = [
    CustomerHomePage(),
    CustomerOrdersPage(),
    TransactionsPage(),
    CustomerProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print("🧪 Checking user data for UID: $uid");

    if (uid == null) {
      print("❗ UID is null. User not logged in?");
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('customers')
              .doc(uid)
              .get();

      print("📄 Document exists? ${doc.exists}");

      if (doc.exists) {
        setState(() {
          _hasUserData = true;
        });
      } else {
        print("⚠️ No user data found in 'customers' collection for UID: $uid");
      }
    } catch (e) {
      print("🔥 Error fetching user doc: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("✅ Finished checking user data");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasUserData) {
      return Scaffold(
        body: Center(
          child: Text(
            "User data not found.\nPlease try logging in again.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Color(0xFF4B007D),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
