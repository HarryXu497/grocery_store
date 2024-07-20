import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/firebase/firestore.dart';
import 'package:grocery_store/models/grocery_item.dart';
import 'package:grocery_store/utils/utils.dart';
import 'package:grocery_store/widgets/categorized_item_list.dart';

class BrowseScreen extends StatelessWidget {
  final Stream<Map<String, List<QueryDocumentSnapshot<GroceryItem>>>>
      _itemsStream = firestore
          .collection("items")
          .withConverter<GroceryItem>(
            fromFirestore: (snapshot, _) => GroceryItem.fromFirebase(snapshot),
            toFirestore: (model, _) => model.toFirebase(),
          )
          .snapshots()
          .map(categoryMapper);

  BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CategorizedItemList(itemsStream: _itemsStream);
  }
}

class BrowseScreenAppBar extends StatelessWidget {
  const BrowseScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Browse");
  }
}
