// Project imports:
import '../../imports.dart';

class SliverPersistentHeaderDelegateWidget
    extends SliverPersistentHeaderDelegate {
  final PreferredSize? child;

  SliverPersistentHeaderDelegateWidget({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child!;
  }

  @override
  double get maxExtent => child!.preferredSize.height;

  @override
  double get minExtent => child!.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
