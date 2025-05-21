// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CredentialsResponseImpl _$$CredentialsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CredentialsResponseImpl(
      credentials: TemporaryCredentials.fromJson(
          json['credentials'] as Map<String, dynamic>),
      requestId: json['requestId'] as String,
      expiration: json['expiration'] as String,
      startTime: (json['startTime'] as num).toInt(),
      expiredTime: (json['expiredTime'] as num).toInt(),
    );

Map<String, dynamic> _$$CredentialsResponseImplToJson(
        _$CredentialsResponseImpl instance) =>
    <String, dynamic>{
      'credentials': instance.credentials,
      'requestId': instance.requestId,
      'expiration': instance.expiration,
      'startTime': instance.startTime,
      'expiredTime': instance.expiredTime,
    };

_$TemporaryCredentialsImpl _$$TemporaryCredentialsImplFromJson(
        Map<String, dynamic> json) =>
    _$TemporaryCredentialsImpl(
      tmpSecretId: json['tmpSecretId'] as String,
      tmpSecretKey: json['tmpSecretKey'] as String,
      sessionToken: json['sessionToken'] as String,
    );

Map<String, dynamic> _$$TemporaryCredentialsImplToJson(
        _$TemporaryCredentialsImpl instance) =>
    <String, dynamic>{
      'tmpSecretId': instance.tmpSecretId,
      'tmpSecretKey': instance.tmpSecretKey,
      'sessionToken': instance.sessionToken,
    };
