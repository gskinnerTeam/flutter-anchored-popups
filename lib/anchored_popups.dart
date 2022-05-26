import 'package:anchored_popups/anchored_popup_region.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// //////////////////////////////////
/// POPOVER CONTEXT (ROOT)
class AnchoredPopups extends StatefulWidget {
  const AnchoredPopups({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  AnchoredPopupsController createState() => AnchoredPopupsController();

  static AnchoredPopupsController? of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<_InheritedPopupOverlay>();
    if (w == null) print("[AnchoredPopups] WARNING: No AnchoredPopup was found.");
    return w == null ? null : w.state;
  }
}

class AnchoredPopupsController extends State<AnchoredPopups> {
  OverlayEntry? barrierOverlay;
  OverlayEntry? mainContentOverlay;
  ValueNotifier<Size?> _sizeNotifier = ValueNotifier(Size.zero);
  PopupConfig? _currentPopupConfig;
  PopupConfig? get currentPopup => _currentPopupConfig;
  Size? _prevSize;
  @override
  Widget build(BuildContext context) {
    _closeHoverOnScreenSizeChange();
    final config = _currentPopupConfig;
    // Get the size and position of the region that triggered this popup,
    // then calculate the global offset for the popup content
    Size anchorSize = Size.zero;
    Offset anchoredRegionPos = Offset.zero;
    Offset popUpFractionalOffset = Offset.zero;

    if (config != null) {
      RenderBox? rb = config.context.findRenderObject() as RenderBox?;
      if (rb != null) {
        anchorSize = rb.size;
        anchoredRegionPos = rb.localToGlobal(Offset(
          anchorSize.width / 2 + (config.anchor.x) * anchorSize.width / 2,
          anchorSize.height / 2 + (config.anchor.y) * anchorSize.height / 2,
        ));
      }
      // Work out the fractional offset for the popUp content based on the incoming popupAnchor.
      // For anchor of -1,-1 (top left), we want an offset of (0, 0), for anchor of 1, 1 (bottom right), we want an offset of (-1, -1)
      // Formula is: offset = .5 - align/2 - 1;
      popUpFractionalOffset = Offset(.5 - (config.popUpAnchor.x / 2) - 1, .5 - (config.popUpAnchor.y / 2) - 1);
    }
    return _InheritedPopupOverlay(
        state: this,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              widget.child,
              if (config != null) ...[
                // Barrier
                if (config.useBarrier) ...[
                  GestureDetector(
                      onTap: config.dismissOnBarrierClick ? () => hide() : null,
                      child: Container(color: config.barrierColor)),
                ],
                // Pop child
                Transform.translate(
                  offset: anchoredRegionPos,
                  child: FractionalTranslation(
                    translation: (((popUpFractionalOffset))),
                    child: IgnorePointer(
                      ignoring: config.popUpMode == PopUpMode.hover,
                      child: config.popUpContent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  bool get isBarrierOpen => barrierOverlay != null;

  void hide() {
    print("Close current");
    setState(() => _currentPopupConfig = null);
    _sizeNotifier.value = null;
    barrierOverlay?.remove();
    mainContentOverlay?.remove();
    barrierOverlay = mainContentOverlay = null;
  }

  void show(
    BuildContext context, {
    bool useBarrier = true,
    bool dismissOnBarrierClick = true,
    Color barrierColor = Colors.transparent,
    required PopUpMode popUpMode,
    required Alignment anchor,
    required Alignment popAnchor,
    required Widget popContent,
  }) {
    setState(() {
      _currentPopupConfig = PopupConfig(context, popUpMode,
          anchor: anchor,
          popUpAnchor: popAnchor,
          popUpContent: popContent,
          useBarrier: useBarrier,
          barrierColor: barrierColor,
          dismissOnBarrierClick: dismissOnBarrierClick);
    });
  }

  void _closeHoverOnScreenSizeChange() {
    Size screenSize = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
    if (screenSize != _prevSize) {
      _currentPopupConfig = null;
    }
    _prevSize = screenSize;
  }
}

/// InheritedWidget boilerplate
class _InheritedPopupOverlay extends InheritedWidget {
  _InheritedPopupOverlay({Key? key, required Widget child, required this.state}) : super(key: key, child: child);

  final AnchoredPopupsController state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class PopupConfig {
  PopupConfig(
    this.context,
    this.popUpMode, {
    this.useBarrier = true,
    this.dismissOnBarrierClick = true,
    this.barrierColor = Colors.transparent,
    required this.anchor,
    required this.popUpAnchor,
    required this.popUpContent,
  });

  final BuildContext context;
  final PopUpMode popUpMode;
  final bool useBarrier;
  final bool dismissOnBarrierClick;
  final Color barrierColor;
  final Alignment anchor;
  final Alignment popUpAnchor;
  final Widget popUpContent;
}
