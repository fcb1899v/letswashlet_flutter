import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'extension.dart';

/// Ad Banner Widget
/// Manages Google Mobile Ads banner display with consent handling
/// Handles different ad unit IDs for debug/release and iOS/Android platforms
class AdBannerWidget extends HookWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // State management for ad loading
    final adLoaded = useState(false);
    final adFailedLoading = useState(false);
    final bannerAd = useState<BannerAd?>(null);
    // final testIdentifiers = ['2793ca2a-5956-45a2-96c0-16fafddc1a15'];

    /// Get appropriate banner ad unit ID based on platform and build mode
    /// Returns test IDs for debug mode, production IDs for release mode
    String bannerUnitId() =>
        (!kDebugMode && Platform.isIOS) ? dotenv.get("IOS_BANNER_UNIT_ID") :
        (!kDebugMode && Platform.isAndroid) ? dotenv.get(
            "ANDROID_BANNER_UNIT_ID") :
        (Platform.isIOS) ? dotenv.get("IOS_BANNER_TEST_ID") :
        dotenv.get("ANDROID_BANNER_TEST_ID");

    /// Load banner ad with error handling and retry logic
    /// Creates BannerAd instance with appropriate size and listener
    Future<void> loadAdBanner() async {
      final adBanner = BannerAd(
        adUnitId: bannerUnitId(),
        size: AdSize.largeBanner,
        request: const AdRequest(),
        listener: BannerAdListener(
          /// Called when ad successfully loads
          onAdLoaded: (Ad ad) {
            'Ad: $ad loaded.'.debugPrint();
            adLoaded.value = true;
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

    /// Initialize ad loading with consent management
    /// Handles GDPR consent requirements before loading ads
    useEffect(() {
      ConsentInformation.instance.requestConsentInfoUpdate(ConsentRequestParameters(
        // consentDebugSettings: ConsentDebugSettings(
        //   debugGeography: DebugGeography.debugGeographyEea,
        //   testIdentifiers: testIdentifiers,
        // ),
      ), () async {
        /// Check if consent form is available
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadConsentForm((ConsentForm consentForm) async {
            var status = await ConsentInformation.instance.getConsentStatus();
            "status: $status".debugPrint();
            
            /// Show consent form if required, otherwise load ad directly
            if (status == ConsentStatus.required) {
              consentForm.show((formError) async => await loadAdBanner());
            } else {
              await loadAdBanner();
            }
          }, (formError) {});
        } else {
          /// Load ad directly if no consent form is available
          await loadAdBanner();
        }
      }, (FormError error) {});
      
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
