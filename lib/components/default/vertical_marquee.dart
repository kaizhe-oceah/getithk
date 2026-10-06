// Project imports:
import "../../imports.dart";

typedef OnTapCalback = void Function(int index);
typedef OnDoneCallback = void Function();

class VerticalMarquee extends StatefulWidget {
  final List<String> textList;
  final List<TextSpan> textSpanList;
  final double fontSize;
  final Color textColor;
  final Duration scrollDuration;
  final Duration stopDuration;
  final MarqueeController controller;
  final OnTapCalback? onTap;
  final OnDoneCallback? onDone;
  final FontWeight? fontWeight;

  const VerticalMarquee({
    super.key,
    this.textList = const [],
    this.textSpanList = const [],
    this.fontSize = 14.0,
    this.textColor = Colors.black,
    this.scrollDuration = const Duration(seconds: 1),
    this.stopDuration = const Duration(seconds: 3),
    this.onTap,
    this.onDone,
    this.fontWeight,
    required this.controller,
  });

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<VerticalMarquee>
    with SingleTickerProviderStateMixin {
  double percent = 0.0;
  int current = 0;

  List<String> get textList => widget.textList;
  List<TextSpan> get textSpanList => widget.textSpanList;

  late Timer stopTimer;

  late AnimationController animationConroller;

  MarqueeController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    animationConroller = AnimationController(vsync: this);
    stopTimer = Timer.periodic(widget.stopDuration + widget.scrollDuration, (
      timer,
    ) {
      setupAnimation();
    });
  }

  @override
  void dispose() {
    animationConroller.dispose();
    stopTimer.cancel();
    super.dispose();
  }

  void listener() {
    var value = animationConroller.value;

    setState(() {
      percent = value;
      _refreshControllerValue();
    });
  }

  void setupAnimation() {
    animationConroller.addListener(listener);
    animationConroller
        .animateTo(1.0, duration: widget.scrollDuration * (1 - percent))
        .then((t) {
          animationConroller.removeListener(listener);
          animationConroller.value = 0.0;
          setState(() {
            percent = 0.0;
            current = nextPosition;
            _refreshControllerValue();
          });
        });
  }

  void onTap() {
    if (widget.onTap != null) {
      printLog("===== current onTap value: $current");
      widget.onTap!(current);
    }
  }

  void _refreshControllerValue() {
    controller.position = current;

    if (widget.onDone != null) {
      if (current == textList.length - 1 && percent > 0.0) {
        widget.onDone!();
      }
    }

    if (percent > 0.5) {
      controller.position = nextPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !(textList.isNotEmpty && textSpanList.isNotEmpty),
      "textList and textSpanList cannot have elements at the same time.",
    );

    if ((textList.isEmpty) && (textSpanList.isEmpty)) {
      return Container();
    }

    if (textList.length == 1) {
      return Center(
        child: Text(
          textList[0],
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.textColor,
            fontWeight: widget.fontWeight,
          ),
        ),
      );
    }

    if (textSpanList.length == 1) {
      return Center(
        child: Text.rich(
          textSpanList[0],
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.textColor,
            fontWeight: widget.fontWeight,
          ),
        ),
      );
    }

    Widget _widget = ClipRect(
      child: CustomPaint(
        painter: _MarqueePainter(
          widget.textList,
          textSpanList: textSpanList,
          fontSize: widget.fontSize,
          textColor: widget.textColor,
          heightSpace: 0.0,
          percent: percent,
          current: current,
          fontWeight: widget.fontWeight,
        ),
        child: Container(),
      ),
    );

    return InkWellWrapper(onTap: onTap, child: _widget);
  }

  int get nextPosition {
    List list;
    if (textSpanList.isNotEmpty) {
      list = textSpanList;
    } else {
      list = textList;
    }

    var next = current + 1;
    if (next >= list.length) {
      next = 0;
    }
    return next;
  }
}

class _MarqueePainter extends CustomPainter {
  List<String> textList;
  List<TextSpan> textSpanList;
  double? heightSpace;
  double? fontSize;
  Color? textColor;
  int current;
  double percent;
  FontWeight? fontWeight;

  _MarqueePainter(
    this.textList, {
    required this.textSpanList,
    this.fontSize,
    this.textColor,
    this.heightSpace,
    this.percent = 0.0,
    this.current = 0,
    this.fontWeight,
  });

  TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    // textAlign: TextAlign.start,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _paintCurrent(size, canvas);
    _paintNext(size, canvas);
  }

  TextSpan getTextSpan(int position) {
    if (textSpanList.isNotEmpty) {
      return textSpanList[position];
    }

    String text = textList[position];
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: fontWeight,
      ),
    );
  }

  void _paintCurrent(Size size, Canvas canvas) {
    textPainter.text = getTextSpan(current);
    textPainter.textAlign = TextAlign.start;
    textPainter.maxLines = 1;
    textPainter.ellipsis = "...";

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, _getTextOffset(textPainter, size));
  }

  void _paintNext(Size size, Canvas canvas) {
    textPainter.text = getTextSpan(nextPosition);
    textPainter.textAlign = TextAlign.start;
    textPainter.maxLines = 1;
    textPainter.ellipsis = "...";

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, _getTextOffset(textPainter, size, isNext: true));
  }

  Offset _getTextOffset(
    TextPainter textPainter,
    Size size, {
    bool isNext = false,
  }) {
    var width = textPainter.width;
    if (width >= size.width) {
      width = size.width;
    }
    var height = textPainter.height;
    var dx = 0.0;
    var dy = size.height / 2 - height / 2 - size.height * percent;
    if (isNext) {
      dy = dy + size.height;
    }
    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  int get nextPosition {
    List list;
    if (textSpanList.isNotEmpty) {
      list = textSpanList;
    } else {
      list = textList;
    }

    var next = current + 1;
    if (next >= list.length) {
      next = 0;
    }
    return next;
  }
}

class MarqueeController {
  late int position;
}
