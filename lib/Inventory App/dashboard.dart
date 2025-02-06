import 'package:flutter/material.dart';
import 'package:my_project1/Inventory%20App/suplier.dart';

import 'Inventory.dart';
import 'Reports.dart';
import 'login page.dart';
import 'manage store.dart';
import 'orders.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        textTheme: TextTheme(

        ),
      ),
      home: DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: dashboardItems.length,
          itemBuilder: (context, index) {
            final item = dashboardItems[index];
            return DashboardCard(
              icon: item.icon,
              title: item.title,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => item.page,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.2),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Model for dashboard items
class DashboardItem {
  final IconData icon;
  final String title;
  final Widget page;

  DashboardItem({
    required this.icon,
    required this.title,
    required this.page,
  });
}

// Placeholder pages
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'This is the $title page',
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ),
    );
  }
}

// List of all dashboard items
final List<DashboardItem> dashboardItems = [
  DashboardItem(
    icon: Icons.home,
    title: 'Dashboard',
    page: DashboardView(),
  ),
  DashboardItem(
    icon: Icons.inventory_2_outlined,
    title: 'Inventory',
    page: InventoryDashboard(),
  ),
  DashboardItem(
    icon: Icons.people_outline,
    title: 'Suppliers',
    page: SuppliersPage(),
  ),
  DashboardItem(
    icon: Icons.shopping_cart_outlined,
    title: 'Orders',
    page: OrdersPage(),
  ),
  DashboardItem(
    icon: Icons.bar_chart_outlined,
    title: 'Reports',
    page: DashboardScreen(),
  ),
  DashboardItem(
    icon: Icons.storefront_outlined,
    title: 'Manage Store',
    page: StoreManager(),
  ),
  DashboardItem(
    icon: Icons.logout_outlined,
    title: 'Log Out',
    page: LoginScreen(),
  ),
];