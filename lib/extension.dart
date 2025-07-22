import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'constant.dart';

/// BuildContext extensions for responsive design and UI sizing
/// Provides methods to calculate dimensions based on screen size
extension ContextExt on BuildContext {

  /// ===== COMMON DIMENSIONS =====
  double width() => MediaQuery.of(this).size.width;
  double height() => MediaQuery.of(this).size.height;
  double responsibleWidth() => (width() > 600) ? 600: width();

  /// ===== APP BAR DIMENSIONS =====
  double appBarHeight() => responsibleWidth() * 0.15;
  double appBarFontSize() => responsibleWidth() * 0.10;  
  double appBarTitleTopMargin() => responsibleWidth() * 0.04;

  /// ===== BUTTON DIMENSIONS =====
  double washButtonSize() => responsibleWidth() * 0.24;  
  double musicButtonSize() => responsibleWidth() * 0.16;
  double volumeButtonSize() => responsibleWidth() * 0.10;
  double volumeIconSize() => responsibleWidth() * 0.08;
  double flushButtonWidth() => responsibleWidth() * 0.32;
  double flushButtonHeight() => responsibleWidth() * 0.10;
  double thickBorderWidth() =>  responsibleWidth() * 0.016;
  double thinBorderWidth() => responsibleWidth() * 0.01;
  double buttonRadius() => responsibleWidth() * 0.025;
  double buttonSpace() => responsibleWidth() * 0.04;

  /// ===== LAMP INDICATOR DIMENSIONS =====
  double lampSize() => responsibleWidth() * 0.04;
  double lampPadding() => responsibleWidth() * 0.005;
  double lampSpace() => responsibleWidth() * 0.005;
  double lampSideSpace() => responsibleWidth() * 0.01;

  /// ===== TOILET IMAGE DIMENSIONS =====
  double toiletHeight() => height() * 0.5;
  double nozzleTopMargin() => height() * 0.28;
  double nozzleWidth() => height() * 0.01;
  double nozzleHeight(bool isNozzle) => isNozzle ? height() * 0.04: 0;
  double waterTopMargin(int washStrength) => height() * (0.31 - 0.05 * washStrength);
  double waterWidth() => height() * 0.025;

  /// ===== AD BANNER DIMENSIONS =====
  double admobHeight() => (height() < 600) ? 50: (height() < 1000) ? 50 + (height() - 600) / 8: 100;
  double admobWidth() => width();
}

/// String extension for debug printing
/// Only prints in debug mode to avoid console spam in release builds
extension StringExt on String {

  /// Print string only in debug mode
  void debugPrint() {
    if (kDebugMode) {
      print(this);
    }
  }
}

/// Integer extensions for volume calculations and UI logic
/// Provides utility methods for washing strength, music volume, and UI state
extension IntExt on int {

  /// Convert washing strength (1-5) to audio volume multiplier
  /// Returns volume level suitable for washing sounds
  double washingVolume() => 1.5 * this;
  /// Convert music volume (1-3) to audio volume multiplier
  /// Returns volume level suitable for background music
  double musicVolume() => 4 * this - 3;
  /// Determine lamp color based on current volume/strength
  /// Green for active level, black for inactive
  Color lampColor(int volume) => (this == volume) ? deepGreen! : Colors.black;
  /// Get water animation image path based on strength level
  /// Returns path like "assets/images/water1.png" through "assets/images/water5.png"
  String waterImage() => "assets/images/water$this.png";
  /// Increment/decrement value within specified bounds
  /// Used for volume and strength controls with min/max limits
  int plusMinus(bool isPlus, int max, int min) =>
      (isPlus && this < max) ? this + 1:
      (!isPlus && this > min) ? this - 1: this;

}

