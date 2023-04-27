import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'helper/ad_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Google Mobile Ads SDK
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  MyHomePage(title: 'Google Ads Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );


   String testDevice = 'YOUR_DEVICE_ID';
   int maxFailedLoadAttempts = 3;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  BannerAd? _bannerAd;
  int _numBannerLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    // Interstitial ads are full-screen ads that cover the interface of their host app. They're typically displayed at natural transition points in the flow of an app, '
    // 'such as between activities or during the pause between levels in a game.

    _createInterstitialAd();

    // Banner ads occupy a spot within an app's layout, either at the top or bottom of the device screen.
    _createBannerAd();


    _createRewardedAd();
    _createRewardedInterstitialAd();
  }

  void _createInterstitialAd() {
    // Loading an InterstitialAd requires an adUnitId, an AdRequest, and an InterstitialAdLoadCallback. The following example loads an interstitial ad:
    InterstitialAd.load(
        // adUnitId: Platform.isAndroid
        //     ? 'ca-app-pub-3940256099942544/1033173712'
        //     : 'ca-app-pub-3940256099942544/4411468910',
        adUnitId: AdHelper.interstitialAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
        });
    _rewardedAd = null;
  }

  void _createBannerAd() {
    // TODO: Load a banner ad
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    // before showing the ad to receive notifications for these events

    // access to it is no longer needed. The best practice for when to call dispose() is in
    // the FullScreenContentCallback.onAdDismissedFullScreenContent and FullScreenContentCallback.onAdFailedToShowFullScreenContent callbacks.
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    // Display an Interstitial Ad
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

  void _showRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
              print('$ad onAdShowedFullScreenContent.'),
          onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
            print('$ad onAdDismissedFullScreenContent.');
            ad.dispose();
            _createRewardedInterstitialAd();
          },
          onAdFailedToShowFullScreenContent:
              (RewardedInterstitialAd ad, AdError error) {
            print('$ad onAdFailedToShowFullScreenContent: $error');
            ad.dispose();
            _createRewardedInterstitialAd();
          },
        );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
        });
    _rewardedInterstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AdMob Plugin example app'),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (String result) {
                  switch (result) {
                    case 'InterstitialAd':
                      _showInterstitialAd();
                      break;
                    case 'RewardedAd':
                      _showRewardedAd();
                      break;
                    case 'RewardedInterstitialAd':
                      _showRewardedInterstitialAd();
                      break;
                    // case 'Fluid':
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => FluidExample()),
                    //   );
                    //   break;
                    // case 'Inline adaptive':
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => InlineAdaptiveExample()),
                    //   );
                    //   break;
                    // case 'Anchored adaptive':
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => AnchoredAdaptiveExample()),
                    //   );
                    //   break;
                    default:
                      throw AssertionError('unexpected button: $result');
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'InterstitialAd',
                    child: Text('InterstitialAd'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'RewardedAd',
                    child: Text('RewardedAd'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'RewardedInterstitialAd',
                    child: Text('RewardedInterstitialAd'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Fluid',
                    child: Text('Fluid'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Inline adaptive',
                    child: Text('Inline adaptive'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Anchored adaptive',
                    child: Text('Anchored adaptive'),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(child: Column(
            children: [
              if(_bannerAd !=null)
                Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ],
          )),
        );
      }),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  }

