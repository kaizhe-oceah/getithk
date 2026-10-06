// Project imports:
import '../../imports.dart';

class AppBarActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double size;
  final EdgeInsets? padding;

  const AppBarActionButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = kToolbarHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellWrapper(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: padding,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
