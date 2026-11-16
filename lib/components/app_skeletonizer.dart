// Project imports:
import '../imports.dart';

class AppSkeletonizer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  const AppSkeletonizer({required this.child, this.enabled = true, super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;

    return Skeletonizer(
      enabled: enabled,
      enableSwitchAnimation: false,
      effect: ShimmerEffect(
        baseColor: dark
            ? AppColors.darkModeDividerColor
            : const Color.fromARGB(255, 228, 228, 228),
        highlightColor: dark
            ? AppColors.darkModeBorderColor
            : const Color(0xFFF5F5F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: child,
    );
  }
}
