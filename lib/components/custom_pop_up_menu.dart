import 'package:flutter/material.dart';

enum ExtendedAlign {
  belowLeft,
  belowCenter,
  belowRight,
}

class CustomPopup extends StatefulWidget {
  CustomPopup({
    required this.child,
    required this.parentKey,
    Key? key,
    this.align = ExtendedAlign.belowRight,
    this.barrierColor = Colors.black38,
    this.showBarrierColor = false,
  })  : this.rect = null,
        this.relativeRect = null,
        super(key: key);

  CustomPopup.fromRect({
    required this.child,
    required this.parentKey,
    required this.rect,
    this.barrierColor = Colors.black38,
    this.showBarrierColor = false,
  })  : this.align = null,
        this.relativeRect = null;

  CustomPopup.fromRelativeRect(
      {required this.child,
      required this.parentKey,
      required this.relativeRect,
      this.showBarrierColor = false,
      this.barrierColor = Colors.black38})
      : this.rect = null,
        this.align = null;

  final Widget child;
  final GlobalKey parentKey;
  final ExtendedAlign? align;
  final Rect Function(Size size, Offset pos)? rect;
  final Color barrierColor;
  final bool showBarrierColor;
  final RelativeRect Function(Size size, Offset pos)? relativeRect;
  final state = CustomPopupState();

  @override
  CustomPopupState createState() => state;

  void show(BuildContext context) => state.show(context, this);
}

class CustomPopupState extends State<CustomPopup> {
  late RenderBox renderBox;
  late Size size;
  late Offset position;
  late OverlayEntry overlayEntry;

  Alignment get alignment {
    switch (widget.align) {
      case ExtendedAlign.belowLeft:
        return Alignment.topLeft;
      case ExtendedAlign.belowCenter:
        return Alignment.topCenter;
      case ExtendedAlign.belowRight:
        break;
      case null:
        break;
    }
    return Alignment.topRight;
  }

  double get _left => position.dx;

  double get _right =>
      MediaQuery.of(context).size.width - position.dx - size.width;

  double get _top => position.dy;

  // double get _bottom =>
  //     MediaQuery.of(context).size.height - position.dy - size.height;

  void show(BuildContext context, CustomPopup popup) {
    overlayEntry = OverlayEntry(builder: (context) => popup);
    Overlay.of(context)!.insert(overlayEntry);
  }

  void remove() {
    overlayEntry.remove();
  }

  @override
  void initState() {
    renderBox =
        widget.parentKey.currentContext!.findRenderObject() as RenderBox;
    size = renderBox.size;
    position = renderBox.localToGlobal(Offset.zero);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("top: ${position.dy + size.height}");
    print("right: ${position.dx}");
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              remove();
            },
            child: Container(
              color:
                  widget.showBarrierColor ? Colors.black38 : Colors.transparent,
            ),
          ),
        ),
        Positioned(
          top: _top + size.height,
          left: _left,
          right: _right,
          child: Container(
            child: Align(
              alignment: alignment,
              child: Material(
                color: Colors.transparent,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
