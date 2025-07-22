import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'audio_manager.dart';
import 'extension.dart';
import 'admob_banner.dart';
import 'constant.dart';

/// Main home page widget that manages the toilet interface
/// Handles washing, music, and flush functionality with state management
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State management for UI controls
    final washStrength = useState(3);         // Washing strength level (1-5)
    final musicVolume = useState(2);          // Music volume level (1-3)
    final isNozzle = useState(false);         // Nozzle activation state
    final isWashing = useState(false);        // Washing animation state
    final isListening = useState(false);      // Music playback state
    final isFlushing = useState(false);       // Flush animation state
    final lifecycle = useAppLifecycleState(); // App lifecycle state
    // Initialize audio manager and home widget
    final audioManager = useMemoized(() => AudioManager());
    final home = HomeWidget(context);

    // Update audio volumes when strength/volume values change
    useEffect(() {
      audioManager.setWashingVolume(washStrength.value.washingVolume());
      audioManager.setMusicVolume(musicVolume.value.musicVolume());
      return null;
    }, [washStrength.value, musicVolume.value]);

    /// ===== APP LIFECYCLE MANAGEMENT =====
    /// Handle app lifecycle changes (pause, resume) to stop audio
    useEffect(() {
      Future<void> handleLifecycleChange() async {
        if (!context.mounted) return;
        if (lifecycle == AppLifecycleState.inactive || lifecycle == AppLifecycleState.paused) {
          try {
            await audioManager.stopAll();
          } catch (e) {
            'Error handling stop for player: $e'.debugPrint();
          }
        }
      }
      handleLifecycleChange();
      return null;
    }, [lifecycle, context.mounted]);

    /// ===== WASHING FUNCTIONALITY =====
    /// Start the washing sequence with pre-washing sound and animation
    startWashing() async {
      if (isNozzle.value) return;
      isNozzle.value = true;
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      await audioManager.playPreWashingSound();
      await Future.delayed(const Duration(seconds: prepWashTime)).then((_) {
        if (!isNozzle.value) return;
        isWashing.value = true;
        audioManager.playWashingSound(washStrength.value.washingVolume());
      });
    }
    /// Stop the washing sequence and reset states
    stopWashing() async {
      if (!isNozzle.value) return;
      isNozzle.value = false;
      isWashing.value = false;
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      await audioManager.stopWashingSound();
      await audioManager.playPreWashingSound();
    }
    /// Adjust washing strength with haptic feedback
    washPlusMinus(bool isPlus) {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      washStrength.value = washStrength.value.plusMinus(isPlus, 5, 1);
      "washStrength: ${washStrength.value}".debugPrint();
    }

    /// ===== MUSIC FUNCTIONALITY =====
    /// Start music playback with current volume level
    playMusic() async {
      if (!isListening.value) {
        isListening.value = true;
        "isListening: ${isListening.value}".debugPrint();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        audioManager.playMusic(musicVolume.value.musicVolume());
      }
    }
    /// Stop music playback and reset state
    stopMusic() async {
      if (isListening.value) {
        isListening.value = false;
        "isListening: ${isListening.value}".debugPrint();
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        await audioManager.stopMusic();
      }
    }
    /// Adjust music volume with haptic feedback
    musicPlusMinus(bool isPlus) {
      Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
      musicVolume.value = musicVolume.value.plusMinus(isPlus, 3, 1);
      "musicVolume: ${musicVolume.value}".debugPrint();
    }

    /// ===== FLUSH FUNCTIONALITY =====
    /// Start flush animation and sound for specified duration
    startFlush() async {
      if (!isFlushing.value) {
        Vibration.vibrate(duration: vibTime, amplitude: vibAmp);
        isFlushing.value = true;
        audioManager.playFlushingSound();
        await Future.delayed(const Duration(seconds: flushTime)).then((_) {
          isFlushing.value = false;
        });
      }
    }

    return Scaffold(
      appBar: home.homeAppBar(),
      body: Container(color: whiteColor,
        child: Column(
          children: [
            const Spacer(flex: 3),
            /// Toilet Image Stack
            /// Contains toilet base, nozzle, and water animation layers
            Stack(alignment: Alignment.topCenter,
              children: [
                home.toiletImageWidget(),
                home.nozzleImageWidget(isNozzle.value),
                home.waterImageWidget(isWashing.value, washStrength.value),
              ],
            ),
            const Spacer(flex: 1),
            /// Control Buttons Section
            /// Left side: Washing controls, Right side: Music and flush controls
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  /// Start/Stop Washing Button
                  Row(children: [
                    home.washButton(isStart: false, onTap: () => stopWashing()),
                    SizedBox(width: context.buttonSpace()),
                    home.washButton(isStart: true, onTap: () => startWashing()),
                  ]),
                  SizedBox(height: context.buttonSpace()),
                  /// Wash Strength Plus/Minus Button
                  Row(children: [
                    home.volumeButton(isPlus: false, onTap: () => washPlusMinus(false)),
                    home.volumeLamps(strengthLampNumber, washStrength.value),
                    home.volumeButton(isPlus: true, onTap: () => washPlusMinus(true)),
                  ]),
                ]),
                Column(children: [
                  /// Flush Button
                  home.flushButton(onTap: () => startFlush()),
                  /// Play/Stop Music Button
                  Row(children: [
                    home.musicButton(isPlay: false, onTap: () => stopMusic()),
                    SizedBox(width: context.buttonSpace()),
                    home.musicButton(isPlay:true, onTap: () => playMusic()),
                  ]),
                  SizedBox(height: context.buttonSpace()),
                  /// Music Volume Plus/Minus Button
                  Row(children: [
                    home.volumeButton(isPlus: false, onTap: () => musicPlusMinus(false) ),
                    home.volumeLamps(volumeLampNumber, musicVolume.value),
                    home.volumeButton(isPlus: true, onTap: () => musicPlusMinus(true)),
                  ]),
                ]),
              ]
            ),
            const Spacer(flex: 3),
            /// Ad Banner at bottom
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}

