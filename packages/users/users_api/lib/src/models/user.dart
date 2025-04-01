import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:users_api/users_api.dart';

part 'user.g.dart';

/// Defines the possible roles a user can have
@JsonEnum(valueField: 'value')
enum Role {
  /// Basic user (regular permissions)
  basic(0),

  /// Privileged user (administrative permissions)
  privileged(1);

  /// Constructor with integer value
  const Role(this.value);

  /// Integer value of the role
  final int value;

  /// Get Role from integer value
  static Role fromValue(int value) {
    return Role.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Role.basic,
    );
  }
}

/// {@template user_item}
/// A single `user` item.
///
/// Contains a [id], [role], time of the [lastEdit] and [name].
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
    required this.role,
    required this.lastEdit,
    required this.name,
  });

  /// The id of the `user`.
  ///
  /// Cannot be empty.
  final int id;

  /// The `user`role.
  ///
  /// Cannot be empty.
  final Role role;

  /// The time the `user` was last modified.
  ///
  /// Cannot be empty.
  final DateTime lastEdit;

  /// The name of the `user`.
  ///
  /// Cannot be empty.
  final String name;

  /// Returns a copy of this `user` with the given values updated.
  ///
  /// {@macro user_item}
  User copyWith({
    int? id,
    Role? role,
    DateTime? lastEdit,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      lastEdit: lastEdit ?? this.lastEdit,
      name: name ?? this.name,
    );
  }

  /// Deserializes the given [JsonMap] into a [User].
  static User fromJson(JsonMap json) => _$UserFromJson(json);

  /// Converts this [User] into a [JsonMap].
  JsonMap toJson() => _$UserToJson(this);

  @override
  List<Object> get props => [id, role, lastEdit, name];
}
