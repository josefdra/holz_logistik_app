/// A callback type for handling sync requests
typedef DateGetter = Future<DateTime> Function(String);

/// A callback type for handling sync requests
typedef DateSetter = Future<void> Function(String, DateTime);
