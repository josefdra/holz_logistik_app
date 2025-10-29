import 'dart:io' show Platform;

import 'package:holz_logistik_backend/api/api.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> startNavigation(Location loc) async {
  if (Platform.isAndroid) {
    final url = Uri.parse(
      'geo:${loc.latitude},${loc.longitude}?q=${loc.latitude},${loc.longitude}',
    );

    await launchUrl(url);
  } else if (Platform.isIOS) {
    final googleMapsUrl = Uri.parse(
      'comgooglemaps://?q=${loc.latitude},${loc.longitude}&center=${loc.latitude},${loc.longitude}',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
      return;
    }

    final url = Uri.parse(
      // ignore: lines_longer_than_80_chars
      'maps:${loc.latitude},${loc.longitude}?q=${loc.latitude},${loc.longitude}',
    );
    await launchUrl(url);
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${loc.latitude},${loc.longitude}',
    );
    
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
