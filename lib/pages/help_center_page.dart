// Project imports:
import '../imports.dart';

/// 幫助中心: the banner, then the questions, each opened on its own.
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  static const double _headerAspectRatio = 1600 / 795;

  static const List<_Faq> _faqs = [
    _Faq(AppStrings.faqDamagedQuestion, [
      _FaqSection(body: AppStrings.faqDamagedIntro),
      _FaqSection(
        title: AppStrings.faqDamagedStep1Title,
        body: AppStrings.faqDamagedStep1Body,
      ),
      _FaqSection(
        title: AppStrings.faqDamagedStep2Title,
        body: AppStrings.faqDamagedStep2Body,
      ),
    ]),
    _Faq(AppStrings.faqAddressQuestion, [
      _FaqSection(body: AppStrings.faqAddressAnswer),
    ]),
    _Faq(AppStrings.faqDeliveryQuestion, [
      _FaqSection(
        title: AppStrings.faqDeliveryStep1Title,
        body: AppStrings.faqDeliveryStep1Body,
      ),
      _FaqSection(
        title: AppStrings.faqDeliveryStep2Title,
        bullets: [AppStrings.faqDeliveryHongKong],
      ),
    ]),
    _Faq(AppStrings.faqCancelQuestion, [
      _FaqSection(body: AppStrings.faqCancelAnswer),
    ]),
  ];

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final Set<int> _expanded = {0};

  static double get _sidePadding => 10.r;
  static double get _sheetRadius => 14.r;

  void _toggle(int index) => setState(() {
    if (!_expanded.remove(index)) _expanded.add(index);
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.light,
      headerWidgets: [_header(context)],
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          _sidePadding,
          0,
          _sidePadding,
          20.r + MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: HelpCenterPage._faqs.length,
        separatorBuilder: (_, _) => 10.heightSpace,
        itemBuilder: (context, i) =>
            _faqCard(context, HelpCenterPage._faqs[i], i),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return AspectRatio(
      aspectRatio: HelpCenterPage._headerAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // the decoded image's rounded size can leave a sub-pixel gap at
          // its edges; dark like the banner's, so it doesn't show
          const ColoredBox(color: AppColors.blackColor),
          AppImage(
            name: AppAssets.helpCenterHeader,
            fit: BoxFit.contain,
            cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                .round(),
          ),
          // dims the banner's own small print under the title
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.45, 0.8],
                colors: [
                  AppColors.blackColor.wOpacity(0),
                  AppColors.blackColor.wOpacity(0.85),
                ],
              ),
            ),
          ),
          // the banner runs up behind the status bar; the button stays below it
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4.r,
            left: 10.r,
            child: _backButton(context),
          ),
          Positioned(
            left: _sidePadding + 4.r,
            right: _sidePadding,
            bottom: _sheetRadius + 6.r,
            child: AppText(
              context.tr(AppStrings.faqTitle),
              fontSize: kFont22,
              fontWeight: FontWeight.w800,
              color: AppColors.whiteColor,
            ),
          ),
          // the page's rounded top, over the banner's bottom edge
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _sheetRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_sheetRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // on a backdrop: the banner's busy right where it sits
  Widget _backButton(BuildContext context) {
    return InkWellWrapper(
      onTap: () => AppNavigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(7).r,
        decoration: BoxDecoration(
          color: AppColors.blackColor.wOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Iconsax.arrow_left_copy,
          size: 20.r,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }

  Widget _faqCard(BuildContext context, _Faq faq, int index) {
    final bool expanded = _expanded.contains(index);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14).r,
      child: ColoredBox(
        color: AppColors.greyBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWellWrapper(
              onTap: () => _toggle(index),
              child: Container(
                color: AppColors.greyLightColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ).r,
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        context.tr(faq.question),
                        fontSize: kFont13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    10.widthSpace,
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Iconsax.arrow_down_1_copy, size: 16.r),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? _answer(context, faq)
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _answer(BuildContext context, _Faq faq) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < faq.sections.length; i++) ...[
            if (i > 0) 14.heightSpace,
            ..._section(context, faq.sections[i]),
          ],
        ],
      ),
    );
  }

  List<Widget> _section(BuildContext context, _FaqSection section) {
    final String? title = section.title;
    final String? body = section.body;

    return [
      if (title != null) ...[
        AppText(
          context.tr(title),
          fontSize: kFont13,
          fontWeight: FontWeight.w700,
        ),
        4.heightSpace,
      ],
      if (body != null) _body(context.tr(body)),
      for (final String bullet in section.bullets)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6).r,
              child: _body('•'),
            ),
            Expanded(child: _body(context.tr(bullet))),
          ],
        ),
    ];
  }

  Widget _body(String text) => AppText(
    text,
    fontSize: kFont13,
    color: AppColors.textLightColor,
    height: 1.6,
  );
}

class _Faq {
  final String question;
  final List<_FaqSection> sections;

  const _Faq(this.question, this.sections);
}

/// A step's [title] (第一步：…), then its text and/or bullet points; all
/// translation keys.
class _FaqSection {
  final String? title;
  final String? body;
  final List<String> bullets;

  const _FaqSection({this.title, this.body, this.bullets = const []});
}
