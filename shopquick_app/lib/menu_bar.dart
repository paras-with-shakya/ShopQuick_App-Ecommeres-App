import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:shopquick_app/models/product.dart';
import 'package:shopquick_app/pages/cart_page.dart';
import 'package:shopquick_app/pages/login_page.dart';
import 'package:shopquick_app/pages/product_details_page.dart';
import 'package:shopquick_app/pages/profile_page.dart';
import 'package:shopquick_app/pages/settings_page.dart';
import 'package:shopquick_app/services/cart_service.dart';
import 'package:shopquick_app/services/category_service.dart';
import 'package:shopquick_app/services/product_service.dart';

class MenuIcon extends StatefulWidget {
  final List<String> categories;

  const MenuIcon({super.key, this.categories = const []});

  @override
  State<MenuIcon> createState() => _MenuIconState();
}

class _MenuIconState extends State<MenuIcon> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    // Use passed categories or fetch if empty
    if (widget.categories.isNotEmpty) {
      categories = widget.categories;
    } else {
      _loadCategories();
    }
  }

  void _loadCategories() async {
    List<String> loadedCategories = await CategoryService().fetchCategories();
    if (mounted) {
      setState(() {
        categories = loadedCategories;
      });
    }
  }

  String _formatCategoryName(String category) {
    return category
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.electrical_services;
      case 'jewelery':
        return Icons.diamond;
      case "men's clothing":
        return Icons.man;
      case "women's clothing":
        return Icons.woman;
      default:
        return Icons.shopping_bag;
    }
  }

  Widget _buildProductGrid(String category) {
    Future<List<Product>> future = category == 'all'
        ? ProductService().fetchAllProducts()
        : ProductService().fetchProductsByCategory(category);

    return FutureBuilder<List<Product>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  category == 'all'
                      ? 'No products available'
                      : 'No products in ${_formatCategoryName(category)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            8,
            8,
            8,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.55,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailsPage(productId: product.id),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.hardEdge,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_not_supported, size: 40),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '₹${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );

                                    try {
                                      await CartService().addToCart(
                                        userId: 1,
                                        productId: product.id,
                                      );

                                      if (!mounted) return;

                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Added to cart successfully',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to add to cart: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        2,
                                        242,
                                        202,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color.fromARGB(255, 2, 242, 202),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              // showTooltip: false,
              displayMode: SideMenuDisplayMode.auto,
              showHamburger: true,
              hoverColor: Colors.blue[100],
              selectedHoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.all(Radius.circular(10)),
              // ),
              // backgroundColor: Colors.grey[200]
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[600],
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 4),
                  Text(
                    textAlign: TextAlign.center,
                    'Welcome Back',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Divider(indent: 8.0, endIndent: 8.0),
                ],
              ),
            ),
            items: [
              SideMenuItem(
                title: 'Home',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                  pageController.jumpToPage(0);
                },
                icon: const Icon(Icons.home),
                tooltipContent: "Go to Home",
              ),
              ...categories.asMap().entries.map((entry) {
                String category = entry.value;
                return SideMenuItem(
                  title: _formatCategoryName(category),
                  onTap: (menuIndex, _) {
                    sideMenu.changePage(menuIndex);
                    pageController.jumpToPage(menuIndex);
                  },
                  icon: Icon(_getCategoryIcon(category)),
                  tooltipContent: category,
                );
              }),
              SideMenuItem(
                builder: (context, displayMode) {
                  return const Divider(endIndent: 8, indent: 8);
                },
              ),
              SideMenuItem(
                title: 'Shopping Cart',
                onTap: (index, _) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              SideMenuItem(
                title: 'Settings',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                  pageController.jumpToPage(categories.length + 3);
                },
                icon: const Icon(Icons.settings),
              ),
              SideMenuItem(
                title: 'Exit',
                onTap: (index, _) {
                  if (!mounted) return;

                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.exit_to_app),
              ),
            ],
          ),
          const VerticalDivider(width: 0),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                // Home page - All products
                _buildProductGrid('all'),
                // Category pages
                ...categories.map((category) {
                  return _buildProductGrid(category);
                }),
                // Divider space
                const SizedBox.shrink(),
                // Shopping Cart
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Shopping Cart',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
                // Settings
                const SettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
