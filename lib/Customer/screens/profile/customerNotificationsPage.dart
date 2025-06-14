import 'package:flutter/material.dart';

class CustomerNotificationsPage extends StatefulWidget {
  @override
  _CustomerNotificationsPageState createState() =>
      _CustomerNotificationsPageState();
}

class _CustomerNotificationsPageState extends State<CustomerNotificationsPage> {
  bool _remindToPickup = false;
  bool _notifyWhenDone = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B007D),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Remind me to pick up order'),
            value: _remindToPickup,
            activeColor: Color(0xFF4B007D),
            onChanged: (value) {
              setState(() {
                _remindToPickup = value;
              });
            },
          ),
          Divider(),
          SwitchListTile(
            title: Text('Notify me when order is done'),
            value: _notifyWhenDone,
            activeColor: Color(0xFF4B007D),
            onChanged: (value) {
              setState(() {
                _notifyWhenDone = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
