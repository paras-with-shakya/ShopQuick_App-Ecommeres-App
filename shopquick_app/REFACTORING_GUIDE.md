# ShopQuick App Refactoring Guide

## Overview
This document describes the comprehensive refactoring performed on the ShopQuick Flutter application to improve code quality, maintainability, and user experience.

## Major Changes Implemented

### 1. **Exception Handling & Error Management** ✅
- **Created custom exception classes**:
  - `AppException` - Base exception class
  - `NetworkException` - For network/API errors
  - `TimeoutException` - For request timeouts
  - `ValidationException` - For input validation errors
  
- **Created centralized ErrorHandler**:
  - `ErrorHandler.getMessage()` - Convert exceptions to user-friendly messages
  - `ErrorHandler.showErrorSnackbar()` - Display errors to users
  - `ErrorHandler.showErrorDialog()` - Show error dialogs
  - `ErrorHandler.logError()` - Log error details for debugging

**Location**: `lib/core/errors/`

---

### 2. **Project Structure Reorganization** ✅
```
lib/
├── core/                          # Core application layer
│   ├── constants/
│   │   ├── api_constants.dart     # API endpoints and configuration
│   │   └── app_constants.dart     # App-wide constants
│   ├── errors/                    # Custom exception classes
│   │   ├── app_exception.dart
│   │   ├── network_exception.dart
│   │   ├── timeout_exception.dart
│   │   ├── validation_exception.dart
│   │   └── error_handler.dart
│   ├── services/
│   │   └── api_service.dart       # Centralized HTTP client
│   └── utils/
│       └── logger_service.dart    # Logging utility
├── shared/                         # Shared components
│   ├── theme/
│   │   ├── app_colors.dart        # Color palette
│   │   └── app_theme.dart         # Theme definitions
│   └── widgets/                    # Reusable UI widgets
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── custom_app_bar.dart
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── empty_state_widget.dart
├── features/                       # Feature modules (to be created)
│   ├── auth/
│   ├── home/
│   └── products/
├── services/                       # Business logic services (refactored)
│   ├── auth_service.dart          # Now uses ApiService + proper exceptions
│   ├── product_service.dart       # Now uses ApiService + proper exceptions
│   ├── category_service.dart      # Now uses ApiService + proper exceptions
│   └── cart_service.dart          # Now uses ApiService + proper exceptions
├── pages/                          # UI screens (to be refactored)
├── models/                         # Data models
└── main.dart                       # App entry point (updated)
```

---

### 3. **Centralized API Service** ✅
- **ApiService Class**: Single point for all HTTP requests
  - Methods: `get()`, `post()`, `put()`, `delete()`
  - Built-in error handling and logging
  - Automatic JSON serialization/deserialization
  - Timeout handling
  - Response validation

**Location**: `lib/core/services/api_service.dart`

**Usage Example**:
```dart
final apiService = ApiService();
final response = await apiService.get(url);
```

---

### 4. **Refactored Services** ✅
All services have been refactored to use the new ApiService and throw proper exceptions:

#### **ProductService**
- Uses ApiService instead of raw http package
- Throws appropriate exceptions (NetworkException, ValidationException, TimeoutException)
- Added comprehensive logging
- Improved input validation

#### **CategoryService**
- Modern exception handling
- Centralized API configuration

#### **AuthService**
- Proper error handling for authentication failures
- Integrated with error handler
- Token management with validation

#### **CartService**
- Full CRUD operations with error handling
- Instance-based instead of static
- Cart count notification system
- Input validation for all parameters

---

### 5. **Reusable Components** ✅
Created a library of common widgets for consistent UI:

#### **CustomButton**
- Multiple button types: Primary, Secondary, Outline, Text
- Loading state support
- Disabled state handling
- Icon support

#### **CustomTextField**
- Password visibility toggle
- Icon support (prefix/suffix)
- Validation support
- Flexible configuration

#### **LoadingWidget**
- Spinner with optional message
- Full screen or inline variants
- Skeleton loader for placeholders
- Shimmer effect for better UX

#### **ErrorWidget**
- User-friendly error display
- Retry button support
- Customizable icons and messages

#### **EmptyStateWidget**
- Empty list state display
- Call-to-action button
- Customizable messaging

#### **CustomAppBar**
- Consistent app bar styling
- Back button handling
- Custom title styling

**Location**: `lib/shared/widgets/`

---

