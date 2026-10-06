// Project imports:
import '../../imports.dart';

class CustomFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function() future; // Now accepts a function, not a Future
  final Widget Function(T data) successWidget;
  final Widget? errorWidget;
  final Widget? loadingPlaceHolder;

  const CustomFutureBuilder({
    super.key,
    required this.future,
    required this.successWidget,
    this.errorWidget,
    this.loadingPlaceHolder,
  });

  @override
  State<CustomFutureBuilder<T>> createState() => _CustomFutureBuilderState<T>();
}

class _CustomFutureBuilderState<T> extends State<CustomFutureBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future(); // Call function only once
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingPlaceHolder ??
              const Center(child: CircularProgressIndicatorWidget());
        } else if (snapshot.hasError) {
          return widget.errorWidget ??
              Center(
                child: AppText(
                  snapshot.error.toString(),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLightColor,
                ),
              );
        } else if (snapshot.hasData && snapshot.data != null) {
          return widget.successWidget(snapshot.data as T);
        }

        return const SizedBox(); // Handle empty state
      },
    );
  }
}
