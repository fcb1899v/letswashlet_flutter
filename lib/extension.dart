import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

extension ContextExt on BuildContext {

  ///Common
  double width() => MediaQuery.of(this).size.width;
  double height() => MediaQuery.of(this).size.height;

  ///AppBar Size
  double appBarHeight() => (width() < 660) ? (width() - 60) / 10 + 20: 80;
  double appBarFontSize() => (width() < 660) ? (width() - 60) / 10: 60;
  double appBarTitleTopMargin() => (width() < 660) ? (width() - 60) / 25: 24;

  ///Button Size
  double washButtonSize() => (width() < 660) ? (width() - 60) / 3 - 20: 180.0;
  double musicButtonSize() => (width() < 660) ? (width() - 60) / 6: 100.0;
  double volumeButtonSize() => (width() < 660) ? (width() - 60) / 10: 60.0;
  double volumeIconSize() => (width() < 660) ? (width() - 60) / 15: 40.0;
  double flushButtonWidth() => (width() < 660) ? (width() - 60) / 3: 200.0;
  double flushButtonHeight() => (width() < 660) ? (width() - 60) / 8: 90.0;
  double thickBorderWidth() => (width() < 660) ? (width() - 60) / 60: 10.0;
  double thinBorderWidth() => (width() < 660) ? (width() - 60) / 100: 6.0;
  double buttonRadius() => (width() < 660) ? (width() - 60) / 40: 15.0;
  double buttonSpace() => (width() < 660) ? (width() - 60) / 25: 24.0;

  ///Lamp Size
  double lampSize() => (width() < 660) ? (width() - 60) / 25: 24.0;
  double lampPadding() => (width() < 660) ? (width() - 60) / 150: 4.0;
  double lampSpace() => (width() < 660) ? (width() - 60) / 240: 2.5;
  double lampSideSpace() => (width() < 660) ? (width() - 60) / 48: 12.5;

  ///Toilet
  double toiletHeight() => height() * 0.5;
  double nozzleTopMargin() => height() * 0.28;
  double nozzleWidth() => height() * 0.01;
  double nozzleHeight(bool isNozzle) => isNozzle ? height() * 0.04: 0;
  double waterTopMargin(int washStrength) => height() * (0.31 - 0.05 * washStrength);
  double waterWidth() => height() * 0.025;

  ///Admob
  double admobHeight() => (height() < 600) ? 50: (height() < 1000) ? 50 + (height() - 600) / 8: 100;
  double admobWidth() => width();
}

extension StringExt on String {

  void debugPrint() {
    if (kDebugMode) {
      print(this);
    }
  }

  ///Audio Player
  void playAudio(AudioPlayer audioPlayer) async {
    debugPrint();
    await audioPlayer.setReleaseMode(ReleaseMode.stop);
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(ReleaseMode.release);
    await audioPlayer.play(AssetSource(this));
  }

  void loopAudio(AudioPlayer audioPlayer) async {
    debugPrint();
    await audioPlayer.setReleaseMode(ReleaseMode.stop);
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource(this));
  }

}

extension IntExt on int {

  double washingVolume() => 1.5 * this;
  double musicVolume() => 4 * this - 3;
  Color lampColor(int volume, Color? color) =>
      (this == volume) ? color! : Colors.black;
  String waterImage() => "assets/images/water$this.png";

  int plusMinus(bool isPlus, int max, int min) =>
      (isPlus && this < max) ? this + 1:
      (!isPlus && this > min) ? this - 1: this;

}

