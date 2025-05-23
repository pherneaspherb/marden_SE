import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orderDetailsPage.dart';

class CustomerOrdersPage extends StatefulWidget {
  @override
  _CustomerOrdersPageState createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  int _selectedTab = 0; // 0 = Laundry, 1 = Water

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF4B007D),
          title: Text('Orders'),
        ),
        body: Center(child: Text('User not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Orders',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16), // Top spacing from AppBar
        child: Column(
          children: [
            _buildTabButtons(),
            Expanded(
              child:
                  _selectedTab == 0
                      ? _buildLaundryOrders(context, uid)
                      : _buildWaterOrders(context, uid),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40.0,
      ), // Matches TransactionsPage
      child: Row(
        children: [
          _tabButton('Laundry', 0),
          const SizedBox(width: 10),
          _tabButton('Water', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final bool isSelected = _selectedTab == index;

    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTab = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFF4B007D) : Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildLaundryOrders(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('customers')
              .doc(uid)
              .collection('laundryOrders')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty)
          return Center(child: Text('No laundry orders found.'));

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => OrderDetailsPage(
                            orderData: data,
                            orderType: 'Laundry Hub',
                          ),
                    ),
                  ),
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepPurple.shade100),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.deepPurple.shade50,
                      child: Icon(
                        Icons.local_laundry_service,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(
                              data['status'] ?? 'pending',
                              'Laundry Hub',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'To pay: ₱${data['totalAmount']} via ${data['paymentMethod']}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaterOrders(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('customers')
              .doc(uid)
              .collection('waterOrders')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text('No water orders found.'));

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => OrderDetailsPage(
                            orderData: data,
                            orderType: 'Water Station',
                          ),
                    ),
                  ),
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(Icons.local_drink, color: Colors.blue),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(
                              data['status'] ?? 'pending',
                              'Water Station',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'To pay: ₱${data['totalPrice']} via ${data['paymentMethod']}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getStatusText(String status, String serviceType) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Your $serviceType order is completed.';
      case 'cancelled':
        return 'Your $serviceType order was cancelled.';
      default:
        return 'Your $serviceType order is being processed.';
    }
  }
}
