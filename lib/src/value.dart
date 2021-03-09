part of '../flutter_advanced_drawer.dart';

/// AdvancedDrawer state value.
class AdvancedDrawerValue {
  const AdvancedDrawerValue({
    this.visible,
  });

  /// Indicates whether drawer visible or not.
  final bool? visible;

  factory AdvancedDrawerValue.hidden() {
    return const AdvancedDrawerValue(
      visible: false,
    );
  }

  factory AdvancedDrawerValue.visible() {
    return const AdvancedDrawerValue(
      visible: true,
    );
  }
}