### 6. **Centralized Theme System** ✅
- **AppColors**: Comprehensive color palette
- **AppTheme**: Light and dark theme definitions
  - Consistent button styling
  - Input field styling
  - Text styles hierarchy
  - Card and divider themes

**Usage**:
```dart
theme: AppTheme.lightTheme(),
darkTheme: AppTheme.darkTheme(),
```

**Location**: `lib/shared/theme/`

---

### 7. **Logging System** ✅
Created `LoggerService` for comprehensive application logging:
- API request/response logging
- Error tracking with stack traces
- Debug information
- Multiple log levels (verbose, debug, info, warning, error, fatal)

**Usage**:
```dart
final logger = LoggerService();
logger.info('Message');
logger.error('Error message', error, stackTrace);
logger.logApiRequest(method: 'GET', url: 'https://...');
```

**Location**: `lib/core/utils/logger_service.dart`

---

### 8. **Constants Management** ✅
- **ApiConstants**: API endpoints, timeouts, retry configuration
- **AppConstants**: SharedPreferences keys, cache durations, UI timings

**Location**: `lib/core/constants/`

---

## Remaining Tasks (Next Steps)

### **Phase 2: Page Refactoring**
All existing pages should be updated to:
1. Use the new exception handling
2. Display loading states using `LoadingWidget`
3. Show error messages using `ErrorWidget` or `ErrorHandler`
4. Use custom reusable widgets (`CustomButton`, `CustomTextField`, etc.)
5. Add proper try-catch blocks with error handling

Example refactoring pattern:
```dart
class ProductListPage extends StatefulWidget {
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Products'),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget(message: 'Loading products...');
          }
          
          if (snapshot.hasError) {
            return ErrorWidget(
              message: ErrorHandler.getMessage(snapshot.error),
              onRetry: () => setState(() {
                _productsFuture = ProductService().fetchAllProducts();
              }),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyStateWidget(
              message: 'No products found',
              actionLabel: 'Refresh',
              onAction: () => setState(() {
                _productsFuture = ProductService().fetchAllProducts();
              }),
            );
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final product = snapshot.data![index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}
```

### **Phase 3: State Management Enhancement**
Consider adding Provider or Riverpod for better state management:
- App-wide state (user authentication)
- Cart state
- Product list state

### **Phase 4: Additional Improvements**
- [ ] Unit tests for services
- [ ] Widget tests for reusable components
- [ ] Integration tests for critical user flows
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] CI/CD pipeline integration

---

## Dependencies Added

```yaml
provider: ^6.4.0          # State management (optional for now)
logger: ^2.1.0            # Logging utility
connectivity_plus: ^6.0.0 # Network connectivity detection
get_it: ^7.6.0           # Service locator (optional for now)
equatable: ^2.0.5        # Value equality helpers
```

---

## Key Principles Implemented

1. **Single Responsibility**: Each class/widget has one clear purpose
2. **DRY (Don't Repeat Yourself)**: Reusable components and services
3. **Error Handling**: Comprehensive exception handling throughout
4. **Logging**: All important operations are logged
5. **User Feedback**: Loading states, error messages, empty states
6. **Code Organization**: Clear folder structure following clean architecture
7. **Consistency**: Unified theme, colors, and styling
8. **Performance**: Optimized API calls, caching opportunities documented

---

## Migration Guide for Existing Code

### Before (Old Pattern):
```dart
// Direct http usage, silent error handling
final response = await http.get(Uri.parse(url));
if (response.statusCode == 200) {
  return jsonDecode(response.body);
} else {
  return null; // Silent failure
}
```

### After (New Pattern):
```dart
// Using ApiService with proper exceptions
try {
  final response = await apiService.get(url);
  return MyModel.fromJson(response);
} catch (e) {
  ErrorHandler.showErrorSnackbar(context, e);
  rethrow;
}
```

---

## Troubleshooting

### Issue: "Package not found" errors
**Solution**: Run `flutter pub get` to install new dependencies from pubspec.yaml

### Issue: Import errors for new classes
**Solution**: Use the barrel export files (index.dart) for easier imports:
```dart
// Instead of:
import 'package:shopquick_app/core/errors/app_exception.dart';
import 'package:shopquick_app/core/errors/network_exception.dart';

// Use:
import 'package:shopquick_app/core/errors/index.dart';
```

---

## Contact & Support
For questions about the refactoring, refer to the documentation in each module's folder.
