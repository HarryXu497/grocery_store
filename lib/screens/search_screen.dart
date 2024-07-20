import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/firebase/firestore.dart';
import 'package:grocery_store/models/grocery_item.dart';
import 'package:grocery_store/utils/utils.dart';
import 'package:grocery_store/widgets/categorized_item_list.dart';

Query<GroceryItem> searchStream(
  String? searchTerm,
) {
  final itemsCollection =
      firestore.collection("items").withConverter<GroceryItem>(
            fromFirestore: (snapshot, _) => GroceryItem.fromFirebase(snapshot),
            toFirestore: (model, _) => model.toFirebase(),
          );

  if (searchTerm == null) {
    return itemsCollection;
  } else {
    searchTerm = searchTerm.toLowerCase();

    return itemsCollection.where(
      "nameLowercase",
      isGreaterThanOrEqualTo: searchTerm,
      isLessThan: searchTerm.substring(0, searchTerm.length - 1) +
          String.fromCharCode(
            searchTerm.codeUnitAt(searchTerm.length - 1) + 1,
          ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _itemsStream = searchStream(null).snapshots().map(categoryMapper);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
            builder: (context, controller) {
              return SearchBar(
                controller: controller,
                onSubmitted: (input) {
                  print(input);
                  controller.closeView(input);
                },
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (input) {
                  controller.openView();

                  setState(() {
                    _itemsStream =
                        searchStream(input).snapshots().map(categoryMapper);
                  });
                },
                leading: const Icon(Icons.search),
              );
            },
            suggestionsBuilder: (context, controller) async {
              final suggestions = await searchStream(controller.text).get();

              final suggestionNames =
                  suggestions.docs.map((doc) => doc.get("name") as String);

              return suggestionNames.map((name) {
                return ListTile(
                  title: Text(name),
                  onTap: () {
                    setState(() {
                      controller.closeView(name);
                    });
                  },
                );
              }).toList();
            },
          ),
        ),
        Expanded(
          child: CategorizedItemList(
            itemsStream: _itemsStream,
          ),
        ),
      ],
    );
  }
}

class SearchScreenAppBar extends StatelessWidget {
  const SearchScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Search");
  }
}
