import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/firebase/auth.dart';
import 'package:grocery_store/firebase/firestore.dart';
import 'package:grocery_store/models/cart_item.dart';

const taxRate = 0.13;

CollectionReference<CartGroceryItem> getCart() {
  if (auth.currentUser == null) {
    throw ArgumentError("The user is not logged in.");
  }

  return firestore
      .collection("carts")
      .doc(auth.currentUser!.uid)
      .collection("items")
      .withConverter<CartGroceryItem>(
        fromFirestore: (snapshot, _) => CartGroceryItem.fromFirebase(snapshot),
        toFirestore: (model, _) => model.toFirebase(),
      );
}

class CartScreen extends StatelessWidget {
  final _cartStream = getCart().snapshots();

  CartScreen({super.key});

  Future<void> _onPress(CartGroceryItem cartItem, int currentNum) async {
    if (currentNum <= 0) {
      return;
    }

    final cart = getCart();

    final cartItemDoc = cart.doc(cartItem.item.id);

    await cartItemDoc.update({
      "quantitySelected": currentNum,
    });
  }

  Future<void> _onSwipe(CartGroceryItem cartItem, BuildContext context) async {
    final cart = getCart();

    final cartItemDoc = cart.doc(cartItem.item.id);

    await cartItemDoc.delete();
  }

  void _showSnackBar(CartGroceryItem cartItem, BuildContext context) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "'${cartItem.item.name}' has been removed from your cart.",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _cartStream,
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

        final items = snapshot.data!.docs;

        final subtotal = snapshot.data!.docs
            .map((cartItem) =>
                (cartItem.get("quantitySelected") as int) *
                (cartItem.get("price") as double))
            .sum;
        final total = subtotal * (taxRate + 1);

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: snapshot.data!.size,
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemBuilder: (context, index) {
                    final cartItem = items.elementAt(index).data();
                    return Dismissible(
                      key: Key(cartItem.item.id),
                      onDismissed: (direction) async {
                        await _onSwipe(cartItem, context);

                        _showSnackBar(cartItem, context);
                      },
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                        minVerticalPadding: 4,
                        leading: Image.network(
                          cartItem.item.imageURLs[0],
                          fit: BoxFit.cover,
                          width: 70.0,
                          height: 70.0,
                        ),
                        title: Text(
                          cartItem.item.name,
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Text(
                          "\$${cartItem.item.price}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: ItemCounter(
                          onPress: _onPress,
                          cartItem: cartItem,
                          initialCount: cartItem.quantitySelected,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subtotal: "),
                  Text(
                    "\$${subtotal.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total: "),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(
                height: 80.0,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CheckOutButton extends StatelessWidget {
  CheckOutButton({super.key});

  late Map<String, dynamic>? _paymentIntent;

  Future<double> _calculateTotal() async {
    CollectionReference<CartGroceryItem> cart = getCart();

    QuerySnapshot<CartGroceryItem> snapshot = await cart.get();

    final subtotal = snapshot.docs
        .map((cartItem) =>
            (cartItem.get("quantitySelected") as int) *
            (cartItem.get("price") as double))
        .sum;

    return subtotal * (taxRate + 1);
  }

  Future<void> _makePayment() async {
    final total = await _calculateTotal();

    try {
      _paymentIntent = await _createPaymentIntent(total, "USD");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: _paymentIntent!["client_secret"],
          style: ThemeMode.light,
          merchantDisplayName: "GroceryStore",
        ),
      );

      _displayPaymentSheet();
    } catch (e) {
      rethrow;
    }
  }

  int _calculateAmount(double amount) {
    return (amount * 100).floor();
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
      double amount, String currency) async {
    if (dotenv.env["STRIPE_SECRET"] == null) {
      throw ArgumentError(
          "The environment variable 'STRIPE_SECRET' does not exist.");
    }

    try {
      Map<String, dynamic> body = {
        "amount": _calculateAmount(amount).toString(),
        "currency": currency,
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          "Authorization": "Bearer ${dotenv.env["STRIPE_SECRET"]!}",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );

      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      
      _paymentIntent = null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          backgroundColor: WidgetStatePropertyAll<Color>(
              Theme.of(context).colorScheme.primary),
          foregroundColor: WidgetStatePropertyAll<Color>(
              Theme.of(context).colorScheme.onPrimary),
        ),
        onPressed: _makePayment,
        child: const Center(
          child: Text("Check out now!"),
        ),
      ),
    );
  }
}

class ItemCounter extends StatelessWidget {
  final Future<void> Function(CartGroceryItem cartItem, int currentNum) onPress;
  final CartGroceryItem cartItem;
  final int initialCount;

  const ItemCounter({
    super.key,
    required this.cartItem,
    required this.initialCount,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              await onPress(cartItem, initialCount - 1);
            },
            icon: const Icon(Icons.remove),
            iconSize: 14.0,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
            "$initialCount",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          IconButton(
            onPressed: () async {
              await onPress(cartItem, initialCount + 1);
            },
            icon: const Icon(Icons.add),
            iconSize: 14.0,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class CartScreenAppBar extends StatelessWidget {
  const CartScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Your Cart");
  }
}
