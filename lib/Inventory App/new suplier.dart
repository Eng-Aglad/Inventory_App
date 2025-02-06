import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project1/Inventory%20App/suplier.dart'; // Import Firestore

void main() {
  runApp(const InventoryApp());  // The entry point of the app
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: const NewSupplierPage(),  // The starting page of your app
    );
  }
}

class NewSupplierPage extends StatefulWidget {
  const NewSupplierPage({Key? key}) : super(key: key);

  @override
  State<NewSupplierPage> createState() => _NewSupplierPageState();
}

class _NewSupplierPageState extends State<NewSupplierPage> {
  String? _selectedCategory;

  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController buyingPriceController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitSupplier() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Create new supplier document in Firestore
        await FirebaseFirestore.instance.collection('suplier').add({
          'supplier_name': supplierNameController.text,
          'product_supplied': productController.text,
          'buying_price': buyingPriceController.text,
          'contact_number': contactNumberController.text,
          'unit': unitController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Supplier submitted successfully!")),
        );

        // Optionally, navigate to another page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuppliersPage()),
        );
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting supplier: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Supplier'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Supplier',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Supplier Name
                      _buildTextField("Supplier Name", "Enter supplier name", supplierNameController),
                      const SizedBox(height: 16),

                      // Product Supplied
                      _buildTextField("Product Supplied", "Enter product supplied", productController),
                      const SizedBox(height: 16),

                      // Buying Price
                      _buildTextField("Buying Price", "Enter buying price", buyingPriceController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),

                      // Unit
                      _buildTextField("Unit", "Enter unit", unitController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),

                      // Contact Number
                      _buildTextField("Contact Number", "Enter contact number", contactNumberController, keyboardType: TextInputType.phone),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _submitSupplier,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Submit Supplier',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to SuppliersPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  SuppliersPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // primary: Colors.grey[300],
                              // onPrimary: Colors.black,
                            ),
                            child: const Text(
                              'Preview',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom TextField with validation
  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
