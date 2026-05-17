class CartProduct {
  // FakeStore carts API returns objects with productId and quantity
  final int productId;
  final int quantity;

  CartProduct({
    required this.productId,
    required this.quantity,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      productId: json['productId'] as int? ?? json['id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'id': productId,
      'quantity': quantity,
    };
  }
}

class Cart {
  final int id;
  final int userId;
  final List<CartProduct> products;

  Cart({
    required this.id,
    required this.userId,
    required this.products,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var productsList = <CartProduct>[];
    if (json['products'] is List) {
      productsList = (json['products'] as List<dynamic>)
          .map((p) => CartProduct.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return Cart(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      products: productsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

  // Helper to calculate total items in cart (sum of quantities)
  int get totalItems => products.fold(0, (sum, p) => sum + p.quantity);
}
