import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String title = "LETS TOILET";

///App Check
const androidProvider = kDebugMode ? AndroidProvider.debug: AndroidProvider.playIntegrity;
const appleProvider = kDebugMode ? AppleProvider.debug: AppleProvider.deviceCheck;

///Image
const String stopWashImage = "assets/images/black.png";
const String startWashImage = "assets/images/wash.png";
const String toiletJpgImage = "assets/images/toilet.jpg";
const String musicImage = "assets/images/music.png";
const String flushImage = "assets/images/flush.png";
const String waterImage = "assets/images/water.png";

///Sound
const int audioPlayerNumber = 3;
const String washAudio = "audios/wash.mp3";
const String prepWashAudio = "audios/prepWash.m4a";
const String musicAudio = "audios/river.mp3";
const String flushAudio = "audios/flush.mp3";
const String noneAudio = "audios/none.mp3";

///Time
const int vibTime = 200;
const int vibAmp = 128;
const int prepWashTime = 4;
const int musicTime = 20;
const int flushTime = 11;
const double prefWashVolume = 5;
const double flushVolume = 9;
const int nozzleMovingTime = 3;

///Color
const Color whiteColor = Colors.white;
const Color greyColor = Colors.grey;
const Color blackColor = Colors.black;
const Color borderBlack = Colors.black54;
final Color? deepOrange = Colors.deepOrange[400];
final Color? lightOrange = Colors.deepOrange[100];
final Color? deepBlue = Colors.blue[500];
final Color? deepGreen = Colors.greenAccent[400];
final Color? lightGreen = Colors.green[300];


