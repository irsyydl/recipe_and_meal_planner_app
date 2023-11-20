import 'package:flutter/material.dart';
import 'package:recipe_and_meal_planner_app/services/shopping_list_service.dart';

class ShoppingListScreen extends StatelessWidget {
  final ShoppingListService _shoppingListService = ShoppingListService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
      ),
      body: FutureBuilder<List<String>>(
        future: _shoppingListService.getShoppingList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String> shoppingList = snapshot.data ?? [];
            return ListView.builder(
              itemCount: shoppingList.length,
              itemBuilder: (context, index) {
                return ShoppingListItem(
                  itemName: shoppingList[index],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ShoppingListItem extends StatelessWidget {
  final String itemName;

  const ShoppingListItem({Key? key, required this.itemName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(itemName),
    );
  }
}
