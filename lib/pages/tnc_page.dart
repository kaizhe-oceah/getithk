// Package imports:
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

// Project imports:
import '../imports.dart';
import '../models/tnc_model.dart';

/// The terms of service or the privacy policy (by [type]), from the
/// term-condition API.
class TncPage extends StatefulWidget {
  final TncType type;

  const TncPage({this.type = TncType.terms, super.key});

  @override
  State<TncPage> createState() => _TncPageState();
}

class _TncPageState extends State<TncPage> {
  bool _isLoading = true;
  TncModel? _tnc;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ApiService.api.getTnc(
      type: widget.type,
      onSuccess: (response) {
        if (response.data is Map) {
          _tnc = TncModel.fromJson(Map<String, dynamic>.from(response.data));
        }
      },
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.dark,
      headerWidgets: [
        AppBarWidget(
          text: context.tr(
            widget.type == TncType.terms
                ? AppStrings.termsOfService
                : AppStrings.privacyPolicy,
          ),
          textSize: kFont16,
          backgroundColor: AppColors.whiteColor,
          leading: const AppBarBackButton(),
        ),
      ],
      child: _content(),
    );
  }

  Widget _content() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicatorWidget());
    }

    final String content = _tnc?.content ?? '';
    if (content.isEmpty) return const NoDataWidget();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        kHorizontalPadding.r,
        kHorizontalPadding.r,
        kHorizontalPadding.r,
        kHorizontalPadding.r + MediaQuery.paddingOf(context).bottom,
      ),
      child: HtmlWidget(
        content,
        textStyle: TextStyle(
          fontSize: kFont14.sp,
          color: AppColors.loginTextColor,
        ),
      ),
    );
  }
}
