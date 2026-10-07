// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import '../../imports.dart';

class BottomSheetLanguage extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const BottomSheetLanguage({required this.onSelected, super.key});

  Future<void> _selectLanguage(BuildContext context, String language) async {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    AppNavigator.pop(context);

    // Navigator.pop completes its result before the reverse transition has
    // left the screen. Wait for the route itself so the old-language sheet
    // and the rebuilt page are never painted in the same frame.
    await route?.completed;
    onSelected(language);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.fw),
              child: AppText(
                context.tr(AppStrings.selectLanguage),
                fontWeight: FontWeight.w600,
                color: AppColors.whiteColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.fw),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: AppLanguage.values.length,
                itemBuilder: (context, index) {
                  String title = "";
                  String language = "";
                  String flag = "";

                  switch (AppLanguage.values[index]) {
                    case AppLanguage.en:
                      title = context.tr(AppStrings.langEnglish);
                      language = AppLanguage.en.name;
                      flag = "gb";
                      break;

                    case AppLanguage.zh:
                      title = context.tr(AppStrings.langChinese);
                      language = AppLanguage.zh.name;
                      flag = "cn";
                      break;

                    case AppLanguage.ms:
                      title = context.tr(AppStrings.langMalay);
                      language = AppLanguage.ms.name;
                      flag = "my";
                      break;
                  }

                  final bool isSelected =
                      language == context.locale.languageCode;

                  return InkWellWrapper(
                    onTap: () => _selectLanguage(context, language),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.fw),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3).r,
                            child: SvgPicture.asset(
                              'assets/flags/$flag.svg',
                              package: 'country_dial_code',
                              width: 24.fw,
                              height: 16.fw,
                              fit: BoxFit.cover,
                            ),
                          ),
                          12.widthSpace,
                          Expanded(
                            child: AppText(
                              title,
                              color: isSelected
                                  ? context.color.primary
                                  : AppColors.whiteColor,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Iconsax.tick_circle,
                              color: context.color.primary,
                              size: 20.fw,
                            ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 1,
                    color: AppColors.darkDividerColor,
                  );
                },
              ),
            ),
            30.heightSpace,
          ],
        ),
      ),
    );
  }
}