/// HomeWidget class
/// Contains all UI widget components for the toilet interface
/// Manages app bar, toilet images, buttons, and volume indicators
class HomeWidget {
  final BuildContext context;

  HomeWidget(this.context);

  /// ===== APP BAR WIDGET =====
  /// Creates the main app bar with centered title
  /// Uses custom font and styling for the app title
  PreferredSize homeAppBar() => PreferredSize(
    preferredSize: Size.fromHeight(context.appBarHeight()),
    child: AppBar(
      title: Container(
        margin: EdgeInsets.only(top: context.appBarTitleTopMargin()),
        child: Text(title,
          style: TextStyle(
            fontFamily: "cornerStone",
            fontSize: context.appBarFontSize(),
            color: whiteColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      centerTitle: true,
      backgroundColor: blackColor,
    ),
  );

  /// ===== TOILET IMAGE WIDGETS =====
  /// Main toilet image container
  /// Displays the base toilet image with proper sizing
  Widget toiletImageWidget() => Container(
    height: context.toiletHeight(),
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(toiletJpgImage),
        fit: BoxFit.fitHeight,
      ),
    ),
  );

  /// Animated nozzle image widget
  /// Shows nozzle in different positions based on washing state
  /// Uses animated container for smooth transitions
  Widget nozzleImageWidget(bool isNozzle) => AnimatedContainer(
    margin: EdgeInsets.only(top: context.nozzleTopMargin()),
    width: context.nozzleWidth(),
    height: context.nozzleHeight(isNozzle),
    duration: const Duration(seconds: nozzleMovingTime),
    decoration: metalDecoration(),
  );

  /// Water animation widget
  /// Displays water animation based on washing state and strength
  /// Position and image change based on wash strength level
  Widget waterImageWidget(bool isWashing, int washStrength) => Container(
    margin: EdgeInsets.only(top: context.waterTopMargin(washStrength)),
    width: context.waterWidth(),
    child: isWashing ? Image(image: AssetImage(washStrength.waterImage())): null,
  );

  /// Metal gradient decoration for nozzle
  /// Creates a metallic appearance with gradient colors
  BoxDecoration metalDecoration() => const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, 0.4, 0.7, 0.8, 0.9],
        colors: [
          Colors.white70,
          Colors.white38,
          Colors.white12,
          Colors.black45,
          Colors.white38,
        ],
      )
  );

  /// ===== CONTROL BUTTON WIDGETS =====
  /// Wash button widget (start/stop)
  /// Circular button with different colors for start/stop states
  /// Uses custom images and border styling
  Widget washButton({
    required bool isStart,
    required void Function() onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: context.washButtonSize(),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isStart ? whiteColor : lightOrange!,
        border: Border.all(
          color: isStart ? deepBlue! : deepOrange!,
          width: context.thickBorderWidth(),
        ),
      ),
      child: Image(
          image: AssetImage(isStart ? startWashImage : stopWashImage)
      ),
    ),
  );

  /// Music button widget (play/stop)
  /// Circular button with music icon and play/stop states
  /// Uses green border for active state
  Widget musicButton({
    required bool isPlay,
    required void Function() onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: context.musicButtonSize(),
      height: context.musicButtonSize(),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: whiteColor,
        border: Border.all(
          color: isPlay ? lightGreen! : borderBlack,
          width: context.thinBorderWidth(),
        ),
      ),
      child: Image(
          image: AssetImage(isPlay ? musicImage : stopWashImage)
      ),
    ),
  );

  /// Volume control button widget (plus/minus)
  /// Rectangular button with plus/minus icons
  /// Used for adjusting washing strength and music volume
  Widget volumeButton({
    required bool isPlus,
    required void Function() onTap,
  }) => GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.volumeButtonSize(),
        height: context.volumeButtonSize(),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: whiteColor,
          border: Border.all(
            color: greyColor,
            width: context.thinBorderWidth(),
          ),
          borderRadius: BorderRadius.circular(context.buttonRadius()),
        ),
        child: Container(
          alignment: Alignment.center,
          child: Icon(isPlus ? CupertinoIcons.plus : CupertinoIcons.minus,
            color: blackColor,
            size: context.volumeIconSize(),
          ),
        ),
      )
  );

  /// Flush button widget
  /// Rectangular button with flush icon
  /// Larger size compared to other control buttons
  Widget flushButton({
    required void Function() onTap
  }) => GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.flushButtonWidth(),
        height: context.flushButtonHeight(),
        margin: EdgeInsets.only(bottom: context.buttonSpace()),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: whiteColor,
          border: Border.all(
            color: borderBlack,
            width: context.thinBorderWidth(),
          ),
          borderRadius: BorderRadius.circular(context.buttonRadius()),
        ),
        child: const Image(image: AssetImage(flushImage)),
      )
  );

  /// ===== VOLUME INDICATOR WIDGET =====
  /// Volume lamps indicator widget
  /// Shows current volume/strength level with illuminated circles
  /// Uses List.generate to create multiple lamp indicators
  Widget volumeLamps(int number, int volume) => Row(children: [
    SizedBox(width: context.lampSideSpace()),
    ...List.generate(number, (index) => Container(
      width: context.lampSize(),
      height: context.lampSize(),
      margin: EdgeInsets.symmetric(horizontal: context.lampSpace()),
      padding: EdgeInsets.all(context.lampPadding()),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: blackColor,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (index + 1).lampColor(volume),
        ),
      ),
    )),
    SizedBox(width: context.lampSideSpace()),
  ]);
}
