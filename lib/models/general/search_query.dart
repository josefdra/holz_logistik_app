import 'package:holz_logistik_backend/general/general.dart';

class SearchQuery<T extends Gettable>{
  const SearchQuery({this.searchQuery = ''});

  final String searchQuery;

  bool apply(T item) {
    if (searchQuery.isEmpty) return true;

    final lowercaseQuery = searchQuery.toLowerCase();
    return item.name.toLowerCase().contains(lowercaseQuery);
  }

  Iterable<T> applyAll(Iterable<T> locations) {
    return locations.where(apply);
  }
}
