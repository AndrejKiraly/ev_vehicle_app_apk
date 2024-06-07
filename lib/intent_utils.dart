import "package:url_launcher/url_launcher.dart";
import 'package:http/http.dart';
import 'package:flutter/material.dart';

class IntentUtils {
  IntentUtils._();
  static Future<void> launchGoogleMaps(
      double destinationLatitude, double destinationLongitude) async {
    String googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$destinationLatitude,$destinationLongitude";
    Uri uri = Uri.parse(googleMapUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw ('Could not open the map');
    }
  }
}
