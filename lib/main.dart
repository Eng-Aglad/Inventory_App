import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Inventory App/login page.dart';
import 'Inventory App/new order.dart';
import 'Inventory App/new suplier.dart';
//import 'orders.dart'; // Import your Orders page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(const InventoryApp());  // Start the app
}

