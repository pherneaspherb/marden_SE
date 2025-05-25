import 'package:flutter/material.dart';

class AddressProvider extends ChangeNotifier {
  String street = "";
  String barangay = "";
  String municipality = "";
  String city = "";

  void updateAddress({
    required String newStreet,
    required String newBarangay,
    required String newMunicipality,
    required String newCity,
  }) {
    street = newStreet;
    barangay = newBarangay;
    municipality = newMunicipality;
    city = newCity;
    notifyListeners();
  }
}
