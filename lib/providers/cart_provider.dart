import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(String id, String title, double price, String image) {
    if (state.any((item) => item.id == id)) {
      state = [
        for (final item in state)
          if (item.id == id)
            CartItem(
              id: item.id,
              title: item.title,
              price: item.price,
              image: item.image,
              quantity: item.quantity + 1,
            )
          else
            item
      ];
    } else {
      state = [
        ...state,
        CartItem(id: id, title: title, price: price, image: image),
      ];
    }
  }

  void removeFromCart(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeFromCart(id);
      return;
    }
    state = [
      for (final item in state)
        if (item.id == id)
          CartItem(
            id: item.id,
            title: item.title,
            price: item.price,
            image: item.image,
            quantity: quantity,
          )
        else
          item
    ];
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
