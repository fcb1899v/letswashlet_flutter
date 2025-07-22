import 'package:just_audio/just_audio.dart';
import 'package:letswashlet/extension.dart';
import 'constant.dart';

/// Audio Manager Class
/// Handles audio playback for toilet simulation including washing, music, and flush sounds
/// Manages multiple audio players with different states and volume controls
class AudioManager {

  /// ===== AUDIO PLAYER INITIALIZATION =====
  /// Audio player instances for different sound types
  /// Index 0: Washing sounds, Index 1: Music, Index 2: Flush sounds
  final List<AudioPlayer> audioPlayers;
  static const audioPlayerNumber = 3;
  
  /// Initialize AudioManager with specified number of audio players
  AudioManager() : audioPlayers = List.generate(audioPlayerNumber, (_) => AudioPlayer());

  /// ===== PLAYER STATE MANAGEMENT =====
  /// Get current processing state of specific audio player
  ProcessingState playerState(int index) => audioPlayers[index].processingState;

  /// Get descriptive title for audio player based on index
  /// Returns: "washPlayer", "musicPlayer", or "flushPlayer"
  String playerTitle(int index) => "${["wash", "music", "flush"][index]}Player";

  /// ===== CORE AUDIO PLAYBACK METHODS =====
  /// Play loop sound with specified volume and asset
  /// Used for continuous sounds like washing and music
  Future<void> playLoopSound({
    required int index,
    required String asset,
    required double volume,
  }) async {
    final player = audioPlayers[index];
    await player.setVolume(volume);
    await player.setLoopMode(LoopMode.all);
    await player.setAsset(asset);
    player.play();
    "Loop ${playerTitle(index)}: ${audioPlayers[index].processingState}".debugPrint();
  }

  /// Play one-time effect sound with specified volume
  /// Used for short sounds like pre-washing and flush effects
  Future<void> playEffectSound({
    required int index,
    required String asset,
    required double volume
  }) async {
    final player = audioPlayers[index];
    await player.setVolume(volume);
    await player.setLoopMode(LoopMode.off);
    await player.setAsset(asset);
    player.play();
    "Play ${playerTitle(index)}: ${audioPlayers[index].processingState}".debugPrint();
  }

  /// Set volume for specific audio player
  /// Allows dynamic volume control during playback
  Future<void> setSoundVolume(int index, double volume) async {
    await audioPlayers[index].setVolume(volume);
    "Set ${playerTitle(index)} volume: $volume".debugPrint();
  }

  /// Stop specific audio player
  /// Immediately stops playback and resets player state
  Future<void> stopSound(int index) async {
    await audioPlayers[index].stop();
    "Stop ${playerTitle(index)}: ${audioPlayers[index].processingState}".debugPrint();
  }

  /// Stop all audio players safely
  /// Handles errors gracefully and ensures all players are stopped
  Future<void> stopAll() async {
    for (final player in audioPlayers) {
      try {
        if (player.playing) {
          await player.stop();
          "Stop all players".debugPrint();
        }
      } catch (_) {}
    }
  }

  /// ===== WASHING SOUND METHODS =====
  /// Play pre-washing sound effect (one-time)
  Future<void> playPreWashingSound() async => playEffectSound(index: 0, asset: prepWashAudio, volume: prefWashVolume);
  /// Play washing sound in loop mode with specified volume
  Future<void> playWashingSound(double volume) async => playLoopSound(index: 0, asset: washAudio, volume: volume);
  /// Stop washing sound playback
  Future<void> stopWashingSound() async => stopSound(0);
  /// Set washing sound volume dynamically
  Future<void> setWashingVolume(double volume) async => setSoundVolume(0, volume);

  /// ===== MUSIC METHODS =====
  /// Play music in loop mode with specified volume
  Future<void> playMusic(double volume) async  => playLoopSound(index: 1, asset: musicAudio, volume: volume);
  /// Stop music playback
  Future<void> stopMusic() async => stopSound(1);
  /// Set music volume dynamically
  Future<void> setMusicVolume(double volume) async => setSoundVolume(1, volume);

  /// ===== FLUSHING SOUND METHODS =====
  /// Play flushing sound effect (one-time)
  Future<void> playFlushingSound() async => playEffectSound(index: 2, asset: flushAudio, volume: flushVolume);

  /// ===== PLAYER STATE CHECKING METHODS =====
  /// Get current player state of specific audio player
  PlayerState getPlayerState(int index) => audioPlayers[index].playerState;
  /// Check if specific player is currently playing
  bool isPlaying(int index) => audioPlayers[index].playing;
  /// Check if specific player is currently stopped
  bool isStopped(int index) => audioPlayers[index].processingState == ProcessingState.idle;
  /// Check if specific player has completed playback
  bool isCompleted(int index) => audioPlayers[index].processingState == ProcessingState.completed;

  /// ===== RESOURCE CLEANUP METHODS =====
  /// Dispose all audio players and release resources
  /// Ensures proper cleanup to prevent memory leaks
  Future<void> dispose() async {
    "Disposing AudioManager".debugPrint();
    try {
      // Stop all audio players first
      await stopAll();
      // Dispose each audio player
      for (int i = 0; i < audioPlayers.length; i++) {
        try {
          await audioPlayers[i].dispose();
          "Disposed ${playerTitle(i)}".debugPrint();
        } catch (e) {
          "Error disposing ${playerTitle(i)}: $e".debugPrint();
        }
      }
      "AudioManager disposed successfully".debugPrint();
    } catch (e) {
      "Error during AudioManager disposal: $e".debugPrint();
    }
  }
}
