part of '../flutter_advanced_drawer.dart';

/// AdvancedDrawer widget.
class AdvancedDrawer extends StatefulWidget {
  const AdvancedDrawer({
    Key? key,
    required this.child,
    required this.drawer,
    this.controller,
    this.backdropColor,
    this.openRatio = 0.75,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve,
    this.childDecoration,
    this.animateChildDecoration = true,
    this.rtlOpening = false,
  }) : super(key: key);

  /// Child widget. (Usually widget that represent a screen)
  final Widget child;

  /// Drawer widget. (Widget behind the [child]).
  final Widget drawer;

  /// Controller that controls widget state.
  final AdvancedDrawerController? controller;

  /// Backdrop color.
  final Color? backdropColor;

  /// Opening ratio.
  final double openRatio;

  /// Animation duration.
  final Duration animationDuration;

  /// Animation curve.
  final Curve? animationCurve;

  /// Child container decoration in open widget state.
  final BoxDecoration? childDecoration;

  /// Indicates that [childDecoration] might be animated or not.
  /// NOTICE: It may cause animation jerks.
  final bool animateChildDecoration;

  /// Opening from Right-to-left.
  final bool rtlOpening;

  @override
  _AdvancedDrawerState createState() => _AdvancedDrawerState();
}

class _AdvancedDrawerState extends State<AdvancedDrawer>
    with SingleTickerProviderStateMixin {
  late AdvancedDrawerController _controller;
  late AnimationController _animationController;
  late Animation<double> drawerScalingAnimation;
  late Animation<double> drawerOpacityAnimation;
  late Animation<double> screenScalingTween;
  late double _offsetValue;
  late Offset _freshPosition;
  Offset? _startPosition;
  bool _captured = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? AdvancedDrawerController();
    _controller.addListener(handleControllerChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _controller.value.visible! ? 1 : 0,
    );

    drawerScalingAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(_animationController);

    drawerOpacityAnimation = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(_animationController);

    screenScalingTween = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backdropColor,
      child: GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onHorizontalDragCancel: _handleDragCancel,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxOffset = constraints.maxWidth * widget.openRatio;

            final screenTranslateTween = Tween<Offset>(
              begin: Offset(0, 0),
              end: Offset(widget.rtlOpening ? -maxOffset : maxOffset, 0),
            ).animate(widget.animationCurve != null
                ? CurvedAnimation(
                    parent: _animationController,
                    curve: widget.animationCurve!,
                  )
                : _animationController);

            return Stack(
              children: <Widget>[
                // -------- DRAWER
                FractionallySizedBox(
                  widthFactor: widget.openRatio,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: drawerOpacityAnimation.value,
                        child: Transform.scale(
                          alignment: Alignment.centerRight,
                          scale: drawerScalingAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.transparent,
                      child: widget.drawer,
                    ),
                  ),
                ),
                // -------- CHILD
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: screenTranslateTween.value,
                      child: Transform.scale(
                        alignment: Alignment.centerLeft,
                        scale: screenScalingTween.value,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: widget.animateChildDecoration
                              ? BoxDecoration.lerp(
                                  const BoxDecoration(
                                    boxShadow: const [],
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  widget.childDecoration,
                                  _animationController.value,
                                )
                              : widget.childDecoration,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: ValueListenableBuilder<AdvancedDrawerValue>(
                    valueListenable: _controller,
                    builder: (_, value, child) {
                      if (value.visible!) {
                        return Stack(
                          children: [
                            child!,
                            if (value.visible!)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _controller.hideDrawer,
                                  highlightColor: Colors.transparent,
                                  child: Container(),
                                ),
                              ),
                          ],
                        );
                      }

                      return child!;
                    },
                    child: widget.child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void handleControllerChanged() {
    _controller.value.visible!
        ? _animationController.forward()
        : _animationController.reverse();
  }

  void _handleDragStart(DragStartDetails details) {
    _captured = true;
    _startPosition = details.globalPosition;
    _offsetValue = _animationController.value;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_captured) return;

    final screenSize = MediaQuery.of(context).size;

    _freshPosition = details.globalPosition;

    final diff = (_freshPosition - _startPosition!).dx;

    _animationController.value = _offsetValue +
        (diff / (screenSize.width * widget.openRatio)) *
            (widget.rtlOpening ? -1 : 1);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_captured) return;

    _captured = false;
    _startPosition = null;

    if (_animationController.value >= 0.5) {
      _controller.showDrawer();

      if (_controller.value.visible!) {
        _animationController.animateTo(1);
      }
    } else {
      _controller.hideDrawer();

      if (!_controller.value.visible!) {
        _animationController.animateTo(0);
      }
    }
  }

  void _handleDragCancel() {
    _captured = false;
    _startPosition = null;
  }

  @override
  void dispose() {
    _animationController.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }
}
