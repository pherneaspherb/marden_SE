import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'receiptPage.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Color _primaryColor = const Color(0xFF4B007D);
  final Color _secondaryTextColor = Colors.black54;
  int _selectedTab = 0; // 0 for Laundry, 1 for Water

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                  const Icon(Icons.history, color: Colors.black),
                ],
              ),
            ),
            
            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildTabButton(0, 'Laundry'),
                  const SizedBox(width: 10),
                  _buildTabButton(1, 'Water'),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Recent',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _secondaryTextColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: user == null
                  ? _buildNotLoggedIn()
                  : _selectedTab == 0
                      ? _buildLaundryOrders(user)
                      : _buildWaterOrders(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedTab = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedTab == index ? _primaryColor : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: _selectedTab == index ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Text(
        'You must be logged in to view transactions.',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: _secondaryTextColor,
        ),
      ),
    );
  }

  Widget _buildLaundryOrders(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('laundryOrders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No laundry orders found.');
        }

        return _buildLaundryOrderList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildWaterOrders(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .collection('waterOrders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No water orders found.');
        }

        return _buildWaterOrderList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator(color: _primaryColor));
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 60, color: _secondaryTextColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: _secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaundryOrderList(List<QueryDocumentSnapshot> orders) {
    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final data = orders[index].data() as Map<String, dynamic>;
        final serviceType = data['serviceType'] ?? 'Unknown Service';
        final weight = data['weight']?.toString() ?? '0';
        final totalAmount = data['totalAmount'] ?? 0.0;
        final deliveryMode = data['deliveryMode'] ?? 'Unknown';
        final timestamp = data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : null;
        final extras = data['extras'] is List ? data['extras'] as List<dynamic> : [];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_laundry_service, color: _primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceType,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${weight}kg • $deliveryMode',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: _secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₱${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (extras.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: extras.map((extra) => Chip(
                    label: Text(extra.toString()),
                    backgroundColor: Colors.grey[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timestamp != null
                        ? DateFormat('d MMM y, hh:mm a').format(timestamp)
                        : 'No date',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _secondaryTextColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _viewReceipt(context, data, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Receipt',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaterOrderList(List<QueryDocumentSnapshot> orders) {
    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final data = orders[index].data() as Map<String, dynamic>;
        final type = data['type'] ?? 'Water';
        final quantity = data['quantity']?.toString() ?? '0';
        final totalPrice = data['totalPrice'] ?? 0.0;
        final deliveryMode = data['deliveryMode'] ?? 'Unknown';
        final timestamp = data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : null;
        final containerType = data['containerType'] ?? 'Unknown';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.water_drop, color: _primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$quantity containers • $containerType',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: _secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₱${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timestamp != null
                        ? DateFormat('d MMM y, hh:mm a').format(timestamp)
                        : 'No date',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: _secondaryTextColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _viewReceipt(context, data, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Receipt',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewReceipt(BuildContext context, Map<String, dynamic> data, bool isLaundry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptPage(
          orderData: data,
          isLaundryOrder: isLaundry,
        ),
      ),
    );
  }
}