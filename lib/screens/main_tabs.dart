import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';

class MainTabs extends StatefulWidget {
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ProfileScreen(),
    Center(child: Text('Sync Now pressed!')), // Placeholder for Sync action
    SubscriptionScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      // Sync button pressed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync Now Pressed!')),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 90,  // Increased height here
        decoration: BoxDecoration(
          color: Color(0xFF002B53),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.person,
                size: 32,
                color: _selectedIndex == 0 ? Colors.orange : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(0),
            ),

            // Fixed width button instead of Expanded
            SizedBox(
              width: 160,  // Fixed width of the Sync Now button
              child: ElevatedButton.icon(
                onPressed: () => _onItemTapped(1),
                icon: Icon(Icons.refresh, size: 24, color: Colors.white,),
                label: Text(
                  'Sync Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            IconButton(
              icon: Icon(
                Icons.credit_card,
                size: 28,
                color: _selectedIndex == 2 ? Colors.orange : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
