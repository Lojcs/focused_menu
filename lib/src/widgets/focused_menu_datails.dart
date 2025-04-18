import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:focused_menu/src/models/focused_menu_item.dart';
import 'package:focused_menu/src/widgets/toolbar_actions.dart';

class FocusedMenuDetails extends StatelessWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration? menuBoxDecoration;
  final BoxDecoration? childDecoration;
  final Widget? childLowerlay;
  final Offset childOffset;
  final double? itemExtent;
  final Size? childSize;
  final Widget child;
  final bool animateMenu;
  final double? blurSize;
  final double? menuWidth;
  final Color? blurBackgroundColor;
  final double? bottomOffsetHeight;
  final double? menuOffset;

  /// Actions to be shown in the toolbar.
  final List<Widget>? toolbarActions;

  /// Enable scroll in menu.
  final bool enableMenuScroll;

  const FocusedMenuDetails(
      {Key? key,
      required this.menuItems,
      required this.child,
      required this.childOffset,
      required this.childSize,
      required this.menuBoxDecoration,
      required this.childDecoration,
      required this.childLowerlay,
      required this.itemExtent,
      required this.animateMenu,
      required this.blurSize,
      required this.blurBackgroundColor,
      required this.menuWidth,
      required this.enableMenuScroll,
      this.bottomOffsetHeight,
      this.menuOffset,
      this.toolbarActions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final maxMenuHeight = size.height * 0.45;
    final listHeight = menuItems.length * (itemExtent ?? 50.0);

    final maxMenuWidth = menuWidth ?? childSize!.width; // (size.width * 0.70);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (childOffset.dx + maxMenuWidth) < size.width
        ? childOffset.dx
        : (childOffset.dx - maxMenuWidth + childSize!.width);
    final topOffset = (childOffset.dy + menuHeight + childSize!.height) <
            size.height - bottomOffsetHeight!
        ? childOffset.dy + childSize!.height + menuOffset!
        : childOffset.dy - menuHeight - menuOffset!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: blurSize ?? 4, sigmaY: blurSize ?? 4),
                  child: Container(
                    color:
                        (blurBackgroundColor ?? Colors.black).withOpacity(0.7),
                  ),
                )),
            Positioned(
              top: topOffset,
              left: leftOffset,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                tween: Tween(begin: 0.0, end: 1.0),
                child: Container(
                  width: maxMenuWidth,
                  height: menuHeight,
                  decoration: menuBoxDecoration ??
                      BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0)),
                          boxShadow: [
                            const BoxShadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]),
                  child: ClipRRect(
                    borderRadius: menuBoxDecoration?.borderRadius
                            ?.resolve(TextDirection.ltr) ??
                        BorderRadius.circular(5),
                    child: ListView.builder(
                      scrollDirection: maxMenuWidth < menuHeight * 2
                          ? Axis.vertical
                          : Axis.horizontal,
                      itemCount: menuItems.length,
                      padding: EdgeInsets.zero,
                      physics: enableMenuScroll
                          ? BouncingScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        FocusedMenuItem item = menuItems[index];
                        Widget listItem = Container(
                            alignment: Alignment.center,
                            color: item.backgroundColor ?? Colors.white,
                            height: maxMenuWidth < menuHeight * 2
                                ? itemExtent ?? 50.0
                                : menuHeight,
                            width: maxMenuWidth < menuHeight * 2
                                ? maxMenuWidth
                                : maxMenuWidth / menuItems.length,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  item.onPressed();
                                },
                                highlightColor: item.highlightColor,
                                splashColor: item.highlightColor,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: maxMenuWidth < menuHeight * 2
                                          ? 14
                                          : 5),
                                  width: maxMenuWidth,
                                  height: menuHeight,
                                  child: Flex(
                                    direction: maxMenuWidth < menuHeight * 2
                                        ? Axis.horizontal
                                        : Axis.vertical,
                                    mainAxisAlignment:
                                        maxMenuWidth < menuHeight * 2
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: item.title,
                                      ),
                                      if (item.trailing != null) ...[
                                        item.trailing!
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ));
                        if (animateMenu) {
                          return TweenAnimationBuilder(
                              builder: (context, dynamic value, child) {
                                return Transform(
                                  transform: Matrix4.rotationX(1.5708 * value),
                                  alignment: Alignment.bottomCenter,
                                  child: child,
                                );
                              },
                              tween: Tween(begin: 1.0, end: 0.0),
                              duration: Duration(milliseconds: index * 200),
                              child: listItem);
                        } else {
                          return listItem;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (toolbarActions != null)
              ToolbarActions(toolbarActions: toolbarActions!),
            Positioned(
              top: childOffset.dy,
              left: childOffset.dx,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: AbsorbPointer(
                  absorbing: false,
                  child: Container(
                    width: childSize?.width,
                    height: childSize?.height,
                    child: Stack(
                      children: [
                        childDecoration != null
                            ? Container(decoration: childDecoration)
                            : Center(),
                        childLowerlay ?? Center(),
                        child
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
