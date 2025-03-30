import 'dart:convert';

void main(List<String> args) {
  List<String> test = [];
  print(test);

  final new_test = jsonDecode(jsonEncode(test));
  print(new_test);
}