// Project imports:
import '../imports.dart';

class AppSkeletonizer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  const AppSkeletonizer({required this.child, this.enabled = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      enableSwitchAnimation: false,
      effect: const ShimmerEffect(
        baseColor: Color.fromARGB(255, 228, 228, 228),
        highlightColor: Color(0xFFF5F5F5),
        duration: Duration(milliseconds: 1500),
      ),
      child: child,
    );
  }
}
