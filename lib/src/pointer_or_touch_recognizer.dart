import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PointerOrTouchRecognizerFactory
    extends GestureRecognizerFactory<PointerOrTouchRecognizer> {
  /// Called when a tap end
  VoidCallback? onTapEnd;

  /// Called when a short length tap is registered
  VoidCallback? onTap;

  /// Called when a short length tap is registered. Inhibits onTap.
  VoidCallback? onShortTapHold;

  /// Called when a medium length tap is registered
  VoidCallback? onMediumTapHold;

  /// Called when a long length tap is registered
  VoidCallback? onLongTapHold;

  /// Called when a primary click is registered
  VoidCallback? onPrimaryClick;

  /// Called when a double click is registered
  VoidCallback? onDoubleClick;

  /// Called when a secondary click is registered
  VoidCallback? onSecondaryClick;

  /// Called when a selection click (ctrl+primary) is registered
  VoidCallback? onAddSelect;

  /// Called when a range selection click (shift+primary) is registered
  VoidCallback? onRangeSelect;

  /// Called when a tap is dragged outside the area
  VoidCallback? onTapDrag;

  /// Called when a primary click is dragged outside the area
  VoidCallback? onPrimaryDrag;

  /// Called when pointer has been dragged over (from outside the area)
  VoidCallback? onDragOver;
  PointerOrTouchRecognizerFactory(
      {this.onTapEnd,
      this.onTap,
      this.onShortTapHold,
      this.onMediumTapHold,
      this.onLongTapHold,
      this.onPrimaryClick,
      this.onDoubleClick,
      this.onSecondaryClick,
      this.onAddSelect,
      this.onRangeSelect,
      this.onTapDrag,
      this.onPrimaryDrag,
      this.onDragOver});
  @override
  PointerOrTouchRecognizer constructor() => PointerOrTouchRecognizer();

  @override
  void initializer(PointerOrTouchRecognizer instance) {
    instance.setKeyHandler();
    instance.onTapEnd = onTapEnd;
    instance.onTap = onTap;
    instance.onShortTapHold = onShortTapHold;
    instance.onMediumTapHold = onMediumTapHold;
    instance.onLongTapHold = onLongTapHold;
    instance.onPrimaryClick = onPrimaryClick;
    instance.onDoubleClick = onDoubleClick;
    instance.onSecondaryClick = onSecondaryClick;
    instance.onAddSelect = onAddSelect;
    instance.onRangeSelect = onRangeSelect;
    instance.onTapDrag = onTapDrag;
    instance.onPrimaryDrag = onPrimaryDrag;
    instance.onDragOver = onDragOver;
  }
}

class PointerOrTouchRecognizer extends PrimaryPointerGestureRecognizer {
  /// Called when a tap ends, regardless of anything else
  VoidCallback? onTapEnd;

  /// Called when a short length tap is registered
  VoidCallback? onTap;

  /// Called when a short length tap is registered. Inhibits onTap.
  VoidCallback? onShortTapHold;

  /// Called when a medium length tap is registered.
  VoidCallback? onMediumTapHold;

  /// Called when a long length tap is registered
  VoidCallback? onLongTapHold;

  /// Called when a primary click is registered
  VoidCallback? onPrimaryClick;

  /// Called when a double primary click is registered
  VoidCallback? onDoubleClick;

  /// Called when a secondary click is registered
  VoidCallback? onSecondaryClick;

  /// Called when a selection click (ctrl+primary) is registered
  VoidCallback? onAddSelect;

  /// Called when a range selection click (shift+primary) is registered
  VoidCallback? onRangeSelect;

  /// Called when a tap is dragged outside the area
  VoidCallback? onTapDrag;

  /// Called when a primary click is dragged outside the area
  VoidCallback? onPrimaryDrag;

  /// Called when pointer has been dragged over (from outside the area)
  VoidCallback? onDragOver;

  PointerOrTouchRecognizer();

  void setKeyHandler() {
    HardwareKeyboard.instance.addHandler((key) {
      if (key is KeyUpEvent) {
        lastKeyEvent = null;
      } else {
        lastKeyEvent = key;
      }
      return true;
    });
  }

