import 'package:flutter/material.dart';
import 'package:shopquick_app/all_category.dart';
import 'package:shopquick_app/pages/category_products_page.dart';
import 'package:shopquick_app/services/category_service.dart';
import 'package:shopquick_app/widgets/common_header.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> categories = [];
  int _selectedTabIndex = 0;
  bool _categoriesLoaded = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _loadCategories();
  }

  void _initializeTabController() {
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _loadCategories() async {
    if (_isInitialized) return;

    try {
      List<String> loadedCategories = await CategoryService().fetchCategories();
      if (mounted && !_isInitialized) {
        setState(() {
          categories = loadedCategories;
          _categoriesLoaded = true;
          _isInitialized = true;
          _updateTabController();
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _categoriesLoaded = true;
          _isInitialized = true;
        });
      }
    }
  }

  void _updateTabController() {
    if (!mounted) return;

    final newLength = categories.length + 1;
    final oldController = _tabController;

    // Create new controller for new length
    _tabController = TabController(
      length: newLength,
      vsync: this,
      initialIndex: _selectedTabIndex < newLength ? _selectedTabIndex : 0,
    );
    _tabController.addListener(_handleTabChange);

    // Dispose old controller after creating new one
    Future.delayed(Duration.zero, () {
      oldController.dispose();
    });
  }

  void _handleTabChange() {
    if (mounted && !_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    }
  }

  void _onCategorySelected(String category) {
    int index = 0;
    if (category == 'Home') {
      index = 0;
    } else {
      index = categories.indexOf(category) + 1;
    }
    if (index < _tabController.length && index != _tabController.index) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CommonHeader(
            categories: categories,
            onCategorySelected: _onCategorySelected,
            selectedTabIndex: _selectedTabIndex,
          ),
          Expanded(
            child: _categoriesLoaded
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      const AllCategoryPage(), // Home tab
                      ...categories.map((category) {
                        return CategoryProductsPage(category: category);
                      }),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
