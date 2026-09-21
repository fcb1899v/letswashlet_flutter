import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'extension.dart';
import 'constant.dart';

/// Ad banner widget: loads a Google Mobile Ads banner with consent handling
/// and picks the unit id per debug/release and iOS/Android.
class AdBannerWidget extends HookWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // State management for ad loading
    final adLoaded = useState(false);
    final adFailedLoading = useState(false);
    final bannerAd = useState<BannerAd?>(null);
    // Ref, not state: the consent callbacks resolve after this widget can be
    // gone, and writing to a disposed ValueNotifier asserts in debug
    final isAdRequested = useRef(false);
    // final testIdentifiers = ['2793ca2a-5956-45a2-96c0-16fafddc1a15'];

    /// Get appropriate banner ad unit ID based on platform and build mode
    /// Returns test IDs for debug mode, production IDs for release mode
    String bannerUnitId() =>
        (!kDebugMode && Platform.isIOS) ? dotenv.get("IOS_BANNER_UNIT_ID") :
        (!kDebugMode && Platform.isAndroid) ? dotenv.get(
            "ANDROID_BANNER_UNIT_ID") :
        (Platform.isIOS) ? iosBannerTestId :
        androidBannerTestId;

    /// Load banner ad with error handling and retry logic
    /// Creates BannerAd instance with appropriate size and listener
    Future<void> loadAdBanner() async {
      // largeBanner asked for a fixed 320x100 inside a box sized by admobWidth
      // and admobHeight. Inline adaptive asks for that box's width and height
      final cap = context.admobHeight().toInt();
      final size = AdSize.getInlineAdaptiveBannerAdSize(
          context.admobWidth().toInt(), cap);
      final adBanner = BannerAd(
        adUnitId: bannerUnitId(),
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          /// Called when ad successfully loads
          onAdLoaded: (Ad ad) async {
            'Ad: $ad loaded.'.debugPrint();
            // Mount first; the await below only feeds a debug line
            adLoaded.value = true;
            if (kDebugMode) {
              // Requested and served together: neither alone separates the size
              // asked for from the creative Google had to hand
              final served = await (ad as BannerAd).getPlatformAdSize();
              'AdSize: ${size.width} x cap $cap / served: ${served?.width} x ${served?.height}'.debugPrint();
            }
          },
          /// Called when ad fails to load
          /// Disposes failed ad and retries after 30 seconds
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            'Ad: $ad failed to load: $error'.debugPrint();
            adFailedLoading.value = true;
            Future.delayed(const Duration(seconds: 30), () {
              if (!adLoaded.value && !adFailedLoading.value) loadAdBanner();
            });
          },
        ),
      );
      adBanner.load();
      bannerAd.value = adBanner;
    }

    /// The single gate for the ad request. canRequestAds is the SDK's own verdict
    /// (region, TCF, Additional Consent); never decide from ConsentStatus in the app.
    Future<void> requestAdIfAllowed() async {
      if (isAdRequested.value) return;
      if (!await ConsentInformation.instance.canRequestAds()) return;
      // Both callers race across that await. Claiming the request with no await
      // in between means no second BannerAd is created for the same slot
      if (isAdRequested.value) return;
      isAdRequested.value = true;
      await loadAdBanner();
    }

    /// Initialize ad loading with consent management
    /// Handles GDPR consent requirements before loading ads
    useEffect(() {
      ConsentInformation.instance.requestConsentInfoUpdate(ConsentRequestParameters(
        // consentDebugSettings: ConsentDebugSettings(
        //   debugGeography: DebugGeography.debugGeographyEea,
        //   testIdentifiers: testIdentifiers,
        // ),
      ), () async {
        // The SDK decides whether a form is required, loads it and presents it.
        // Do not request from the form callback: it fires even when the user declined
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
          if (formError != null) {
            "formError: ${formError.errorCode}: ${formError.message}".debugPrint();
          }
          await requestAdIfAllowed();
        });
      }, (FormError error) async {
        // The update failed, but earlier consent still stands and canRequestAds
        // can still say yes, so do not stop here
        "error: ${error.errorCode}: ${error.message}".debugPrint();
        await requestAdIfAllowed();
      });

      "bannerAd: ${bannerAd.value}".debugPrint();
      
      /// Cleanup: dispose ad when widget unmounts
      return () => bannerAd.value?.dispose();
    }, []);

    /// Render ad banner container
    /// Shows ad widget when loaded, empty container when not loaded
    return SizedBox(
      width: context.admobWidth(),
      height: context.admobHeight(),
      child: (adLoaded.value) ? AdWidget(ad: bannerAd.value!) : null,
    );
  }
}
