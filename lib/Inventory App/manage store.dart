import 'package:flutter/material.dart';

import 'add store.dart';
import 'dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoreManager(),
    );
  }
}

class StoreManager extends StatelessWidget {
  final List<Store> stores = [
    Store(name: "Lisy Store", branch: "Dubai Branch", address: "1A/Khinarapuram, 3rd Street Sulur", phone: "6313403"),
    Store(name: "Lisy Store", branch: "Mogadishu Branch", address: "54 Ramani Colony, 3rd Street Sulur", phone: "6313403"),
    Store(name: "Lisy Store", branch: "China Branch", address: "32/ Venkatasamy Layout, 1st Street Sulur", phone: "6313403"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Store'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: stores.length,
              itemBuilder: (context, index) {
                return StoreCard(store: stores[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to AddStorePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewStore()),
                      );
                    },
                    child: Text('Add Store'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50), // Full-width button
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to PreviewStoresPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardView()),
                      );
                    },
                    child: Text('Preview'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50), // Full-width button
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final Store store;

  StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.branch, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text(store.name),
            SizedBox(height: 4.0),
            Text("Address: ${store.address}"),
            SizedBox(height: 4.0),
            Text("Phone: ${store.phone}"),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Action for editing the store
                },
                child: Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Store {
  final String name;
  final String branch;
  final String address;
  final String phone;

  Store({required this.name, required this.branch, required this.address, required this.phone});
}

// Add Store Page
class AddStorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Store'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Store',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Store Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Branch',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle adding store functionality
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full-width button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Preview Stores Page
class PreviewStoresPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Stores'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'This is the Preview Stores Page',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}
