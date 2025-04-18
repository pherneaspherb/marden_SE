import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>?> getUserProfile() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print("No user is currently logged in.");
      return null;
    }

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print("User Data: $userData");
      return userData;
    } else {
      print("User document does not exist.");
      return null;
    }
  } catch (e) {
    print("Error fetching user data: $e");
    return null;
  }
}
