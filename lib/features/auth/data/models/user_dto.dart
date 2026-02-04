import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

@JsonSerializable()
class UserDto {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'created_at': createdAt,
  };

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }

  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      createdAt: user.createdAt?.toIso8601String(),
    );
  }
}
