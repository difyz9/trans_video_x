import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

class UserModel {
  final String userId;
  final String userName;
  final String email;
  final int isVip;
  final String vipExpire;
  final String avatar;

  UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.isVip,
    required this.vipExpire,
    required this.avatar,
  });

  // Create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'].toString(),
      userName: json['userName'] as String,
      email: json['email'] as String? ?? '',
      isVip: json['isVip'] as int? ?? 0,
      vipExpire: json['vipExpire'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'isVip': isVip,
      'vipExpire': vipExpire,
      'avatar': avatar,
    };
  }

  // Create a copy of the UserModel with updated fields
  UserModel copyWith({
    String? userId,
    String? userName,
    String? email,
    int? isVip,
    String? vipExpire,
    String? avatar,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      isVip: isVip ?? this.isVip,
      vipExpire: vipExpire ?? this.vipExpire,
      avatar: avatar ?? this.avatar,
    );
  }
}

@freezed
class CredentialsResponse with _$CredentialsResponse {
  const factory CredentialsResponse({
    required TemporaryCredentials credentials,
    required String requestId,
    required String expiration,
    required int startTime,
    required int expiredTime,
  }) = _CredentialsResponse;

  factory CredentialsResponse.fromJson(Map<String, dynamic> json) => 
      _$CredentialsResponseFromJson(json);
}

@freezed
class TemporaryCredentials with _$TemporaryCredentials {
  const factory TemporaryCredentials({
    required String tmpSecretId,
    required String tmpSecretKey,
    required String sessionToken,
  }) = _TemporaryCredentials;

  factory TemporaryCredentials.fromJson(Map<String, dynamic> json) => 
      _$TemporaryCredentialsFromJson(json);
}
