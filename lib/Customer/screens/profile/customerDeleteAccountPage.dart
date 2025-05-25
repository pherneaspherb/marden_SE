import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (user != null && uid != null) {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(uid)
            .delete();
        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in again before deleting your account.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred.')),
        );
      }
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to permanently delete your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _deleteAccount();
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child:
            _isDeleting
                ? CircularProgressIndicator()
                : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever, size: 100, color: Colors.red),
                      SizedBox(height: 24),
                      Text(
                        'This action is irreversible.\nYour account and all data will be permanently deleted.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _confirmDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        child: Text('Delete My Account'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
