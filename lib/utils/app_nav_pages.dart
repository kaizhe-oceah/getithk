// Project imports:
import '../imports.dart';
import '../models/bottom_nav_model.dart';
import '../pages/cart_page.dart';
import '../pages/favourite_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';

/// 🏠 User navigation setup
// Iconsax: plain names are the Bold (filled) style, `_copy` the Linear
// (outline) one.
const List<BottomNavModel> kUserBottomNavList = [
  BottomNavModel(
    id: kBottomNavHome,
    title: AppStrings.home,
    iconOn: Iconsax.home,
    iconOff: Iconsax.home_copy,
    page: HomePage(),
  ),
  BottomNavModel(
    id: kBottomNavCart,
    title: AppStrings.cart,
    iconOn: Iconsax.shopping_cart,
    iconOff: Iconsax.shopping_cart_copy,
    page: CartPage(),
  ),
  BottomNavModel(
    id: kBottomNavFavourite,
    title: AppStrings.favourite,
    iconOn: Iconsax.heart,
    iconOff: Iconsax.heart_copy,
    page: FavouritePage(),
  ),
  BottomNavModel(
    id: kBottomNavProfile,
    title: AppStrings.profile,
    iconOn: Iconsax.user,
    iconOff: Iconsax.user_copy,
    page: ProfilePage(),
  ),
];
