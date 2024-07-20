import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'extension.dart';
import 'common_widget.dart';
import 'admob_banner.dart';
import 'constant.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final washStrength = useState(1);
    final washVolume = useState(washStrength.value.washingVolume());
    final musicVolume = useState(1);
    final isNozzle = useState(false);
    final isWashing = useState(false);
    final isListening = useState(false);
    final isFlushing = useState(false);
    final washPlayer = useMemoized(() => AudioPlayer());
    final musicPlayer = useMemoized(() => AudioPlayer());
    final flushPlayer = useMemoized(() => AudioPlayer());

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (Platform.isIOS || Platform.isMacOS) initATTPlugin(context);
        musicPlayer.setVolume(musicVolume.value.musicVolume());
        flushPlayer.setVolume(flushVolume);
      });
      return () {
        washPlayer.dispose();
        musicPlayer.dispose();
        flushPlayer.dispose();
      };
    }, []);

    useEffect(() {
      musicPlayer.setVolume(musicVolume.value.musicVolume());
      return null;
    }, [musicVolume.value]);

    useEffect(() {
      if (isWashing.value) {
        washVolume.value = washStrength.value.washingVolume();
        if (isWashing.value) {
          washPlayer.setVolume(washVolume.value);
        }
      }
      return null;
    }, [washStrength.value]);

    ///Wash Action
    startWashing() async {
      if (!isWashing.value) {
        isNozzle.value= true;
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        await washPlayer.setVolume(prefWashVolume);
        prepWashAudio.playAudio(washPlayer);
        washPlayer.onPlayerComplete.listen((event) {
          if (isNozzle.value) {
            isWashing.value = true;
            washPlayer.stop();
            washPlayer.setVolume(washVolume.value);
            washAudio.loopAudio(washPlayer);
            "isWashing: ${isWashing.value}".debugPrint();
            "isNozzle: ${isNozzle.value}".debugPrint();
          }
        });
      }
    }

    stopWashing() async {
      if (isNozzle.value) {
        isNozzle.value = false;
        isWashing.value = false;
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        await washPlayer.stop();
        if (!isNozzle.value && !isWashing.value) {
          await washPlayer.setVolume(prefWashVolume);
          prepWashAudio.playAudio(washPlayer);
          "isWashing: ${isWashing.value}".debugPrint();
          "isNozzle: ${isNozzle.value}".debugPrint();
        }
      }
    }

    washPlusMinus(bool isPlus) {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      washStrength.value = isPlus.plusMinus(washStrength.value, 5, 1);
      "washStrength: ${washStrength.value}".debugPrint();
    }

    ///Music Action
    playMusic() async {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      musicAudio.loopAudio(musicPlayer);
      isListening.value = true;
      "isListening: ${isListening.value}".debugPrint();
    }

    stopMusic() async {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      await musicPlayer.stop();
      isListening.value = false;
      "isListening: ${isListening.value}".debugPrint();
    }

    musicPlusMinus(bool isPlus) {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      musicVolume.value = isPlus.plusMinus(musicVolume.value, 3, 1);
      "musicVolume: ${musicVolume.value}".debugPrint();
    }

    ///Flush Action
    startFlush() async {
      if (!isFlushing.value) {
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        flushAudio.playAudio(flushPlayer);
        isFlushing.value = true;
        "isFlushing: ${isFlushing.value}".debugPrint();
        await Future.delayed(const Duration(seconds: flushTime)).then((_) {
          flushPlayer.stop();
          isFlushing.value = false;
          "isFlushing: ${isFlushing.value}".debugPrint();
        });
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.appBarHeight()),
        child: myHomeAppBar(context),
      ),
      body: Container(color: Colors.white,
        padding: EdgeInsets.only(top: context.height() * 0.01),
        child: Column(
          children: [
            const Spacer(flex: 3),
            /// Toilet Image
            Stack(children: [
              toiletImage(context),
              nozzleImage(context, isNozzle.value),
              waterImage(context, isWashing.value, washStrength.value),
            ]),
            const Spacer(flex: 1),
            /// Buttons
            Row(children: [
              const Spacer(flex: 2),
              Column(children: [
                Row(children: [
                  /// Stop Washing Button
                  GestureDetector(
                    child: washButtonImage(context, false),
                    onTap: () => stopWashing(),
                  ),
                  SizedBox(width: context.buttonSpace()),
                  /// Start Washing Button
                  GestureDetector(
                    child: washButtonImage(context, true),
                    onTap: () => startWashing(),
                  ),
                ]),
                SizedBox(height: context.buttonSpace()),
                Row(children: [
                  /// Wash Strength Minus Button
                  GestureDetector(
                    child: volumeButtonImage(context, false),
                    onTap: () => washPlusMinus(false),
                  ),
                  SizedBox(width: context.lampSideSpace()),
                  volumeLamp(context, 1, washStrength.value),
                  volumeLamp(context, 2, washStrength.value),
                  volumeLamp(context, 3, washStrength.value),
                  volumeLamp(context, 4, washStrength.value),
                  volumeLamp(context, 5, washStrength.value),
                  SizedBox(width: context.lampSideSpace()),
                  /// Wash Strength Plus Button
                  GestureDetector(
                    child: volumeButtonImage(context, true),
                    onTap: () => washPlusMinus(true),
                  ),
                ]),
              ]),
              const Spacer(flex: 1),
              Column(children: [
                /// Flush Button
                GestureDetector(
                  child: flushButtonImage(context),
                  onTap: () => startFlush(),
                ),
                SizedBox(height: context.buttonSpace()),
                Row(children: [
                  /// Stop Music Button
                  GestureDetector(
                    child: musicButtonImage(context, false),
                    onTap: () => stopMusic(),
                  ),
                  SizedBox(width: context.buttonSpace()),
                  /// Play Music Button
                  GestureDetector(
                    child: musicButtonImage(context, true),
                    onTap: () => playMusic(),
                  ),
                ]),
                SizedBox(height: context.buttonSpace()),
                Row(children: [
                  /// Music Volume Minus Button
                  GestureDetector(
                    child: volumeButtonImage(context, false),
                    onTap: () => musicPlusMinus(false),
                  ),
                  SizedBox(width: context.lampSideSpace()),
                  volumeLamp(context, 1, musicVolume.value),
                  volumeLamp(context, 2, musicVolume.value),
                  volumeLamp(context, 3, musicVolume.value),
                  SizedBox(width: context.lampSideSpace()),
                  /// Music Volume Plus Button
                  GestureDetector(
                    child: volumeButtonImage(context, true),
                    onTap: () => musicPlusMinus(true),
                  ),
                ]),
              ]),
              const Spacer(flex: 2),
            ]),
            const Spacer(flex: 3),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}