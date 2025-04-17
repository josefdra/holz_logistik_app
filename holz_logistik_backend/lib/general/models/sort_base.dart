/// Interface for providing standard access to sortable data properties
abstract class Gettable {
  /// The date property used for chronological sorting
  DateTime get date;
  
  /// The name property used for alphabetical sorting
  String get name;
}
