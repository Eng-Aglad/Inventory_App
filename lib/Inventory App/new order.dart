import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore import
import 'orders.dart';  // Your OrdersPage file

class NewOrderScreen extends StatefulWidget {
  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  bool notifyOnDelivery = false;

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController buyingPriceController = TextEditingController();
  final TextEditingController dateOfDeliveryController = TextEditingController();
  final TextEditingController ProductOrderedController = TextEditingController();
  final TextEditingController categoryNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Order"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Improved app bar color
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
                        "New Order",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField("Order Person", "Enter Order person", productNameController),
                      const SizedBox(height: 16),
                      _buildTextField("Product Ordered", "Enter Product ordered", ProductOrderedController),
                      const SizedBox(height: 16),
                      _buildTextField("Category Name", "Enter category name", categoryNameController),
                      const SizedBox(height: 16),
                      _buildTextField("Quantity", "Enter product quantity", quantityController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildTextField("Buying Price", "Enter buying price", buyingPriceController, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),

                      // Date of Delivery Picker
                      _buildDatePickerField(),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: notifyOnDelivery,
                            onChanged: (value) {
                              setState(() {
                                notifyOnDelivery = value!;
                              });
                            },
                          ),
                          const Text("Notify on the date of delivery"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to PreviewPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrdersPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              //primary: Colors.grey[300],
                              //onPrimary: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Preview'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              //primary: Colors.blueAccent, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _submitOrder();  // Call the method to save data to Firestore
                              }
                            },
                            child: const Text("Submit Order"),
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
              return "Please enter $label";
            }
            return null;
          },
        ),
      ],
    );
  }

  // Date of Delivery Picker
  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date of Delivery",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: dateOfDeliveryController,
          decoration: InputDecoration(
            hintText: "Pick the date of delivery",
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
              return 'Please select a delivery date';
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
        dateOfDeliveryController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
      });
    }
  }

  // Submit order to Firestore
  Future<void> _submitOrder() async {
    try {
      // Create a new order document in Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'order_person': productNameController.text,
        'product_ordered': ProductOrderedController.text,
        'category_name': categoryNameController.text,
        'quantity': quantityController.text,
        'buying_price': buyingPriceController.text,
        'date_of_delivery': dateOfDeliveryController.text,
        'notify_on_delivery': notifyOnDelivery,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order submitted successfully!")),
      );

      // Optionally, navigate to the orders page or reset the form
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrdersPage(),
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting order: $e')),
      );
    }
  }
}
