import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(
          color: Colors.white,
        ), // sets back arrow color to white
        title: Text(
          'Transactions',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body:
          user == null
              ? Center(child: Text('You must be logged in to view this page.'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('transactions')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No transactions found.'));
                  }

                  final transactions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final data =
                          transactions[index].data() as Map<String, dynamic>;

                      final serviceName = data['serviceName'] ?? 'Unknown';
                      final amount = data['amount'] ?? 0;
                      final type = data['type'] ?? '';
                      final timestamp =
                          data['timestamp'] != null
                              ? (data['timestamp'] as Timestamp).toDate()
                              : null;

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(
                            type == 'Laundry'
                                ? Icons.local_laundry_service
                                : Icons.local_drink,
                            color: Colors.blueAccent,
                          ),
                          title: Text(serviceName),
                          subtitle: Text(
                            timestamp != null
                                ? DateFormat(
                                  'MMM d, y • h:mm a',
                                ).format(timestamp)
                                : 'No date',
                          ),
                          trailing: Text('₱$amount'),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
