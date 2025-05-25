import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerAccountSettingsPage.dart';
import 'customerNotificationsPage.dart';
import '../customerLoginPage.dart';
import 'customerAddressBookPage.dart';

class CustomerProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('customers')
                .doc(uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(child: Text('No user data found.'));
          }

          final displayName =
              '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                  .trim();
          final phoneNumber = userData['phoneNumber'] ?? 'No Phone';

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF4B007D),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [SizedBox(height: 4), Text(phoneNumber)],
                  ),
                ),
              ),
              SizedBox(height: 24),

              Text(
                "General",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Account Settings"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerAccountSettingsPage(),
                    ),
                  );
                },
              ),
              Divider(),

              ListTile(
                leading: Icon(Icons.notifications),
                title: Text("Notifications & Reminders"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerNotificationsPage(),
                    ),
                  );
                },
              ),
              Divider(),

              ListTile(
                leading: Icon(
                  Icons.location_on_outlined,
                  color: Colors.black54,
                ),
                title: Text('Address Book'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerAddressBookPage(),
                    ),
                  );
                },
              ),
              Divider(),

              SizedBox(height: 40),

              ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  "Log Out",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _showLogoutConfirmation(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Log Out'),
            content: Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => CustomerLoginPage()),
                    (route) => false,
                  );
                },
                child: Text('Log Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
