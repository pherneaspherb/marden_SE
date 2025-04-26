import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerProfilePageEdit.dart';
import 'customerChangePasswordPage.dart';
import '../screens/customerLoginPage.dart'; // <-- you forgot this!

class CustomerAccountSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
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
        ],
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
              Navigator.pop(context); // Close the dialog first
              try {
                final user = FirebaseAuth.instance.currentUser;
                final uid = user?.uid;

                if (uid != null) {
                  await FirebaseFirestore.instance.collection('customers').doc(uid).delete();
                }

                await user?.delete();

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
}
