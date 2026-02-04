import 'package:json_annotation/json_annotation.dart';
import 'user_dto.dart';

@JsonSerializable()
class LoginResponseDto {
  final String token;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  final UserDto user;

  LoginResponseDto({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String?,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refresh_token': refreshToken,
    'user': user.toJson(),
  };
}
