class DataItem {
  final String name;
  final String description;

  DataItem({required this.name, required this.description});

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      name: json['name'],
      description: json['description'],
    );
  }
}
