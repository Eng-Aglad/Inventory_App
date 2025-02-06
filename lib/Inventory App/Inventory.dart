import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_core/firebase_core.dart'; // Firebase core for initialization
import 'package:my_project1/Inventory%20App/products.dart';
import 'dashboard.dart'; // Replace with your actual Dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const InventoryApp());
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: const InventoryDashboard(),
    );
  }
}

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({Key? key}) : super(key: key);

  @override
  _InventoryDashboardState createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = _firestore.collection('inventory').snapshots(); // Stream for Firestore data
  }

  // Delete product from Firestore
  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('inventory').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product deleted successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
    }
  }

  // Update product information
  Future<void> _updateProduct(String productId) async {
    TextEditingController _productNameController = TextEditingController();
    TextEditingController _categoryController = TextEditingController();
    TextEditingController _buyingPriceController = TextEditingController();
    TextEditingController _unitController = TextEditingController();
    TextEditingController _registerDateController = TextEditingController();

    // Fetch current data from Firestore
    DocumentSnapshot productSnapshot = await _firestore.collection('inventory').doc(productId).get();
    var productData = productSnapshot.data() as Map<String, dynamic>;

    // Pre-populate the fields with the existing data
    _productNameController.text = productData['productName'] ?? '';
    _categoryController.text = productData['category'] ?? '';
    _buyingPriceController.text = productData['buyingPrice']?.toString() ?? '';
    _unitController.text = productData['unit'] ?? '';
    _registerDateController.text = productData['registerDate'] ?? '';

    // Show the update dialog with pre-populated data
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Product"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Product Name", "Enter product name", _productNameController),
                const SizedBox(height: 8),
                _buildTextField("Category", "Enter category", _categoryController),
                const SizedBox(height: 8),
                _buildTextField("Buying Price", "Enter buying price", _buyingPriceController, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _buildTextField("Unit", "Enter unit", _unitController),
                const SizedBox(height: 8),
                _buildTextField("Register Date", "Enter register date", _registerDateController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _firestore.collection('inventory').doc(productId).update({
                    'productName': _productNameController.text,
                    'category': _categoryController.text,
                    'buyingPrice': double.parse(_buyingPriceController.text),
                    'unit': _unitController.text,
                    'registerDate': _registerDateController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product updated successfully")));
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update product: $e')));
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
        title: const Text('Inventory Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCardsSection(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewProductForm()),
                        );
                      },
                      child: const Text('Add Product'),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   child: const Text('Filters'),
                    // ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _productsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  }

                  final products = snapshot.data?.docs ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Product Name')),
                        DataColumn(label: Text('Category Name')),
                        DataColumn(label: Text('Buying Price')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Register Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _buildProductRows(products),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to previous page (if any)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardView()),
                    );
                  },
                  child: const Text('Previous'),
                ),
                const Text('Page 1 of 10'),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to next page (if any)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewProductForm()),
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

  List<DataRow> _buildProductRows(List<QueryDocumentSnapshot> products) {
    return products.map((product) {
      final data = product.data() as Map<String, dynamic>;
      final productId = product.id;

      return DataRow(cells: [
        DataCell(Text(data['productName'] ?? '')),
        DataCell(Text(data['category'] ?? '')),
        DataCell(Text(data['buyingPrice']?.toString() ?? '')),
        DataCell(Text(data['unit'] ?? '')),
        DataCell(Text(data['registerDate'] ?? '')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _updateProduct(productId),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProduct(productId),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  // Scrollable Stat Cards Section
  Widget _buildStatCardsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Enables horizontal scrolling
      child: Row(
        children: _buildStatCards(),
      ),
    );
  }

  List<Widget> _buildStatCards() {
    return [

    ];
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(right: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
