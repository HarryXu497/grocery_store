import 'package:flutter/material.dart';
import 'package:grocery_store/models/grocery_item.dart';

class ItemDisplay extends StatelessWidget {
  final GroceryItem item;

  const ItemDisplay({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 230,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            print("Tap.");
          },
          child: Stack(
            children: [
              CoverImage(item: item),
              CardText(item: item)
            ],
          ),
        ),
      ),
    );
  }
}

class CardText extends StatelessWidget {
  const CardText({
    super.key,
    required this.item,
  });

  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 155,
      left: 8,
      right: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                item.quantity.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          Text(
            "\$${item.price}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.item,
  });

  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          border: Border.all(
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          child: Image.network(
            item.imageURL,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
