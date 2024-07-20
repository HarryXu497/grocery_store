import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/firebase/auth.dart';
import 'package:grocery_store/firebase/firestore.dart';
import 'package:grocery_store/models/grocery_item.dart';

class ItemScreen extends StatelessWidget {
  final GroceryItem item;

  const ItemScreen({
    super.key,
    required this.item,
  });

  Future<void> _onPressed() async {
    if (auth.currentUser == null) {
      return;
    }

    final cartItems = firestore
        .collection("carts")
        .doc(auth.currentUser!.uid)
        .collection("items");

    final itemDocRef = firestore.collection("items").doc(item.id);

    final itemQuery = cartItems.where("item", isEqualTo: itemDocRef);

    final resultItems = await itemQuery.get();

    if (resultItems.size == 0) {
      // Item not yet added to cart
      await cartItems.add({
        "item": itemDocRef,
        "quantity": 1,
      });
    } else if (resultItems.size == 1) {
      // Update existing doc - increment quantity
      final itemDoc = resultItems.docs.first;

      await itemDoc.reference.set({
        "quantity": itemDoc.get("quantity") + 1,
      }, SetOptions(merge: true));
    }
  }

  void _showSnackBar(BuildContext context) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "'${item.name}' has been added to your cart.",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
              },
              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary,),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Back"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemHeader(item: item),
            const SizedBox(height: 4.0),
            Hero(
              tag: "item-image-${item.id}",
              child: ItemImageCarousel(item: item),
            ),
            const SizedBox(height: 8.0),
            Text(
              "\$${item.price} ea",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 18.0),
            Text(
              "Get this item with your grocery order",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
            const SizedBox(height: 4.0),
            TextButton(
              onPressed: () async {
                await _onPressed();

                _showSnackBar(context);
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minimumSize: WidgetStateProperty.all<Size>(
                    const Size(double.infinity, 30.0),
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ))),
              child: Text(
                "Add to Cart",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemImageCarousel extends StatefulWidget {
  const ItemImageCarousel({
    super.key,
    required this.item,
  });

  final GroceryItem item;

  @override
  State<StatefulWidget> createState() {
    return _ItemImageCarousel();
  }
}

class _ItemImageCarousel extends State<ItemImageCarousel> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 4.0 / 3.0,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            items: widget.item.imageURLs.map(
              (url) {
                return Builder(
                  builder: (context) {
                    return Image.network(url,
                        fit: BoxFit.cover, width: double.infinity);
                  },
                );
              },
            ).toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.item.imageURLs.asMap().entries.map(
            (entry) {
              final color = Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black;

              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(_current == entry.key ? 0.8 : 0.3),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class ItemHeader extends StatelessWidget {
  const ItemHeader({
    super.key,
    required this.item,
  });

  final GroceryItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          item.quantity,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
