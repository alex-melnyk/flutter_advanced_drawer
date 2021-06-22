part of '../flutter_advanced_drawer.dart';

/// Advanced Drawer Controller that manage drawer state.
class AdvancedDrawerController extends ValueNotifier<AdvancedDrawerValue> {
  /// Creates controller with initial drawer state. (Hidden by default)
  AdvancedDrawerController([AdvancedDrawerValue? value])
      : super(value ?? AdvancedDrawerValue.hidden());

  /// Shows drawer.
  void showDrawer() {
    value = AdvancedDrawerValue.visible();
  }

  /// Hides drawer.
  void hideDrawer() {
    value = AdvancedDrawerValue.hidden();
  }

  /// Toggles drawer.
  void toggleDrawer() {
    if (value.visible) {
      return hideDrawer();
    }

    return showDrawer();
  }
}
