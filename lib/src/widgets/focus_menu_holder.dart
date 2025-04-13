import 'package:flutter/material.dart';
import 'package:focused_menu/src/models/focused_menu_item.dart';
import 'package:focused_menu/src/widgets/focused_menu_datails.dart';

import '../pointer_or_touch_recognizer.dart';

class FocusedMenuHolderController {
  late _FocusedMenuHolderState _widgetState;
  bool _isOpened = false;

  void _addState(_FocusedMenuHolderState widgetState) {
    this._widgetState = widgetState;
  }

  void open() {
    _widgetState.openMenu(_widgetState.context);
    _isOpened = true;
  }

  void close() {
    if (_isOpened) {
      Navigator.pop(_widgetState.context);
      _isOpened = false;
    }
  }
}

/// Shows a focused menu on right click and optionally also medium tap hold.
class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double? menuItemExtent;
  final double? menuWidth;
  final List<FocusedMenuItem> menuItems;
  final bool? animateMenuItems;
  final BoxDecoration? menuBoxDecoration;
  final BoxDecoration? childDecoration;
  final BoxDecoration? openChildDecoration;
  final Widget? childLowerlay;
  final Widget? openChildLowerlay;
  final Color? childHighlightColor;

  final Duration? duration;
  final double? blurSize;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  final FocusedMenuHolderController? controller;

  /// Actions to be shown in the toolbar.
  final List<Widget>? toolbarActions;

  /// Enable scroll in menu. Default is true.
  final bool enableMenuScroll;

  /// Wheter to show menu on medium tap hold.
  final bool showMenuOnMediumHold;

  /// Called when a tap end
  final VoidCallback? onTapEnd;

  /// Called when a short length tap is registered
  final VoidCallback? onTap;

  /// Called when a short length tap is registered. Inhibits onTap.
  final VoidCallback? onShortTapHold;

  /// Called when a long length tap is registered
  final VoidCallback? onLongTapHold;

  /// Called when a primary click is registered
  final VoidCallback? onPrimaryClick;

  /// Called when a double click is registered
  final VoidCallback? onDoubleClick;

  /// Called when a selection click (ctrl+primary) is registered
  final VoidCallback? onAddSelect;

  /// Called when a range selection click (shift+primary) is registered
  final VoidCallback? onRangeSelect;

  /// Called when a tap is dragged outside the area
  final VoidCallback? onTapDrag;

  /// Called when a primary click is dragged outside the area
  final VoidCallback? onPrimaryDrag;

  /// Called when pointer has been dragged over (from outside the area)
  final VoidCallback? onDragOver;

  /// Callback to call before the menu opens
  final VoidCallback? beforeOpened;

  /// Callback to call after the menu is closed
  final VoidCallback? afterClosed;

  final Future? initData;

  const FocusedMenuHolder(
      {Key? key,
      required this.child,
      required this.menuItems,
      this.showMenuOnMediumHold = true,
      this.onTapEnd,
      this.onTap,
      this.onShortTapHold,
      this.onLongTapHold,
      this.onPrimaryClick,
      this.onDoubleClick,
      this.onAddSelect,
      this.onRangeSelect,
      this.onTapDrag,
      this.onPrimaryDrag,
      this.onDragOver,
      this.duration,
      this.menuBoxDecoration,
      this.childDecoration,
      this.openChildDecoration,
      this.childLowerlay,
      this.openChildLowerlay,
      this.childHighlightColor,
      this.menuItemExtent,
      this.animateMenuItems,
      this.blurSize,
      this.blurBackgroundColor,
      this.menuWidth,
      this.bottomOffsetHeight,
      this.menuOffset,
      this.toolbarActions,
      this.enableMenuScroll = true,
      this.controller,
      this.beforeOpened,
      this.afterClosed,
      this.initData})
      : super(key: key);

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState(controller);
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = Offset(0, 0);
  Size? childSize;

  _FocusedMenuHolderState(FocusedMenuHolderController? _controller) {
    if (_controller != null) {
      _controller._addState(this);
    }
  }

  void _getOffset() {
    RenderBox renderBox =
        containerKey.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      this.childOffset = Offset(offset.dx, offset.dy);
      childSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.childDecoration != null
            ? Container(decoration: widget.childDecoration)
            : Center(),
        widget.childLowerlay ?? Center(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: widget.childDecoration?.borderRadius
                    ?.resolve(TextDirection.ltr) ??
                BorderRadius.circular(5),
            highlightColor: widget.childHighlightColor,
            splashColor: widget.childHighlightColor,
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                PointerOrTouchRecognizer: PointerOrTouchRecognizerFactory(
                  onTapEnd: widget.onTapEnd,
                  onTap: widget.onTap,
                  onShortTapHold: widget.onShortTapHold,
                  onMediumTapHold: widget.showMenuOnMediumHold
                      ? () async {
                          await openMenu(context);
                        }
                      : null,
                  onLongTapHold: widget.onLongTapHold,
                  onPrimaryClick: widget.onPrimaryClick,
                  onDoubleClick: widget.onDoubleClick,
                  onSecondaryClick: () async {
                    await openMenu(context);
                  },
                  onAddSelect: widget.onAddSelect,
                  onRangeSelect: widget.onRangeSelect,
                  onTapDrag: widget.onTapDrag,
                  onPrimaryDrag: widget.onPrimaryDrag,
                  onDragOver: widget.onDragOver,
                )
              },
              key: containerKey,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }

  Future openMenu(BuildContext context) async {
    _getOffset();
    widget.beforeOpened?.call();
    await widget.initData;
    await Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: widget.duration ?? Duration(milliseconds: 100),
          pageBuilder: (context, animation, secondaryAnimation) {
            animation = Tween(begin: 0.0, end: 1.0).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: FocusedMenuDetails(
                itemExtent: widget.menuItemExtent,
                menuBoxDecoration: widget.menuBoxDecoration,
                childDecoration: widget.openChildDecoration,
                childLowerlay: widget.openChildLowerlay,
                child: widget.child,
                childOffset: childOffset,
                childSize: childSize,
                menuItems: widget.menuItems,
                blurSize: widget.blurSize,
                menuWidth: widget.menuWidth,
                blurBackgroundColor: widget.blurBackgroundColor,
                animateMenu: widget.animateMenuItems ?? true,
                bottomOffsetHeight: widget.bottomOffsetHeight ?? 0,
                menuOffset: widget.menuOffset ?? 0,
                toolbarActions: widget.toolbarActions,
                enableMenuScroll: widget.enableMenuScroll,
              ),
            );
          },
          fullscreenDialog: true,
          opaque: false,
        )).whenComplete(() => widget.afterClosed?.call());
  }
}
