// Project imports:
import '../imports.dart';

class UnfocusWrapper extends StatelessWidget {
  final Widget child;
  final Function()? onTap;
  const UnfocusWrapper({required this.child, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unfocusKeyboard();

        if (onTap != null) {
          onTap!();
        }
      },
      behavior:
          HitTestBehavior.opaque, // Ensures taps on empty space are detected
      child: child,
    );
  }
}
