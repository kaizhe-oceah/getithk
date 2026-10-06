// Project imports:
import '../imports.dart';

extension ThemeContextExtension on BuildContext {
  ColorScheme get color => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
