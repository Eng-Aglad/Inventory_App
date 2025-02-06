import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart';
import 'new suplier.dart'; // Assuming this page exists
import 'dashboard.dart'; // Your DashboardPage

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
      title: 'Suppliers App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: SuppliersPage(),
    );
  }
}

class SuppliersPage extends StatefulWidget {
  @override
  _SuppliersPageState createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for suppliers data
  late Stream<QuerySnapshot> _suppliersStream;

  @override
  void initState() {
    super.initState();
    _suppliersStream = _firestore.collection('suplier').snapshots(); // Stream for Firestore data
  }

  // Delete supplier from Firestore
  Future<void> _deleteSupplier(String supplierId) async {
    try {
      await _firestore.collection('suplier').doc(supplierId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Supplier deleted successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete supplier: $e')));
    }
  }

  // Update supplier information
  Future<void> _updateSupplier(String supplierId) async {
    // Fetch supplier's current data
    DocumentSnapshot supplierSnapshot = await _firestore.collection('suplier').doc(supplierId).get();
    var supplierData = supplierSnapshot.data() as Map<String, dynamic>;

    // Initialize text controllers with current supplier data
    TextEditingController _productSuppliedController = TextEditingController(text: supplierData['product_supplied']);
    TextEditingController _buyingPriceController = TextEditingController(text: supplierData['buying_price'].toString());
    TextEditingController _unitController = TextEditingController(text: supplierData['unit']);
    TextEditingController _contactNumberController = TextEditingController(text: supplierData['contact_number']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Supplier"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Product Supplied", "Enter product supplied", _productSuppliedController),
                const SizedBox(height: 8),
                _buildTextField("Buying Price", "Enter buying price", _buyingPriceController, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _buildTextField("Unit", "Enter unit", _unitController),
                const SizedBox(height: 8),
                _buildTextField("Contact Number", "Enter contact number", _contactNumberController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _firestore.collection('suplier').doc(supplierId).update({
                    'product_supplied': _productSuppliedController.text,
                    'buying_price': double.parse(_buyingPriceController.text), // Ensure double value is used
                    'unit': _unitController.text,
                    'contact_number': _contactNumberController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Supplier updated successfully")));
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update supplier: $e')));
                }
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Custom method to build text fields with validation
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to AddSupplierPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewSupplierPage()),
                    );
                  },
                  child: const Text('Add Supplier'),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to PreviewSuppliersPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardView()),
                    );
                  },
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Data table
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _suppliersStream, // Listen for Firestore data
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  }

                  final suppliers = snapshot.data?.docs ?? [];

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
                          DataColumn(label: Text('Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Product Supplied', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Buying Price', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _buildDataRows(suppliers), // Populate the rows dynamically
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to PreviewSuppliersPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardView()),
                    );
                  },
                  child: const Text('Preview'),
                ),
                const Text('Page 1 of 10'),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to NextSuppliersPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewSupplierPage()),
                    );
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds the DataTable Rows based on Firestore data
  List<DataRow> _buildDataRows(List<QueryDocumentSnapshot> suppliers) {
    return suppliers.map((supplier) {
      final data = supplier.data() as Map<String, dynamic>;
      final supplierId = supplier.id;

      return DataRow(cells: [
        DataCell(Text(data['supplier_name'] ?? '')),
        DataCell(Text(data['product_supplied'] ?? '')),
        DataCell(Text(data['buying_price']?.toString() ?? '')), // Convert price to String if it's a double
        DataCell(Text(data['unit'] ?? '')),
        DataCell(Text(data['contact_number'] ?? '')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _updateSupplier(supplierId),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteSupplier(supplierId),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }
}
