import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/models/grocery_item.dart';

/// A [GroceryItem] obejct augmented with a [quantitySelected] proeprty which
/// specifies the amount added to cart by the user
class CartGroceryItem {
  final GroceryItem item;
  final int quantitySelected;

  CartGroceryItem({
    required this.item,
    required this.quantitySelected,
  });

  CartGroceryItem.fromFirebase(DocumentSnapshot<Map<String, dynamic>> snapshot)
    : item = GroceryItem.fromFirebase(snapshot),
      quantitySelected = snapshot.get("quantitySelected") as int;

  Map<String, Object?> toFirebase() {
    return {
      "category": item.category,
      "imageURLs": item.imageURLs,
      "name": item.name,
      "nameLowercase": item.nameLowercase,
      "quantity": item.quantity,
      "price": item.price,
      "quantitySelected": quantitySelected,
    };
  }
}
