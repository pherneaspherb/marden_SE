import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'laundryHubPage.dart';
import 'waterStationPage.dart'; // ✅ Import the Water Station page

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String? fullName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .get();

      final data = doc.data();
      setState(() {
        fullName = data?['firstName'] ?? 'User';
        _isLoading = false;
      });
    } catch (e) {
      print('🔥 Error loading user data: $e');
      setState(() {
        fullName = 'User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${fullName ?? "User"} 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildMainButton(
                    icon: Icons.local_laundry_service,
                    label: 'Laundry Hub',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LaundryHubPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildMainButton(
                    icon: Icons.opacity,
                    label: 'Water Station',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WaterStationPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMainButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
