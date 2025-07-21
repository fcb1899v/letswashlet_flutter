import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'common_function.dart';
import 'extension.dart';
import 'common_widget.dart';
import 'admob_banner.dart';
import 'constant.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final washStrength = useState(3);
    final washVolume = useState(washStrength.value.washingVolume());
    final musicVolume = useState(2);
    final isNozzle = useState(false);
    final isWashing = useState(false);
    final isListening = useState(false);
    final isFlushing = useState(false);
    final audioPlayers = AudioPlayerManager();
    final lifecycle = useAppLifecycleState();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        audioPlayers.audioPlayers[0].setVolume(washVolume.value);
        audioPlayers.audioPlayers[1].setVolume(musicVolume.value.musicVolume());
        audioPlayers.audioPlayers[2].setVolume(flushVolume);
      });
      return null;
    }, []);

    useEffect(() {
      washVolume.value = washStrength.value.washingVolume();
      audioPlayers.audioPlayers[0].setVolume(washVolume.value);
      audioPlayers.audioPlayers[1].setVolume(musicVolume.value.musicVolume());
      return null;
    }, [washStrength.value, musicVolume.value]);

    useEffect(() {
      Future<void> handleLifecycleChange() async {
        // ウィジェットが破棄されていたら何もしない
        if (!context.mounted) return;
        // アプリがバックグラウンドに移行する直前
        if (lifecycle == AppLifecycleState.inactive || lifecycle == AppLifecycleState.paused) {
          for (int i = 0; i < audioPlayers.audioPlayers.length; i++) {
            final player = audioPlayers.audioPlayers[i];
            try {
              if (player.state == PlayerState.playing) await player.stop();
            } catch (e) {
              'Error handling stop for player $i: $e'.debugPrint();
            }
          }
        }
      }
      handleLifecycleChange();
      return null;
    }, [lifecycle, context.mounted, audioPlayers.audioPlayers.length]);

    ///Wash Action
    startWashing() async {
      if (!isWashing.value) {
        isNozzle.value= true;
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        await audioPlayers.audioPlayers[0].setVolume(prefWashVolume);
        prepWashAudio.playAudio(audioPlayers.audioPlayers[0]);
        audioPlayers.audioPlayers[0].onPlayerComplete.listen((event) {
          if (isNozzle.value) {
            isWashing.value = true;
            audioPlayers.audioPlayers[0].stop();
            audioPlayers.audioPlayers[0].setVolume(washVolume.value);
            washAudio.loopAudio(audioPlayers.audioPlayers[0]);
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
        await audioPlayers.audioPlayers[0].stop();
        if (!isNozzle.value && !isWashing.value) {
          await audioPlayers.audioPlayers[0].setVolume(prefWashVolume);
          prepWashAudio.playAudio(audioPlayers.audioPlayers[0]);
          "isWashing: ${isWashing.value}".debugPrint();
          "isNozzle: ${isNozzle.value}".debugPrint();
        }
      }
    }

    washPlusMinus(bool isPlus) {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      washStrength.value = washStrength.value.plusMinus(isPlus, 5, 1);
      "washStrength: ${washStrength.value}".debugPrint();
    }

    ///Music Action
    playMusic() async {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      musicAudio.loopAudio(audioPlayers.audioPlayers[1]);
      isListening.value = true;
      "isListening: ${isListening.value}".debugPrint();
    }

    stopMusic() async {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      await audioPlayers.audioPlayers[1].stop();
      isListening.value = false;
      "isListening: ${isListening.value}".debugPrint();
    }

    musicPlusMinus(bool isPlus) {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      musicVolume.value = musicVolume.value.plusMinus(isPlus, 3, 1);
      "musicVolume: ${musicVolume.value}".debugPrint();
    }

    ///Flush Action
    startFlush() async {
      if (!isFlushing.value) {
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        flushAudio.playAudio(audioPlayers.audioPlayers[2]);
        isFlushing.value = true;
        "isFlushing: ${isFlushing.value}".debugPrint();
        await Future.delayed(const Duration(seconds: flushTime)).then((_) {
          audioPlayers.audioPlayers[2].stop();
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
        child: Column(
          children: [
            const Spacer(flex: 3),
            /// Toilet Image
            Stack(alignment: Alignment.topCenter,
              children: [
                toiletImageWidget(context),
                nozzleImageWidget(context, isNozzle.value),
                waterImageWidget(context, isWashing.value, washStrength.value),
              ],
            ),
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