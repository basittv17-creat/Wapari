import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Runs Google's UMP consent flow before Wapari requests any AdMob ads.
class AdConsentService extends ChangeNotifier {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  bool _initialized = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;
  bool _adsSdkInitialized = false;

  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
          if (formError != null) {
            debugPrint('Wapari consent form: ${formError.message}');
          }
          await _refreshConsentState();
        });
      },
      (FormError error) async {
        debugPrint('Wapari consent update failed: ${error.message}');
        await _refreshConsentState();
      },
    );

    // UMP may already have a valid consent decision from the previous session.
    await _refreshConsentState();
  }

  Future<void> _refreshConsentState() async {
    try {
      final canRequest = await ConsentInformation.instance.canRequestAds();
      final privacyStatus = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      final required =
          privacyStatus == PrivacyOptionsRequirementStatus.required;
      final changed = canRequest != _canRequestAds ||
          required != _privacyOptionsRequired;
      _canRequestAds = canRequest;
      _privacyOptionsRequired = required;

      if (_canRequestAds && !_adsSdkInitialized) {
        _adsSdkInitialized = true;
        await MobileAds.instance.initialize();
      }
      if (changed) notifyListeners();
    } catch (error) {
      debugPrint('Wapari consent state check failed: $error');
    }
  }

  Future<void> showPrivacyOptions(BuildContext context) async {
    if (!_privacyOptionsRequired) return;
    await ConsentForm.showPrivacyOptionsForm((formError) async {
      if (formError != null) {
        debugPrint('Wapari privacy options form: ${formError.message}');
      }
      await _refreshConsentState();
      if (context.mounted && formError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy options could not be opened. Please try again.'),
          ),
        );
      }
    });
  }
}
