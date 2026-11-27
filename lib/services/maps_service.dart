import 'package:url_launcher/url_launcher.dart';

Future<bool> bukaGoogleMaps(String query, {bool petunjukArah = false}) async {
  final tujuan = query.trim();
  if (tujuan.isEmpty) return false;

  final uri = Uri.https(
    'www.google.com',
    petunjukArah ? '/maps/dir/' : '/maps/search/',
    {
      'api': '1',
      if (petunjukArah) 'destination': tujuan else 'query': tujuan,
      if (petunjukArah) 'travelmode': 'driving',
    },
  );

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
