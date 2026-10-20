// Project imports:
import '../../imports.dart';

/// Picks a month, in the look of the app's calendar picker: ‹ year › over
/// its 12 months; a tap on one selects it, 確認 closes with it. None after
/// [lastDate]. With [canReset], 重設 closes with no month.
class MonthPickerDialog extends StatefulWidget {
  final DateTime? initialMonth;
  final DateTime? lastDate;
  final bool canReset;

  const MonthPickerDialog({
    this.initialMonth,
    this.lastDate,
    this.canReset = false,
    super.key,
  });

  /// The month confirmed, as its 1st, or none after 重設; null if
  /// cancelled.
  static Future<({DateTime? month})?> show(
    BuildContext context, {
    DateTime? initialMonth,
    DateTime? lastDate,
    bool canReset = false,
  }) {
    return DialogHelper<({DateTime? month})>().showDefaultDialog(
      context2: context,
      child: MonthPickerDialog(
        initialMonth: initialMonth,
        lastDate: lastDate,
        canReset: canReset,
      ),
    );
  }

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _year = (widget.initialMonth ?? DateTime.now()).year;
  late DateTime? _selected = widget.initialMonth;

  bool _isSameMonth(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = context.text.bodyMedium!.copyWith(
      color: AppColors.blackColor,
    );
    final DateTime? last = widget.lastDate;

    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 0.075.sw),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15).r),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _arrow(
                  Iconsax.arrow_left_2_copy,
                  onTap: () => setState(() => _year--),
                ),
                Expanded(
                  child: Text(
                    DateFormat.y(
                      context.locale.toString(),
                    ).format(DateTime(_year)),
                    textAlign: TextAlign.center,
                    style: style.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _arrow(
                  Iconsax.arrow_right_3_copy,
                  onTap: last != null && _year >= last.year
                      ? null
                      : () => setState(() => _year++),
                ),
              ],
            ),
            12.heightSpace,
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.4,
              mainAxisSpacing: 8.r,
              crossAxisSpacing: 8.r,
              children: [
                for (int month = 1; month <= 12; month++)
                  _month(context, DateTime(_year, month), style),
              ],
            ),
            4.heightSpace,
            Row(
              children: [
                if (widget.canReset)
                  _action(
                    context.tr(AppStrings.reset),
                    style,
                    onPressed: () => AppNavigator.pop(context, (month: null)),
                  ),
                const Spacer(),
                _action(
                  context.tr(AppStrings.cancel),
                  style,
                  onPressed: () => AppNavigator.pop(context),
                ),
                _action(
                  context.tr(AppStrings.confirm),
                  style,
                  onPressed: _selected == null
                      ? null
                      : () => AppNavigator.pop(context, (month: _selected)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(String text, TextStyle style, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: style.copyWith(
          fontWeight: FontWeight.w500,
          color: onPressed == null ? AppColors.greyColor : null,
        ),
      ),
    );
  }

  Widget _arrow(IconData icon, {required VoidCallback? onTap}) {
    return InkWellWrapper(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: Icon(
          icon,
          size: 16.r,
          color: onTap == null ? AppColors.greyColor : AppColors.blackColor,
        ),
      ),
    );
  }

  /// [month] highlighted when it's the one selected, outlined when it's
  /// this one.
  Widget _month(BuildContext context, DateTime month, TextStyle style) {
    final Color primary = context.color.primary;
    final DateTime? last = widget.lastDate;
    final bool isEnabled =
        last == null || !month.isAfter(DateTime(last.year, last.month));
    final bool isSelected = _isSameMonth(_selected, month);
    final bool isCurrent = _isSameMonth(DateTime.now(), month);
    final BorderRadius radius = BorderRadius.circular(100);

    return InkWellWrapper(
      onTap: isEnabled ? () => setState(() => _selected = month) : null,
      borderRadius: radius,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primary : null,
          border: !isSelected && isCurrent ? Border.all(color: primary) : null,
          borderRadius: radius,
        ),
        child: Text(
          DateFormat.MMM(context.locale.toString()).format(month),
          style: style.copyWith(
            color: isSelected
                ? AppColors.whiteColor
                : isEnabled
                ? AppColors.blackColor
                : AppColors.greyColor,
          ),
        ),
      ),
    );
  }
}
