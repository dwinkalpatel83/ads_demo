import 'package:flutter/material.dart';
// TODO: Import ad_helper.dart
import 'helper/ad_helper.dart';

// TODO: Import google_mobile_ads.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeInlinePage extends StatefulWidget {
  const NativeInlinePage({Key? key}) : super(key: key);

  @override
  State<NativeInlinePage> createState() => _NativeInlinePageState();
}

class _NativeInlinePageState extends State<NativeInlinePage> {


  // TODO: Add _kAdIndex
  // _kAdIndex indicates the index where a banner ad will be displayed,
  static final _kAdIndex = 4;

  // TODO: Add a native ad instance
  NativeAd? _ad;

  @override
  void initState() {
    // TODO: implement initState
    // TODO: Create a NativeAd instance
    _ad = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');       },
      ),
    );

    _ad?.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // TODO: Add _getDestinationItemIndex()
  //used to calculate the item index from the _getDestinationItemIndex() method.
  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && _ad != null) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  @override
  void dispose() {
    // TODO: Dispose a NativeAd object
    _ad?.dispose();
    super.dispose();
  }

}
