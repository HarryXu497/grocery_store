import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:grocery_store/models/grocery_item.dart';

Map<String, List<QueryDocumentSnapshot<GroceryItem>>> categoryMapper(
    QuerySnapshot<GroceryItem> snapshot) {
  return groupBy(
    snapshot.docs.toList(),
    (snapshot) => snapshot.get("category") as String,
  );
}
