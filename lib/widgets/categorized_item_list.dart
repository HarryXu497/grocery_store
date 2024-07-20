import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/models/grocery_item.dart';
import 'package:grocery_store/widgets/item_group.dart';

class CategorizedItemList extends StatelessWidget {
  const CategorizedItemList({
    super.key,
    required Stream<Map<String, List<QueryDocumentSnapshot<GroceryItem>>>> itemsStream,
  }) : _itemsStream = itemsStream;

  final Stream<Map<String, List<QueryDocumentSnapshot<GroceryItem>>>> _itemsStream;

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