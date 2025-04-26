import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerProfilePageEdit.dart';
import 'customerChangePasswordPage.dart';
import '../screens/customerLoginPage.dart';

class CustomerProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('customers').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(child: Text('No user data found.'));
          }

          final displayName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          final phoneNumber = userData['phoneNumber'] ?? 'No Phone';
          final address = userData['address'] ?? 'No Address';

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
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(displayName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(phoneNumber),
                      Text(address),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              Text("Account Settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              ListTile(
                leading: Icon(Icons.person),
                title: Text("Account Information"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage()));
                },
              ),
              Divider(),

              ListTile(
                leading: Icon(Icons.lock),
                title: Text("Change Password"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage()));
                },
              ),
              Divider(),

              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete Account"),
                onTap: () {
                  _showDeleteConfirmation(context);
                },
              ),
              Divider(),

              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Log Out"),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                final uid = user?.uid;

                // Delete Firestore document
                if (uid != null) {
                  await FirebaseFirestore.instance.collection('customers').doc(uid).delete();
                }

                // Delete Auth account
                await user?.delete();

                // Navigate back to login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerLoginPage()),
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete account: $e')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog first
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
