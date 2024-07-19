import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItem {
  final String category;
  final List<String> imageURLs;
  final String name;
  final String quantity;
  final double price;

  GroceryItem({
    required this.category,
    required this.imageURLs,
    required this.name,
    required this.quantity,
    required this.price,
  });

  GroceryItem.fromFirebase(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : category = snapshot.get("category"),
        imageURLs = List<String>.from(snapshot.get("imageURLs")),
        name = snapshot.get("name"),
        quantity = snapshot.get("quantity"),
        price = snapshot.get("price") as double;

  Map<String, Object?> toFirebase() {
    return {
      "category": category,
      "imageURLs": imageURLs,
      "name": name,
      "quantity": quantity,
      "price": price,
    };
  }
}
