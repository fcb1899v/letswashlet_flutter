import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'extension.dart';
import 'constant.dart';

/// App Bar

AppBar myHomeAppBar(BuildContext context) =>
    AppBar(
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
    );


/// Toilet Image
Widget toiletImageWidget(BuildContext context) =>
    Container(
      height: context.toiletHeight(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(toiletJpgImage),
          fit: BoxFit.fitHeight,
        ),
      ),
    );

Widget nozzleImageWidget(BuildContext context, bool isNozzle) =>
    AnimatedContainer(
      margin: EdgeInsets.only(top: context.nozzleTopMargin()),
      width: context.nozzleWidth(),
      height: context.nozzleHeight(isNozzle),
      duration: const Duration(seconds: nozzleMovingTime),
      decoration: metalDecoration(),
    );

Widget waterImageWidget(BuildContext context, bool isWashing, int washStrength) =>
    Container(
      margin: EdgeInsets.only(top: context.waterTopMargin(washStrength)),
      width: context.waterWidth(),
      child: isWashing ? Image(image: AssetImage(washStrength.waterImage())): null,
    );

BoxDecoration metalDecoration() =>
    const BoxDecoration(
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

///Wash Button Image
Widget washButtonImage(BuildContext context, bool isStart) =>
    Container(
      width: context.washButtonSize(),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isStart ? whiteColor: lightOrange!,
        border: Border.all(
          color: isStart ? deepBlue!: deepOrange!,
          width: context.thickBorderWidth(),
        ),
      ),
      child: Image(
        image: AssetImage(isStart ? startWashImage: stopWashImage)
      ),
    );

///Music Button Image
Widget musicButtonImage(BuildContext context, bool isPlay) =>
    Container(
      width: context.musicButtonSize(),
      height: context.musicButtonSize(),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: whiteColor,
        border: Border.all(
          color: isPlay ? lightGreen!: borderBlack,
          width: context.thinBorderWidth(),
        ),
      ),
      child: Image(
        image: AssetImage(isPlay ? musicImage: stopWashImage)
      ),
    );

/// Volume Button Image
Widget volumeButtonImage(BuildContext context, bool isPlus) =>
    Container(
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
        child: Icon(isPlus ? CupertinoIcons.plus: CupertinoIcons.minus,
          color: blackColor,
          size: context.volumeIconSize(),
        ),
      ),
    );

///Flush Button Image
Widget flushButtonImage(BuildContext context) =>
    Container(
      width: context.flushButtonWidth(),
      height: context.flushButtonHeight(),
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
    );

///Volume Lump Image
Widget volumeLamp(BuildContext context, int lampNumber, int volume) =>
    Container(
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
          color: lampNumber.lampColor(volume, deepGreen),
        ),
      ),
    );

