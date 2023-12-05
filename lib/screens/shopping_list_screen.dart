import 'package:flutter/material.dart';
import 'package:recipe_and_meal_planner_app/services/shopping_list_service.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListService _shoppingListService = ShoppingListService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _shoppingListService.getShoppingList(),
        builder: (context, snapshot) {
    List<Map<String, String>> shoppingList = snapshot.data ?? [];

    return ListView.builder(
      itemCount: shoppingList.length,
      itemBuilder: (context, index) {
        String ingredient = shoppingList[index]['ingredient']!;
        String recipeId = shoppingList[index]['recipeId']!;

        return ListTile(
          title: Text(ingredient),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _shoppingListService.removeIngredientFromShoppingList(recipeId, ingredient);
              setState(() {});
            },
          ),
        );
      },
    );
  },
),
    );
  }
}
