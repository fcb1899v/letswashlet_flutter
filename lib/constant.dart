import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Application title displayed in the app bar
const String title = "LETS TOILET";

/// ===== FIREBASE APP CHECK CONFIGURATION =====
/// App Check providers for Android and iOS
/// Uses debug providers in debug mode, production providers in release mode
const androidProvider = kDebugMode ? AndroidProvider.debug: AndroidProvider.playIntegrity;
const appleProvider = kDebugMode ? AppleProvider.debug: AppleProvider.deviceCheck;

/// ===== IMAGE ASSETS =====
/// Image file paths for UI elements
const String stopWashImage = "assets/images/black.png";      // Stop washing button
const String startWashImage = "assets/images/wash.png";      // Start washing button
const String toiletJpgImage = "assets/images/toilet.jpg";    // Main toilet image
const String musicImage = "assets/images/music.png";         // Music button
const String flushImage = "assets/images/flush.png";         // Flush button
const String waterImage = "assets/images/water.png";         // Water animation

/// ===== AUDIO ASSETS =====
/// Audio file paths and configuration
const int audioPlayerNumber = 3;                             // Number of audio players
const String washAudio = "assets/audios/wash.mp3";          // Washing sound (loop)
const String prepWashAudio = "assets/audios/prepWash.m4a";  // Pre-washing sound (one-time)
const String musicAudio = "assets/audios/river.mp3";        // Background music (loop)
const String flushAudio = "assets/audios/flush.mp3";        // Flush sound (one-time)
const String noneAudio = "assets/audios/none.mp3";          // Placeholder audio

/// ===== TIMING AND VOLUME CONSTANTS =====
/// Vibration settings
const int vibTime = 200;                                     // Vibration duration (ms)
const int vibAmp = 128;                                      // Vibration amplitude

/// Animation and sound timing
const int prepWashTime = 4;                                  // Pre-washing duration (seconds)
const int musicTime = 20;                                    // Music duration (seconds)
const int flushTime = 11;                                    // Flush duration (seconds)
const int nozzleMovingTime = 3;                             // Nozzle movement time (seconds)

/// Volume levels
const double prefWashVolume = 5;                             // Pre-washing sound volume
const double flushVolume = 9;                                // Flush sound volume

/// ===== UI ELEMENT COUNTS =====
/// Number of indicator lamps for different controls
const int strengthLampNumber = 5;                            // Washing strength lamps (1-5)
const int volumeLampNumber = 3;                              // Music volume lamps (1-3)

/// ===== COLOR DEFINITIONS =====
/// Basic colors
const Color whiteColor = Colors.white;                       // Background color
const Color greyColor = Colors.grey;                         // Secondary text color
const Color blackColor = Colors.black;                       // Primary text color
const Color borderBlack = Colors.black54;                    // Border color

/// Theme colors for different states
final Color? deepOrange = Colors.deepOrange[400];            // Active button color
final Color? lightOrange = Colors.deepOrange[100];           // Inactive button color
final Color? deepBlue = Colors.blue[500];                    // Primary accent color
final Color? deepGreen = Colors.greenAccent[400];            // Success/active state
final Color? lightGreen = Colors.green[300];                 // Light success state


