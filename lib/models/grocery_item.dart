import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItem {
  final String category;
  final String imageURL;
  final String name;
  final int quantity;
  final double price;

  GroceryItem({
    required this.category,
    required this.imageURL,
    required this.name,
    required this.quantity,
    required this.price,
  });

  GroceryItem.fromFirebase(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : category = snapshot.get("category"),
        imageURL = snapshot.get("imageURL"),
        name = snapshot.get("name"),
        quantity = snapshot.get("quantity") as int,
        price = snapshot.get("price") as double;

  Map<String, Object?> toFirebase() {
    return {
      "category": category,
      "imageURL": imageURL,
      "name": name,
      "quantity": quantity,
      "price": price,
    };
  }
}
