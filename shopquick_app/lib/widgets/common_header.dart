import 'package:flutter/material.dart';
import 'package:shopquick_app/menu_bar.dart';
import 'package:shopquick_app/pages/cart_page.dart';
import 'package:shopquick_app/search_box.dart';
import 'package:shopquick_app/services/cart_service.dart';

class CommonHeader extends StatefulWidget {
  final List<String>? categories;
  final ValueChanged<String>? onCategorySelected;
  final int selectedTabIndex;

  const CommonHeader({
    super.key,
    this.categories,
    this.onCategorySelected,
    this.selectedTabIndex = 0,
  });

  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  bool _cartInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCartCount();
  }

  void _initializeCartCount() {
    // Only initialize once
    if (_cartInitialized) return;
    _cartInitialized = true;

    if (CartService.cartCount.value == 0) {
      CartService.getTotalCartItemCount()
          .then((count) {
            if (mounted && CartService.cartCount.value != count) {
              CartService.cartCount.value = count;
            }
          })
          .catchError((e) {
            print('Error initializing cart count: $e');
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CartService.cartCount,
      builder: (context, cartCount, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top AppBar with Flipkart logo and actions
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color.fromARGB(255, 2, 242, 202),
              title: const Text(
                'ShopQuick',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/images/ShopQuick_logo.png'),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Searchpage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        // Make the badge ignore pointer events so it won't block the icon button tap
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 10,
                            ),
                            child: Text(
                              cartCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MenuIcon(categories: widget.categories ?? []),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu),
                ),
              ],
            ),
            // Category Tab Bar
            if (widget.categories != null && widget.categories!.isNotEmpty)
              Container(
                height: 80,
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryTab('Home', 0, context),
                      ...widget.categories!.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        String category = entry.value;
                        return _buildCategoryTab(category, index, context);
                      }),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryTab(String label, int index, BuildContext context) {
    bool isSelected = widget.selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20.0),
      child: GestureDetector(
        onTap: () {
          widget.onCategorySelected?.call(label);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(255, 2, 242, 202)
                : Colors.grey[200],
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Text(
            _formatCategoryName(label),
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    if (category == 'Home') return 'Home';
    return category
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
