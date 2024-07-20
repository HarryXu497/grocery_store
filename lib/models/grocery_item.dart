import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItem {
  final String id;
  final String category;
  final List<String> imageURLs;
  final String name;
  final String nameLowercase;
  final String quantity;
  final double price;

  GroceryItem({
    required this.id,
    required this.category,
    required this.imageURLs,
    required this.name,
    required this.nameLowercase,
    required this.quantity,
    required this.price,
  });

  GroceryItem.fromFirebase(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        category = snapshot.get("category"),
        imageURLs = List<String>.from(snapshot.get("imageURLs")),
        name = snapshot.get("name"),
        nameLowercase = snapshot.get("nameLowercase"),
        quantity = snapshot.get("quantity"),
        price = snapshot.get("price") as double;

  Map<String, Object?> toFirebase() {
    return {
      "category": category,
      "imageURLs": imageURLs,
      "name": name,
      "nameLowercase": nameLowercase,
      "quantity": quantity,
      "price": price,
    };
  }
}
