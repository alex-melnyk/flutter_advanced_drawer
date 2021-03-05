part of '../flutter_advanced_drawer.dart';

/// AdvancedDrawer widget.
class AdvancedDrawer extends StatefulWidget {
  const AdvancedDrawer({
    Key key,
    @required this.child,
    @required this.drawer,
    this.controller,
    this.backdropColor,
    this.openRatio = 0.75,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.childDecoration = const BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8.0,
        ),
      ],
      borderRadius: const BorderRadius.all(Radius.circular(16)),
    ),
  }) : super(key: key);

  /// Child widget. (Usually widget that represent a screen)
  final Widget child;

  /// Drawer widget. (Widget behind the [child]).
  final Widget drawer;

  /// Controller that controls widget state.
  final AdvancedDrawerController controller;

  /// Backdrop color.
  final Color backdropColor;

  /// Opening ratio.
  final double openRatio;

  /// Animation duration.
  final Duration animationDuration;

  /// Animation curve.
  final Curve animationCurve;

  /// Child container decoration in open widget state.
  final BoxDecoration childDecoration;

  @override
  _AdvancedDrawerState createState() => _AdvancedDrawerState();
}

class _AdvancedDrawerState extends State<AdvancedDrawer>
    with SingleTickerProviderStateMixin {
  AdvancedDrawerController _controller;
  AnimationController _animationController;
  Animation<double> _commonAnimation;
  bool _captured = false;
  double _offsetValue;
  Offset _startPosition;
  Offset _freshPosition;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? AdvancedDrawerController();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _controller.value.visible ? 1 : 0,
    );

    _commonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    _controller.addListener(() {
      _controller.value.visible
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    final drawerScalingAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(_commonAnimation);

    final drawerOpacityAnimation = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(_commonAnimation);

    final screenScalingTween = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(_commonAnimation);

    final screenTranslateTween = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(screenSize.width * widget.openRatio, 0),
    ).animate(_commonAnimation);

    return Material(
      color: widget.backdropColor,
      child: GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onHorizontalDragCancel: _handleDragCancel,
        child: Stack(
          children: <Widget>[
            // -------- DRAWER
            FractionallySizedBox(
              widthFactor: widget.openRatio,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    alignment: Alignment.centerRight,
                    scale: drawerScalingAnimation.value,
                    child: Opacity(
                      opacity: drawerOpacityAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.centerLeft,
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
                      decoration: BoxDecoration.lerp(
                        BoxDecoration(
                          boxShadow: const [],
                          borderRadius: BorderRadius.zero,
                        ),
                        widget.childDecoration,
                        _animationController.value,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _controller,
                builder: (_, value, child) {
                  return Stack(
                    children: <Widget>[
                      child,
                      if (value.visible)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _controller.hideDrawer(),
                            splashColor: theme.primaryColor.withOpacity(0.12),
                            highlightColor: Colors.transparent,
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    final screenSize = MediaQuery.of(context).size;

    final offset = screenSize.width * (1.0 - widget.openRatio);

    if (!_controller.value.visible && details.globalPosition.dx > offset ||
        _controller.value.visible &&
            details.globalPosition.dx < screenSize.width - offset) {
      _captured = false;
      return;
    }

    _captured = true;
    _startPosition = details.globalPosition;
    _offsetValue = _animationController.value;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_captured) {
      return;
    }

    final screenSize = MediaQuery.of(context).size;

    _freshPosition = details.globalPosition;

    final diff = (_freshPosition - _startPosition).dx;

    _animationController.value =
        _offsetValue + diff / (screenSize.width * widget.openRatio);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_captured) return;

    _captured = false;
    _startPosition = null;

    if (_animationController.value >= 0.5) {
      _controller.showDrawer();

      if (_controller.value.visible) {
        _animationController.animateTo(1);
      }
    } else {
      _controller.hideDrawer();

      if (!_controller.value.visible) {
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
