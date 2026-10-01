import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _isInitialized = false;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static DateTime? _lastInterstitialTime;

  // Google Official Test Ad Unit IDs (Safe for Development)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadInterstitialAd();
      preloadRewardedAd();
    } catch (_) {}
  }

  // ===============================
  // Adaptive Banner Ad Helper
  // ===============================

  static BannerAd createBannerAd({
    required VoidCallback onAdLoaded,
    required Function(LoadAdError) onAdFailed,
  }) {
    final banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailed(error);
        },
      ),
    );
    banner.load();
    return banner;
  }

  // ===============================
  // Interstitial Ad Helper
  // ===============================

  static void preloadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd({VoidCallback? onAdClosed}) {
    final now = DateTime.now();
    // Cooldown check: Only show interstitial if at least 2 minutes passed
    if (_lastInterstitialTime != null &&
        now.difference(_lastInterstitialTime!) < const Duration(minutes: 2)) {
      if (onAdClosed != null) onAdClosed();
      return;
    }

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _lastInterstitialTime = DateTime.now();
          preloadInterstitialAd();
          if (onAdClosed != null) onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          preloadInterstitialAd();
          if (onAdClosed != null) onAdClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      preloadInterstitialAd();
      if (onAdClosed != null) onAdClosed();
    }
  }

  // ===============================
  // Rewarded Video Ad Helper
  // ===============================

  static void preloadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          preloadRewardedAd();
          if (onAdClosed != null) onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          preloadRewardedAd();
          if (onAdClosed != null) onAdClosed();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward);
      });
      _rewardedAd = null;
    } else {
      preloadRewardedAd();
      if (onAdClosed != null) onAdClosed();
    }
  }
}
