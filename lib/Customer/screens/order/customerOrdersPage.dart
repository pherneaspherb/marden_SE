import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orderDetailsPage.dart'; // ✅ Make sure this path is correct

class CustomerOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    print('Current user UID: $uid');

    if (uid == null) {
      return Center(child: Text('User not logged in.'));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(child: Text('Laundry', style: TextStyle(fontSize: 16))),
              Tab(child: Text('Water', style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLaundryOrders(context, uid),
            _buildWaterOrders(context, uid),
          ],
        ),
      ),
    );
  }

  Widget _buildLaundryOrders(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .collection('laundryOrders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text('No laundry orders found.'));

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsPage(
                    orderData: data,
                    orderType: 'Laundry Hub',
                  ),
                ),
              ),
              child: _buildOrderCard(
                icon: Icons.local_laundry_service,
                title: 'Your laundry is being processed.',
                subtitle: 'To pay: ₱${data['totalAmount']} via ${data['paymentMethod']}',
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaterOrders(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .collection('waterOrders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text('No water orders found.'));

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsPage(
                    orderData: data,
                    orderType: 'Water Station',
                  ),
                ),
              ),
              child: _buildOrderCard(
                icon: Icons.local_drink,
                title: 'Your water is being processed.',
                subtitle: 'To pay: ₱${data['totalPrice']} via ${data['paymentMethod']}',
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
