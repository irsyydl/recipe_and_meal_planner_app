import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset(
                'assets/dishdash-high-resolution-logo-transparent.png',
                fit: BoxFit.contain,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Shopping List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/shoppingList');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Meal Planner'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/mealPlanner');
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload Recipe'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/uploadRecipe');
              },
            ),
          ],
        ),
      ),
    );
  }
}