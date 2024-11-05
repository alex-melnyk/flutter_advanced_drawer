part of '../flutter_advanced_drawer.dart';

/// AdvancedDrawer widget.
class AdvancedDrawer extends StatefulWidget {
  const AdvancedDrawer({
    Key? key,
    required this.child,
    required this.drawer,
    this.controller,
    this.backdropColor,
    this.backdrop,
    this.openRatio = 0.75,
    this.openScale = 0.85,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve,
    this.childDecoration,
    this.animateChildDecoration = true,
    this.rtlOpening = false,
    this.disabledGestures = false,
    this.animationController,
  }) : super(key: key);

  /// Child widget. (Usually widget that represent a screen)
  final Widget child;

  /// Drawer widget. (Widget behind the [child]).
  final Widget drawer;

  /// Controller that controls widget state.
  final AdvancedDrawerController? controller;

  /// Backdrop color.
  final Color? backdropColor;

  /// Backdrop widget for custom background.
  final Widget? backdrop;

  /// Opening ratio.
  final double openRatio;

  /// Opening ratio.
  final double openScale;

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

  /// Disable gestures.
  final bool disabledGestures;

  /// Controller that controls widget animation.
  final AnimationController? animationController;

  @override
  _AdvancedDrawerState createState() => _AdvancedDrawerState();
}

class _AdvancedDrawerState extends State<AdvancedDrawer>
    with TickerProviderStateMixin {
  final _spareController = AdvancedDrawerController();

  late AnimationController _spareAnimationController;
  late AnimationController _animationController;

  late Animation<double> _drawerScaleAnimation;
  late Animation<Offset> _childSlideAnimation;
  late Animation<double> _childScaleAnimation;
  late Animation<Decoration> _childDecorationAnimation;

  late double _offsetValue;
  late Offset _freshPosition;

  bool _captured = false;
  Offset? _startPosition;

  @override
  void initState() {
    super.initState();

    _initControllers();
  }

  @override
  void didUpdateWidget(covariant AdvancedDrawer oldWidget) {
    _initControllers();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backdropColor,
      child: GestureDetector(
        onHorizontalDragStart:
            widget.disabledGestures ? null : _handleDragStart,
        onHorizontalDragUpdate:
            widget.disabledGestures ? null : _handleDragUpdate,
        onHorizontalDragEnd: widget.disabledGestures ? null : _handleDragEnd,
        onHorizontalDragCancel:
            widget.disabledGestures ? null : _handleDragCancel,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              if (widget.backdrop != null) widget.backdrop!,
              Align(
                alignment: widget.rtlOpening
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: widget.openRatio,
                  child: ScaleTransition(
                    scale: _drawerScaleAnimation,
                    alignment: widget.rtlOpening
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: RepaintBoundary(
                      child: widget.drawer,
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: _childSlideAnimation,
                textDirection:
                    widget.rtlOpening ? TextDirection.rtl : TextDirection.ltr,
                child: ScaleTransition(
                  alignment: Alignment.centerLeft,
                  scale: _childScaleAnimation,
                  child: Builder(
                    builder: (_) {
                      final childStack = Stack(
                        children: [
                          RepaintBoundary(child: widget.child),
                          ValueListenableBuilder<AdvancedDrawerValue>(
                            valueListenable: _controller,
                            builder: (_, value, __) {
                              if (!value.visible) {
                                return const SizedBox();
                              }

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _controller.hideDrawer,
                                  highlightColor: Colors.transparent,
                                  child: Container(),
                                ),
                              );
                            },
                          ),
                        ],
                      );

                      if (widget.animateChildDecoration &&
                          widget.childDecoration != null) {
                        return AnimatedBuilder(
                          animation: _childDecorationAnimation,
                          builder: (_, child) {
                            return Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: _childDecorationAnimation.value,
                              child: child,
                            );
                          },
                          child: childStack,
                        );
                      }

                      return Container(
                        clipBehavior: widget.childDecoration != null
                            ? Clip.antiAlias
                            : Clip.none,
                        decoration: widget.childDecoration,
                        child: childStack,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AdvancedDrawerController get _controller {
    return widget.controller ?? _spareController;
  }

  void _initControllers() {
    _controller
      ..removeListener(_handleControllerChanged)
      ..addListener(_handleControllerChanged);

    _spareAnimationController = AnimationController(
      vsync: this,
      value: _controller.value.visible ? 1 : 0,
    );

    _animationController =
        widget.animationController ?? _spareAnimationController;

    _animationController.reverseDuration =
        _animationController.duration = widget.animationDuration;

    final parentAnimation = widget.animationCurve == null
        ? _animationController
        : CurvedAnimation(
            curve: widget.animationCurve!,
            parent: _animationController,
          );

    _drawerScaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(parentAnimation);

    _childSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(widget.openRatio, 0),
    ).animate(parentAnimation);

    _childScaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.openScale,
    ).animate(parentAnimation);

    _childDecorationAnimation = DecorationTween(
      begin: const BoxDecoration(),
      end: widget.childDecoration,
    ).animate(parentAnimation);
  }

  void _handleControllerChanged() {
    // Check if the widget is still mounted
    if (context.mounted) {
      // If the value of _controller is visible, forward the animation; otherwise, reverse it
      _controller.value.visible
          ? _animationController.forward()
          : _animationController.reverse();
    }
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

    if (_animationController.value >= 0.5) {
      if (_controller.value.visible) {
        _animationController.forward();
      } else {
        _controller.showDrawer();
      }
    } else {
      if (!_controller.value.visible) {
        _animationController.reverse();
      } else {
        _controller.hideDrawer();
      }
    }
  }

  void _handleDragCancel() {
    _captured = false;
  }

  @override
  void dispose() {
    _spareController
      ..removeListener(_handleControllerChanged)
      ..dispose();

    _spareAnimationController.dispose();

    super.dispose();
  }
}
