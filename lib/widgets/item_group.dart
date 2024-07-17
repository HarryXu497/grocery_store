import 'package:flutter/material.dart';
import 'package:grocery_store/models/grocery_item.dart';
import 'package:grocery_store/widgets/item_display.dart';

class ItemGroup extends StatelessWidget {
  const ItemGroup({
    super.key,
    required this.category,
    required this.items,
  });

  final String category;
  final List<GroceryItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 230,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, _) => const SizedBox(width: 10,),
              itemBuilder: (context, index) {
                final item = items.elementAt(index);

                return ItemDisplay(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}
