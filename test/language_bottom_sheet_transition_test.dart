import 'package:getithk/components/default/bottom_sheet_language.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'language changes only after the bottom sheet leaves the screen',
    (tester) async {
      String? selectedLanguage;

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('zh'), Locale('ms')],
          path: 'assets/translations',
          startLocale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          saveLocale: false,
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => showBarModalBottomSheet<void>(
                        context: context,
                        barrierColor: Colors.transparent,
                        backgroundColor: const Color(0xFF1A1A1A),
                        topControl: const SizedBox.shrink(),
                        builder: (context) => BottomSheetLanguage(
                          onSelected: (language) {
                            selectedLanguage = language;
                          },
                        ),
                      ),
                      child: const Text('Open languages'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Open languages'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chinese'));
      await tester.pump();

      expect(selectedLanguage, isNull);
      expect(find.byType(BottomSheetLanguage), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(BottomSheetLanguage), findsNothing);
      expect(selectedLanguage, 'zh');
    },
  );
}
