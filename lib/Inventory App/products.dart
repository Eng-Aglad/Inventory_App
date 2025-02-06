import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Correct import for Firestore
//import 'package:my_project1/Inventory%20App/product%20overview.dart'; // Assuming you have this page in your app
import 'Inventory.dart';

class NewProductForm extends StatefulWidget {
  @override
  _NewProductFormState createState() => _NewProductFormState();
}

class _NewProductFormState extends State<NewProductForm> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _buyingPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _registerDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // FormKey for form validation
  final _firestore = FirebaseFirestore.instance; // Correct initialization for Firestore

  // Function to add product to the 'inventory' collection
  Future<void> _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Add product to Firestore
        await _firestore.collection('inventory').add({
          'productName': _productNameController.text,
          'category': _categoryController.text,
          'buyingPrice': double.parse(_buyingPriceController.text),
          'quantity': int.parse(_quantityController.text),
          'unit': _unitController.text,
          'registerDate': _registerDateController.text,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added to inventory successfully!')),
        );

        // Navigate to the product overview page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InventoryDashboard()),
        );
      } catch (e) {
        // Show error message if the product fails to add
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Product'),
        centerTitle: true,
        elevation: 4, // Adding a subtle shadow
        backgroundColor: Colors.blueAccent, // Slightly different shade for the app bar
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
                        'Add New Product',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Product Name Field
                      _buildTextField("Product Name", "Enter product name", _productNameController),
                      const SizedBox(height: 16),

                      // Category Field
                      _buildTextField("Category Name", "Enter category name", _categoryController),
                      const SizedBox(height: 16),

                      // Buying Price Field
                      _buildTextField("Buying Price", "Enter buying price", _buyingPriceController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),

                      // Quantity Field
                      _buildTextField("Quantity", "Enter quantity", _quantityController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),

                      // Unit Field
                      _buildTextField("Unit", "Enter unit", _unitController),
                      const SizedBox(height: 16),

                      // Register Date Field (Date Picker)
                      _buildDatePickerField(),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _addProduct,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Submit Product',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to PreviewPage or any other page
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => InventoryDashboard()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
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

  // Register Date Field (Date Picker)
  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Register Date",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _registerDateController,
          decoration: InputDecoration(
            hintText: "Pick the register date",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[200],
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDate,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a register date';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Date picker function
  Future<void> _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _registerDateController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
      });
    }
  }
}
