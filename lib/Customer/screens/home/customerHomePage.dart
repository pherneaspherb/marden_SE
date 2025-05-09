import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'laundryHubPage.dart';
import 'waterStationPage.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Left-align
                  children: [
                    Text(
                      'Welcome, ${fullName ?? "User"} 👋',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 80),

                    // Laundry Hub Button
                    _buildGradientButton(
                      icon: Icons.local_laundry_service,
                      label: 'Laundry Hub',
                      gradientColors: [Colors.deepPurple, Colors.purpleAccent],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LaundryHubPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Water Station Button
                    _buildGradientButton(
                      icon: Icons.opacity,
                      label: 'Water Station',
                      gradientColors: [Colors.lightBlueAccent, Colors.blue],
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
      ),
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            offset: Offset(0, 6),
            blurRadius: 10,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
