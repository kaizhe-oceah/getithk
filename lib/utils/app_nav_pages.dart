// Project imports:
import '../imports.dart';
import '../models/bottom_nav_model.dart';
import '../pages/activity_page.dart';
import '../pages/backpack_page.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';

/// 🏠 User navigation setup
// Iconsax: plain names are the Bold (filled) style, `_copy` the Linear
// (outline) one. 首頁 and 活動 use Material icons: the closest to the
// design (Iconsax has no chimney house, and its calendar pairs don't match).
const List<BottomNavModel> kUserBottomNavList = [
  BottomNavModel(
    id: kBottomNavHome,
    title: AppStrings.home,
    iconOn: Icons.house,
    iconOff: Icons.house_outlined,
    page: HomePage(),
  ),
  BottomNavModel(
    id: kBottomNavBackpack,
    title: AppStrings.backpack,
    iconOn: Iconsax.layer,
    iconOff: Iconsax.layer_copy,
    page: BackpackPage(),
  ),
  BottomNavModel(
    id: kBottomNavActivity,
    title: AppStrings.activity,
    iconOn: Icons.calendar_month,
    iconOff: Icons.calendar_month_outlined,
    page: ActivityPage(),
  ),
  BottomNavModel(
    id: kBottomNavProfile,
    title: AppStrings.memberCenter,
    iconOn: Iconsax.user,
    iconOff: Iconsax.user_copy,
    page: ProfilePage(),
  ),
];
