import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/firebase/firestore.dart';
import "package:collection/collection.dart";
import 'package:grocery_store/models/grocery_item.dart';
import 'package:grocery_store/widgets/item_group.dart';

Map<String, List<QueryDocumentSnapshot<GroceryItem>>> _mapper(
    QuerySnapshot<GroceryItem> snapshot) {
  return groupBy(
      snapshot.docs.toList(), (snapshot) => snapshot.get("category") as String);
}

class BrowseScreen extends StatelessWidget {
  final Stream<Map<String, List<QueryDocumentSnapshot<GroceryItem>>>>
      _itemsStream = firestore
          .collection("items")
          .withConverter<GroceryItem>(
            fromFirestore: (snapshot, _) => GroceryItem.fromFirebase(snapshot),
            toFirestore: (model, _) => model.toFirebase(),
          )
          .snapshots()
          .map(_mapper);

  BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _itemsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Text(
              "Something went wrong. Please try again",
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final entry = snapshot.data!.entries.elementAt(index);

            return ItemGroup(
              category: entry.key,
              items: entry.value
                  .map(
                    (e) => e.data(),
                  )
                  .toList(),
            );
          },
        );
      },
    );
  }
}

class BrowseScreenAppBar extends StatelessWidget {
  const BrowseScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Browse");
  }
}
