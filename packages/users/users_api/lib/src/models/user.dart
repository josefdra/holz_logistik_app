import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:users_api/users_api.dart';

part 'user.g.dart';

enum Role { basic, privileged }

/// {@template user_item}
/// A single `user` item.
///
/// Contains a [id], [name] in addition to a [role]
/// flag.
///
/// [User]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class User extends Equatable {
  /// {@macro user_item}
  const User({
    required this.id,
    required this.name,
    required this.role,
  });

  /// The id of the `user`.
  ///
  /// Cannot be empty.
  final int id;

  /// The name of the `user`.
  ///
  /// Cannot be empty.
  final String name;

  /// The `user`role.
  ///
  /// Cannot be empty.
  final Role role;

  /// Returns a copy of this `user` with the given values updated.
  ///
  /// {@macro user_item}
  User copyWith({
    int? id,
    String? name,
    Role? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  /// Deserializes the given [JsonMap] into a [User].
  static User fromJson(JsonMap json) => _$UserFromJson(json);

  /// Converts this [User] into a [JsonMap].
  JsonMap toJson() => _$UserToJson(this);

  @override
  List<Object> get props => [id, name, role];
}
