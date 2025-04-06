import 'package:holz_logistik_backend/api/location_api.dart';

class LocationListSearchQuery {
  const LocationListSearchQuery({this.searchQuery = ''});

  final String searchQuery;

  bool apply(Location location) {
    if (searchQuery.isEmpty) return true;

    final lowercaseQuery = searchQuery.toLowerCase();
    return location.partieNr.toLowerCase().contains(lowercaseQuery);
  }

  Iterable<Location> applyAll(Iterable<Location> locations) {
    return locations.where(apply);
  }
}
