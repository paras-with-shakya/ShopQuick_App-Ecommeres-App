import 'package:flutter/material.dart';
import 'package:shopquick_app/models/cart.dart';
import 'package:shopquick_app/models/product.dart';
import 'package:shopquick_app/services/cart_service.dart';
import 'package:shopquick_app/services/product_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Cart>> _cartsFuture;

  @override
  void initState() {
    super.initState();
    _cartsFuture = CartService().fetchAllCarts();
  }

  void _refreshCarts() {
    setState(() {
      _cartsFuture = CartService().fetchAllCarts();
    });
  }

  Future<Map<int, Product>> _fetchProductsForCarts(List<Cart> carts) async {
    final ids = <int>{};
    for (var cart in carts) {
      for (var p in cart.products) {
        ids.add(p.productId);
      }
    }

    final results = <int, Product>{};
    final futures = ids.map((id) => ProductService().fetchProductById(id));
    final fetched = await Future.wait(futures);
    int idx = 0;
    for (var id in ids) {
      final prod = fetched[idx++];
      if (prod != null) results[id] = prod;
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: const Color.fromARGB(255, 2, 242, 202),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshCarts(),
        child: FutureBuilder<List<Cart>>(
          future: _cartsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final carts = snapshot.data ?? [];
            if (carts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add items from the store to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            int totalItems = 0;
            for (var c in carts) {
              totalItems += c.totalItems;
            }

            return FutureBuilder<Map<int, Product>>(
              future: _fetchProductsForCarts(carts),
              builder: (context, prodSnap) {
                if (prodSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final productMap = prodSnap.data ?? {};

                double totalPrice = 0.0;
                for (var c in carts) {
                  for (var cp in c.products) {
                    final p = productMap[cp.productId];
                    if (p != null) totalPrice += p.price * cp.quantity;
                  }
                }

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 2, 242, 202),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total Items: $totalItems',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Total: ₹${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: carts.length,
                        itemBuilder: (context, cartIndex) {
                          final cart = carts[cartIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Cart #${cart.id} - User ${cart.userId}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            2,
                                            242,
                                            202,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${cart.totalItems} items',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Delete cart button
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () async {
                                          final messenger =
                                              ScaffoldMessenger.of(context);

                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (dialogContext) => AlertDialog(
                                              title: const Text('Delete cart'),
                                              content: const Text(
                                                'Are you sure you want to delete this cart?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    dialogContext,
                                                  ).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    dialogContext,
                                                  ).pop(true),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm != true) return;

                                          try {
                                            final ok = await CartService()
                                                .deleteCart(cart.id);

                                            if (!mounted) return;

                                            if (ok) {
                                              _refreshCarts();
                                              messenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text('Cart deleted'),
                                                ),
                                              );
                                            } else {
                                              messenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Failed to delete cart',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (!mounted) return;
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error deleting cart: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cart.products.length,
                                itemBuilder: (context, productIndex) {
                                  final cp = cart.products[productIndex];
                                  final prod = productMap[cp.productId];
                                  if (prod == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[200],
                                            ),
                                            child: Image.network(
                                              prod.image,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  prod.title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  prod.category,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '₹${prod.price.toStringAsFixed(2)} x ${cp.quantity}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        color: Colors.grey[100],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.remove,
                                                              size: 18,
                                                            ),
                                                            onPressed: () async {
                                                              final messenger =
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  );

                                                              final newQty =
                                                                  cp.quantity -
                                                                  1;

                                                              try {
                                                                await CartService()
                                                                    .updateProductQuantity(
                                                                      cartId:
                                                                          cart.id,
                                                                      productId:
                                                                          cp.productId,
                                                                      quantity:
                                                                          newQty,
                                                                    );

                                                                if (!mounted) {
                                                                  return;
                                                                }

                                                                _refreshCarts();

                                                                messenger.showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                      'Cart updated',
                                                                    ),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                if (!mounted) {
                                                                  return;
                                                                }

                                                                messenger.showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Failed to update cart: $e',
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      8.0,
                                                                ),
                                                            child: Text(
                                                              '${cp.quantity}',
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.add,
                                                              size: 18,
                                                            ),
                                                            onPressed: () async {
                                                              final messenger =
                                                                  ScaffoldMessenger.of(
                                                                    context,
                                                                  );

                                                              final newQty =
                                                                  cp.quantity +
                                                                  1;

                                                              try {
                                                                await CartService()
                                                                    .updateProductQuantity(
                                                                      cartId:
                                                                          cart.id,
                                                                      productId:
                                                                          cp.productId,
                                                                      quantity:
                                                                          newQty,
                                                                    );

                                                                if (!mounted) {
                                                                  return;
                                                                }

                                                                _refreshCarts();

                                                                messenger.showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                      'Cart updated',
                                                                    ),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                if (!mounted) {
                                                                  return;
                                                                }

                                                                messenger.showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Failed to update cart: $e',
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                height: 16,
                                indent: 12,
                                endIndent: 12,
                              ),
                            ],
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                2,
                                242,
                                202,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Checkout functionality coming soon!',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
