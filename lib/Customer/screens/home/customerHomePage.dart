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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4B007D),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome to Marden Hub!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your one-stop solution for all your daily needs, whether it’s fresh laundry or clean water delivered to your door.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What would you like to do today?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B007D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildGradientButton(
                        icon: Icons.local_laundry_service,
                        label: 'Laundry Hub',
                        gradientColors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LaundryHubPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildGradientButton(
                        icon: Icons.opacity,
                        label: 'Water Station',
                        gradientColors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
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
              ],
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
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 16,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