  /// Last keyboard key event (for ctrl and shift detection)
  KeyEvent? lastKeyEvent;

  /// Last down event
  PointerEvent? _down;

  /// Ignore tap release because a medium or long tap is registered
  bool _ignoreTap = false;

  /// Tap isn't being held anymore
  bool _tapReleased = false;

  /// Time of the last click
  Duration _lastClickTime = Duration();

  @override
  String get debugDescription => 'mouseOrTouch';

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      _down = event;
      _ignoreTap = false;
      _tapReleased = false;
      if (event.kind == PointerDeviceKind.touch) {
        Future.delayed(Duration(milliseconds: 250), () {
          // Check that the same tap is still held
          if (_down?.pointer == event.pointer && !_tapReleased) {
            _ignoreTap = true;
            if (onShortTapHold != null) {
              invokeCallback<void>('onShortTapHold', onShortTapHold!);
            }
          }
        });
        Future.delayed(Duration(milliseconds: 600), () {
          // Check that the same tap is still held
          if (_down?.pointer == event.pointer && !_tapReleased) {
            if (onMediumTapHold != null) {
              invokeCallback<void>('onMediumTapHold', onMediumTapHold!);
            }
          }
        });
        Future.delayed(Duration(milliseconds: 1000), () {
          // Check that the same tap is still held
          if (_down?.pointer == event.pointer && !_tapReleased) {
            if (onLongTapHold != null) {
              invokeCallback<void>('onLongTapHold', onLongTapHold!);
            }
          }
        });
      }
    } else if (event is PointerUpEvent) {
      if (event.kind == PointerDeviceKind.touch) {
        if (onTapEnd != null) {
          invokeCallback<void>('onTapEnd', onTapEnd!);
        }
      }
      if (_down?.pointer == event.pointer) {
        if (event.kind == PointerDeviceKind.touch) {
          _tapReleased = true;
          if (!_ignoreTap) {
            if (onTap != null) {
              invokeCallback<void>('onTap', onTap!);
            }
          }
        } else {
          if (_down!.buttons == kPrimaryButton) {
            if (lastKeyEvent?.logicalKey.synonyms
                    .contains(LogicalKeyboardKey.control) ??
                false) {
              if (onAddSelect != null) {
                invokeCallback<void>('onAddSelect', onAddSelect!);
              }
            } else if (lastKeyEvent?.logicalKey.synonyms
                    .contains(LogicalKeyboardKey.shift) ??
                false) {
              if (onRangeSelect != null) {
                invokeCallback<void>('onRangeSelect', onRangeSelect!);
              }
            } else {
              if (event.timeStamp - _lastClickTime <
                  Duration(milliseconds: 300)) {
                if (onDoubleClick != null) {
                  invokeCallback<void>('onDoubleClick', onDoubleClick!);
                }
              } else {
                if (onPrimaryClick != null) {
                  invokeCallback<void>('onPrimaryClick', onPrimaryClick!);
                }
              }
              _lastClickTime = event.timeStamp;
            }
          } else if (_down!.buttons == kSecondaryButton) {
            if (onSecondaryClick != null) {
              invokeCallback<void>('onSecondaryClick', onSecondaryClick!);
            }
          }
        }
      }
    } else if (event is PointerMoveEvent) {
      if (_down != null && _down!.pointer != event.pointer) {
        _down = event;
        if (onDragOver != null) {
          invokeCallback<void>('onDragOver', () => onDragOver!);
        }
      } else if (_down?.pointer == event.pointer) {
        if ((event.position - _down!.position).distanceSquared > 49) {
          // kTouchSlop is too accepting here
          _down = null;
        }
      }
    } else if (event is PointerCancelEvent) {
      if (_down?.pointer == event.pointer) {
        _down = null;
        if (event.kind == PointerDeviceKind.touch) {
          if (onTapDrag != null) {
            invokeCallback<void>('onTapDrag', () => onTapDrag!);
          }
        } else {
          if (onPrimaryDrag != null) {
            invokeCallback<void>('onPrimaryDrag', () => onPrimaryDrag!);
          }
        }
      }
    }
  }
}
