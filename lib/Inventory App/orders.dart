import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart';
import 'new order.dart'; // Assuming this page exists
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
      title: 'Responsive Orders Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OrdersPage(),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _currentPage = 1;
  final int _totalPages = 10;
  final _formKey = GlobalKey<FormState>();

  // Fetch data from Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = _firestore.collection('orders').snapshots(); // Stream for Firestore data
  }

  // Delete order from Firestore
  Future<void> _deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order deleted successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete order: $e')));
    }
  }

  // Update order information
  Future<void> _updateOrder(String orderId) async {
    // Fetch the existing data of the selected order
    DocumentSnapshot orderSnapshot = await _firestore.collection('orders').doc(orderId).get();
    var orderData = orderSnapshot.data() as Map<String, dynamic>;

    // Initialize the controllers with the existing data
    TextEditingController _orderPersonController = TextEditingController(text: orderData['order_person']);
    TextEditingController _productOrderedController = TextEditingController(text: orderData['product_ordered']);
    TextEditingController _quantityController = TextEditingController(text: orderData['quantity'].toString());
    TextEditingController _buyingPriceController = TextEditingController(text: orderData['buying_price'].toString());
    TextEditingController _dateOfDeliveryController = TextEditingController(text: orderData['date_of_delivery']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Order"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Order Person", "Enter order person", _orderPersonController),
                const SizedBox(height: 8),
                _buildTextField("Product Ordered", "Enter product ordered", _productOrderedController),
                const SizedBox(height: 8),
                _buildTextField("Quantity", "Enter quantity", _quantityController, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _buildTextField("Buying Price", "Enter buying price", _buyingPriceController, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _buildTextField("Date of Delivery", "Enter delivery date", _dateOfDeliveryController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Update the order in Firestore with the new data
                  await _firestore.collection('orders').doc(orderId).update({
                    'order_person': _orderPersonController.text,
                    'product_ordered': _productOrderedController.text,
                    'quantity': int.parse(_quantityController.text),
                    'buying_price': double.parse(_buyingPriceController.text),
                    'date_of_delivery': _dateOfDeliveryController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order updated successfully")));
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
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
        title: const Text('Orders Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Orders Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewOrderScreen(),
                          ),
                        );
                      },
                      child: const Text('Add New Order'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardView(),
                          ),
                        );
                      },
                      child: const Text('Preview'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Orders Table (Scrollable)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _ordersStream, // Listen for Firestore data
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  }

                  final orders = snapshot.data?.docs ?? [];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Order Person')),
                          DataColumn(label: Text('Product Ordered')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Quantity')),
                          DataColumn(label: Text('Buying Price')),
                          DataColumn(label: Text('Date of Delivery')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _buildOrderRows(orders), // Populate the rows dynamically
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Pagination Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardView(),
                      ),
                    );
                  },
                  child: const Text('Preview'),
                ),
                Text('Page $_currentPage of $_totalPages'),
                ElevatedButton(
                  onPressed: _currentPage < _totalPages
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewOrderScreen(),
                      ),
                    );
                  }
                      : null,
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
  List<DataRow> _buildOrderRows(List<QueryDocumentSnapshot> orders) {
    return orders.map((order) {
      final data = order.data() as Map<String, dynamic>;
      final orderId = order.id;

      return DataRow(
        cells: [
          DataCell(Text(data['order_person'] ?? '')),
          DataCell(Text(data['product_ordered'] ?? '')),
          DataCell(Text(data['category_name'] ?? '')),
          DataCell(Text(data['quantity']?.toString() ?? '')),
          DataCell(Text(data['buying_price']?.toString() ?? '')),
          DataCell(Text(data['date_of_delivery'] ?? '')),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _updateOrder(orderId),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteOrder(orderId),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
