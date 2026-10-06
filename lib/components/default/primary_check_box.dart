// Project imports:
import '../../imports.dart';

class PrimaryCheckBox extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  final bool isRound;
  final bool isGradient;
  final Color? checkBoxColor;

  const PrimaryCheckBox(
      {super.key,
      required this.value,
      required this.onChanged,
      this.isRound = false,
      this.isGradient = false,
      this.checkBoxColor});
  @override
  Widget build(BuildContext context) {
    return isGradient ? gradientBox() : (isRound ? singleBox() : multipleBox());
  }

  Widget gradientBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5).r,
      child: InkWellWrapper(
        onTap: () {
          onChanged(!value);
        },
        child: CustomPaint(
          painter: GradientCheckboxPainter(
            isChecked: value,
            gradient: value
                ? AppColors.buttonGradientColor
                : AppColors.whiteGradientColor,
          ),
          child: SizedBox(
            width: 18.0,
            height: 18.0,
            child: value
                ? const Icon(
                    Icons.check,
                    size: 16.0,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget multipleBox() {
    return SizedBox(
      width: 20.0,
      height: 20.0,
      child: Transform.scale(
        scale: 0.7,
        child: Checkbox(
          value: value,
          onChanged: (v) {
            onChanged(v ?? false);
          },
          side: const BorderSide(
            color: AppColors.greyColor,
          ),
          splashRadius: 0,
          activeColor: checkBoxColor ?? AppColors.blackColor,
          checkColor: AppColors.whiteColor,
          shape: null,
        ),
      ),
    );
  }

  Widget singleBox() {
    return SizedBox(
      width: 20.0,
      height: 20.0,
      child: Transform.scale(
        scale: 0.75,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.greyColor),
          ),
          child: Container(
            margin: const EdgeInsets.all(3).r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? checkBoxColor ?? AppColors.blackColor
                  : AppColors.transparentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class GradientCheckboxPainter extends CustomPainter {
  final bool isChecked;
  final Gradient gradient;

  GradientCheckboxPainter({
    required this.isChecked,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw the checkbox background with gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(4.0),
      ),
      paint,
    );

    // Draw the border
    final borderPaint = Paint()
      ..color =
          isChecked ? Colors.transparent : AppColors.greyColor.wOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(4.0).r,
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
