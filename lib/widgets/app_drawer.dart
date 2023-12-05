import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Navigation Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Shopping List'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/shoppingList');
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Meal Planner'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/mealPlanner');
            },
          ),
          ListTile(
            leading: Icon(Icons.upload),
            title: Text('Upload Recipe'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/uploadRecipe');
            },
          ),
        ],
      ),
    );
  }
}