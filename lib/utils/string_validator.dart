// Project imports:
import '../imports.dart';

class StringValidator {
  static String? normalTextValidator(dynamic value) {
    if (value.isEmpty) {
      return NavigationService.context.tr(AppStrings.cantBeEmpty);
    } else {
      return null;
    }
  }

  static String? emailValidator(dynamic value) {
    if (value.isEmpty) {
      return NavigationService.context.tr(AppStrings.emailRequired);
    } else if (!AppRegex.email.hasMatch(value ?? "")) {
      return NavigationService.context.tr(AppStrings.emailInvalid);
    } else {
      return null;
    }
  }

  static String? passwordValidator(dynamic value) {
    if (value.isEmpty) {
      return NavigationService.context.tr(AppStrings.passwordEmpty);
    } else if (value.length < 6) {
      return NavigationService.context
          .tr(AppStrings.passwordLengthShouldMoreThan6);
    } else {
      return null;
    }
  }

  static String? newPasswordValidator(dynamic value) {
    final context = NavigationService.context;

    if (value == null || value.isEmpty) {
      return context.tr(AppStrings.newPasswordEmpty);
    } else if (value.length < 6) {
      return context.tr(AppStrings.newPasswordLengthShouldMoreThan6);
    }

    return null;
  }

  static String? confirmNewPasswordValidator(
      dynamic value, dynamic newPassword) {
    if (value.isEmpty) {
      return NavigationService.context.tr(AppStrings.confirmNewPasswordEmpty);
    } else if (value.length < 6) {
      return NavigationService.context
          .tr(AppStrings.confirmNewPasswordLengthShouldMoreThan6);
    } else if (value != newPassword) {
      return NavigationService.context
          .tr(AppStrings.confirmPasswordIsNotSameAsNewPassword);
    } else {
      return null;
    }
  }

  static String? icValidator(dynamic value) {
    if (value == null || value.isEmpty) {
      return NavigationService.context.tr(AppStrings.cantBeEmpty);
    } else if (!AppRegex.icNumber.hasMatch(value)) {
      return NavigationService.context.tr(AppStrings.identityCardInvalid);
    } else {
      return null;
    }
  }

  static String? otpValidator(dynamic value) {
    if (value.isEmpty) {
      return NavigationService.context.tr(AppStrings.otpIsEmpty);
    } else if (value.length < 6) {
      return NavigationService.context.tr(AppStrings.otpMustBe6);
    } else {
      return null;
    }
  }

  static String? minValue(dynamic value, dynamic minValue) {
    final double v = parseDouble(value, 0);
    final double m = parseDouble(minValue, 0);

    if (value == null || (value is String && value.trim().isEmpty)) {
      return "${NavigationService.context.tr(AppStrings.miniumumTopupAmount)} ${getPrice(minValue)}";
    }

    if (v < m) {
      return "${NavigationService.context.tr(AppStrings.miniumumTopupAmount)} ${getPrice(minValue)}";
    }

    return null;
  }
}
