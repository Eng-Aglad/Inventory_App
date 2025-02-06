import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_core/firebase_core.dart';

import 'manage store.dart'; // Firebase core for initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store Management',
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
      home: const NewStore(),
    );
  }
}

class NewStore extends StatefulWidget {
  const NewStore({Key? key}) : super(key: key);

  @override
  State<NewStore> createState() => _NewStorePageState();
}

class _NewStorePageState extends State<NewStore> {
  final _formKey = GlobalKey<FormState>(); // FormKey for validation
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController buyingPriceController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();

  // Stream for store data
  late Stream<QuerySnapshot> _storeStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to listen to the 'store' collection in Firestore
    _storeStream = _firestore.collection('store').snapshots();
  }

  // Function to submit store data to Firebase Firestore
  Future<void> _submitStore() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Submit data to Firestore (store collection)
        await _firestore.collection('store').add({
          'product_name': productNameController.text,
          'product_type': productController.text,
          'branch_name': branchNameController.text,
          'buying_price': double.parse(buyingPriceController.text),
          'contact_number': contactNumberController.text,
          'timestamp': FieldValue.serverTimestamp(), // Add timestamp for sorting
        });

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Store submitted successfully!")),
        );

        // Optionally, clear the form after submission
        productNameController.clear();
        productController.clear();
        buyingPriceController.clear();
        contactNumberController.clear();
        branchNameController.clear();
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting store: $e')),
        );
      }
    }
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
            if (label == 'Buying Price' && double.tryParse(value) == null) {
              return 'Please enter a valid price';
            }
            if (label == 'Contact Number' && value.length != 10) {
              return 'Please enter a valid 10-digit contact number';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Function to delete a store
  Future<void> _deleteStore(String storeId) async {
    try {
      await _firestore.collection('store').doc(storeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Store deleted successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting store: $e')));
    }
  }

  // Function to update a store
  Future<void> _updateStore(String storeId, Map<String, dynamic> data) async {
    TextEditingController productNameController = TextEditingController(text: data['product_name']);
    TextEditingController productTypeController = TextEditingController(text: data['product_type']);
    TextEditingController branchNameController = TextEditingController(text: data['branch_name']);
    TextEditingController buyingPriceController = TextEditingController(text: data['buying_price'].toString());
    TextEditingController contactNumberController = TextEditingController(text: data['contact_number']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Store"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Product Name", "Enter product name", productNameController),
                const SizedBox(height: 16),
                _buildTextField("Product Type", "Enter product type", productTypeController),
                const SizedBox(height: 16),
                _buildTextField("Branch Name", "Enter branch name", branchNameController),
                const SizedBox(height: 16),
                _buildTextField("Buying Price", "Enter buying price", buyingPriceController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField("Contact Number", "Enter supplier contact number", contactNumberController, keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _firestore.collection('store').doc(storeId).update({
                        'product_name': productNameController.text,
                        'product_type': productTypeController.text,
                        'branch_name': branchNameController.text,
                        'buying_price': double.parse(buyingPriceController.text),
                        'contact_number': contactNumberController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Store updated successfully")));
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating store: $e')));
                    }
                  },
                  child: const Text("Update Store"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Builds the DataTable Rows based on Firestore data
  List<DataRow> _buildStoreRows(List<QueryDocumentSnapshot> stores) {
    return stores.map((store) {
      final data = store.data() as Map<String, dynamic>;
      final storeId = store.id;

      return DataRow(
        cells: [
          DataCell(Text(data['product_name'] ?? '')),
          DataCell(Text(data['product_type'] ?? '')),
          DataCell(Text(data['branch_name'] ?? '')),
          DataCell(Text(data['buying_price'].toString() ?? '')),
          DataCell(Text(data['contact_number'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _updateStore(storeId, data),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteStore(storeId),
              ),
            ],
          )),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Management'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Store',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 24),

              // Store Form
              Form(
                key: _formKey, // Attach FormKey to Form widget
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Product Name", "Enter product name", productNameController),
                    const SizedBox(height: 16),
                    _buildTextField("Product Type", "Enter product type", productController),
                    const SizedBox(height: 16),
                    _buildTextField("Branch Name", "Enter branch name", branchNameController),
                    const SizedBox(height: 16),
                    _buildTextField("Buying Price", "Enter buying price", buyingPriceController, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField("Contact Number", "Enter supplier contact number", contactNumberController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 24),

                    // Buttons Row (Preview and Submit Store)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoreManager(),
                              ),
                            );
                            // Add your preview page functionality here
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Preview'),
                        ),
                        ElevatedButton(
                          onPressed: _submitStore, // Submit store on press
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Submit Store'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Store List Section
              const Text(
                'Store List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Store List Table
              StreamBuilder<QuerySnapshot>(
                stream: _storeStream, // Listen for Firestore data
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  }

                  final stores = snapshot.data?.docs ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 20,
                        border: TableBorder(
                          horizontalInside: BorderSide(width: 0.5, color: Colors.grey.shade300),
                        ),
                        columns: const [
                          DataColumn(label: Text('Product Name')),
                          DataColumn(label: Text('Product Type')),
                          DataColumn(label: Text('Branch Name')),
                          DataColumn(label: Text('Buying Price')),
                          DataColumn(label: Text('Contact Number')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _buildStoreRows(stores),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
