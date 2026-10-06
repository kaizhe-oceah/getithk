// Project imports:
import '../../imports.dart';

class ExpandableDescription extends StatefulWidget {
  final String description;
  final int maxLines;
  final double? padding;

  const ExpandableDescription({
    super.key,
    required this.description,
    this.maxLines = 2,
    this.padding,
  });

  @override
  ExpandableDescriptionState createState() => ExpandableDescriptionState();
}

class ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;
  bool canExpand = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the content overflows after the widget has been built
      _checkOverflow();
    });
  }

  void _checkOverflow() {
    final textSpan = TextSpan(text: widget.description);

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: AppSize.width - ((widget.padding ?? 0.0) * 2));

    setState(() {
      canExpand = textPainter.didExceedMaxLines;
      printLog("canExpand: $canExpand");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding ?? 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Description text
          AppText(
            widget.description,
            maxLines: isExpanded ? null : widget.maxLines,
            isOverflow: !isExpanded && canExpand,
            textOverflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w500,
          ),

          // See more/less button if content is expandable
          if (canExpand)
            Padding(
              padding: const EdgeInsets.only(top: 5).r,
              child: InkWellWrapper(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: AppText(
                  context.tr(
                    isExpanded ? AppStrings.seeLess : AppStrings.seeMore,
                  ),
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.w600,
                  underline: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
