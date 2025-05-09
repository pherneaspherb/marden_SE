import 'package:flutter/material.dart';

class CustomerNotificationsPage extends StatefulWidget {
  @override
  _CustomerNotificationsPageState createState() => _CustomerNotificationsPageState();
}

class _CustomerNotificationsPageState extends State<CustomerNotificationsPage> {
  bool _remindToPickup = false;
  bool _notifyWhenDone = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(
          color: Colors.white,
        ), // sets back arrow color to white
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
            activeColor: Colors.deepPurple,
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
            activeColor: Colors.deepPurple,
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
