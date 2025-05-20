// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CredentialsResponse _$CredentialsResponseFromJson(Map<String, dynamic> json) {
  return _CredentialsResponse.fromJson(json);
}

/// @nodoc
mixin _$CredentialsResponse {
  TemporaryCredentials get credentials => throw _privateConstructorUsedError;
  String get requestId => throw _privateConstructorUsedError;
  String get expiration => throw _privateConstructorUsedError;
  int get startTime => throw _privateConstructorUsedError;
  int get expiredTime => throw _privateConstructorUsedError;

  /// Serializes this CredentialsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CredentialsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CredentialsResponseCopyWith<CredentialsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialsResponseCopyWith<$Res> {
  factory $CredentialsResponseCopyWith(
    CredentialsResponse value,
    $Res Function(CredentialsResponse) then,
  ) = _$CredentialsResponseCopyWithImpl<$Res, CredentialsResponse>;
  @useResult
  $Res call({
    TemporaryCredentials credentials,
    String requestId,
    String expiration,
    int startTime,
    int expiredTime,
  });

  $TemporaryCredentialsCopyWith<$Res> get credentials;
}

/// @nodoc
class _$CredentialsResponseCopyWithImpl<$Res, $Val extends CredentialsResponse>
    implements $CredentialsResponseCopyWith<$Res> {
  _$CredentialsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CredentialsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
    Object? requestId = null,
    Object? expiration = null,
    Object? startTime = null,
    Object? expiredTime = null,
  }) {
    return _then(
      _value.copyWith(
            credentials:
                null == credentials
                    ? _value.credentials
                    : credentials // ignore: cast_nullable_to_non_nullable
                        as TemporaryCredentials,
            requestId:
                null == requestId
                    ? _value.requestId
                    : requestId // ignore: cast_nullable_to_non_nullable
                        as String,
            expiration:
                null == expiration
                    ? _value.expiration
                    : expiration // ignore: cast_nullable_to_non_nullable
                        as String,
            startTime:
                null == startTime
                    ? _value.startTime
                    : startTime // ignore: cast_nullable_to_non_nullable
                        as int,
            expiredTime:
                null == expiredTime
                    ? _value.expiredTime
                    : expiredTime // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }

  /// Create a copy of CredentialsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TemporaryCredentialsCopyWith<$Res> get credentials {
    return $TemporaryCredentialsCopyWith<$Res>(_value.credentials, (value) {
      return _then(_value.copyWith(credentials: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CredentialsResponseImplCopyWith<$Res>
    implements $CredentialsResponseCopyWith<$Res> {
  factory _$$CredentialsResponseImplCopyWith(
    _$CredentialsResponseImpl value,
    $Res Function(_$CredentialsResponseImpl) then,
  ) = __$$CredentialsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TemporaryCredentials credentials,
    String requestId,
    String expiration,
    int startTime,
    int expiredTime,
  });

  @override
  $TemporaryCredentialsCopyWith<$Res> get credentials;
}

/// @nodoc
class __$$CredentialsResponseImplCopyWithImpl<$Res>
    extends _$CredentialsResponseCopyWithImpl<$Res, _$CredentialsResponseImpl>
    implements _$$CredentialsResponseImplCopyWith<$Res> {
  __$$CredentialsResponseImplCopyWithImpl(
    _$CredentialsResponseImpl _value,
    $Res Function(_$CredentialsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CredentialsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
    Object? requestId = null,
    Object? expiration = null,
    Object? startTime = null,
    Object? expiredTime = null,
  }) {
    return _then(
      _$CredentialsResponseImpl(
        credentials:
            null == credentials
                ? _value.credentials
                : credentials // ignore: cast_nullable_to_non_nullable
                    as TemporaryCredentials,
        requestId:
            null == requestId
                ? _value.requestId
                : requestId // ignore: cast_nullable_to_non_nullable
                    as String,
        expiration:
            null == expiration
                ? _value.expiration
                : expiration // ignore: cast_nullable_to_non_nullable
                    as String,
        startTime:
            null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                    as int,
        expiredTime:
            null == expiredTime
                ? _value.expiredTime
                : expiredTime // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialsResponseImpl implements _CredentialsResponse {
  const _$CredentialsResponseImpl({
    required this.credentials,
    required this.requestId,
    required this.expiration,
    required this.startTime,
    required this.expiredTime,
  });

  factory _$CredentialsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CredentialsResponseImplFromJson(json);

  @override
  final TemporaryCredentials credentials;
  @override
  final String requestId;
  @override
  final String expiration;
  @override
  final int startTime;
  @override
  final int expiredTime;

  @override
  String toString() {
    return 'CredentialsResponse(credentials: $credentials, requestId: $requestId, expiration: $expiration, startTime: $startTime, expiredTime: $expiredTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialsResponseImpl &&
            (identical(other.credentials, credentials) ||
                other.credentials == credentials) &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.expiration, expiration) ||
                other.expiration == expiration) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.expiredTime, expiredTime) ||
                other.expiredTime == expiredTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    credentials,
    requestId,
    expiration,
    startTime,
    expiredTime,
  );

  /// Create a copy of CredentialsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialsResponseImplCopyWith<_$CredentialsResponseImpl> get copyWith =>
      __$$CredentialsResponseImplCopyWithImpl<_$CredentialsResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialsResponseImplToJson(this);
  }
}

abstract class _CredentialsResponse implements CredentialsResponse {
  const factory _CredentialsResponse({
    required final TemporaryCredentials credentials,
    required final String requestId,
    required final String expiration,
    required final int startTime,
    required final int expiredTime,
  }) = _$CredentialsResponseImpl;

  factory _CredentialsResponse.fromJson(Map<String, dynamic> json) =
      _$CredentialsResponseImpl.fromJson;

  @override
  TemporaryCredentials get credentials;
  @override
  String get requestId;
  @override
  String get expiration;
  @override
  int get startTime;
  @override
  int get expiredTime;

  /// Create a copy of CredentialsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CredentialsResponseImplCopyWith<_$CredentialsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemporaryCredentials _$TemporaryCredentialsFromJson(Map<String, dynamic> json) {
  return _TemporaryCredentials.fromJson(json);
}

/// @nodoc
mixin _$TemporaryCredentials {
  String get tmpSecretId => throw _privateConstructorUsedError;
  String get tmpSecretKey => throw _privateConstructorUsedError;
  String get sessionToken => throw _privateConstructorUsedError;

  /// Serializes this TemporaryCredentials to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TemporaryCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemporaryCredentialsCopyWith<TemporaryCredentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemporaryCredentialsCopyWith<$Res> {
  factory $TemporaryCredentialsCopyWith(
    TemporaryCredentials value,
    $Res Function(TemporaryCredentials) then,
  ) = _$TemporaryCredentialsCopyWithImpl<$Res, TemporaryCredentials>;
  @useResult
  $Res call({String tmpSecretId, String tmpSecretKey, String sessionToken});
}

/// @nodoc
class _$TemporaryCredentialsCopyWithImpl<
  $Res,
  $Val extends TemporaryCredentials
>
    implements $TemporaryCredentialsCopyWith<$Res> {
  _$TemporaryCredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemporaryCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmpSecretId = null,
    Object? tmpSecretKey = null,
    Object? sessionToken = null,
  }) {
    return _then(
      _value.copyWith(
            tmpSecretId:
                null == tmpSecretId
                    ? _value.tmpSecretId
                    : tmpSecretId // ignore: cast_nullable_to_non_nullable
                        as String,
            tmpSecretKey:
                null == tmpSecretKey
                    ? _value.tmpSecretKey
                    : tmpSecretKey // ignore: cast_nullable_to_non_nullable
                        as String,
            sessionToken:
                null == sessionToken
                    ? _value.sessionToken
                    : sessionToken // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TemporaryCredentialsImplCopyWith<$Res>
    implements $TemporaryCredentialsCopyWith<$Res> {
  factory _$$TemporaryCredentialsImplCopyWith(
    _$TemporaryCredentialsImpl value,
    $Res Function(_$TemporaryCredentialsImpl) then,
  ) = __$$TemporaryCredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String tmpSecretId, String tmpSecretKey, String sessionToken});
}

/// @nodoc
class __$$TemporaryCredentialsImplCopyWithImpl<$Res>
    extends _$TemporaryCredentialsCopyWithImpl<$Res, _$TemporaryCredentialsImpl>
    implements _$$TemporaryCredentialsImplCopyWith<$Res> {
  __$$TemporaryCredentialsImplCopyWithImpl(
    _$TemporaryCredentialsImpl _value,
    $Res Function(_$TemporaryCredentialsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TemporaryCredentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmpSecretId = null,
    Object? tmpSecretKey = null,
    Object? sessionToken = null,
  }) {
    return _then(
      _$TemporaryCredentialsImpl(
        tmpSecretId:
            null == tmpSecretId
                ? _value.tmpSecretId
                : tmpSecretId // ignore: cast_nullable_to_non_nullable
                    as String,
        tmpSecretKey:
            null == tmpSecretKey
                ? _value.tmpSecretKey
                : tmpSecretKey // ignore: cast_nullable_to_non_nullable
                    as String,
        sessionToken:
            null == sessionToken
                ? _value.sessionToken
                : sessionToken // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TemporaryCredentialsImpl implements _TemporaryCredentials {
  const _$TemporaryCredentialsImpl({
    required this.tmpSecretId,
    required this.tmpSecretKey,
    required this.sessionToken,
  });

  factory _$TemporaryCredentialsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemporaryCredentialsImplFromJson(json);

  @override
  final String tmpSecretId;
  @override
  final String tmpSecretKey;
  @override
  final String sessionToken;

  @override
  String toString() {
    return 'TemporaryCredentials(tmpSecretId: $tmpSecretId, tmpSecretKey: $tmpSecretKey, sessionToken: $sessionToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemporaryCredentialsImpl &&
            (identical(other.tmpSecretId, tmpSecretId) ||
                other.tmpSecretId == tmpSecretId) &&
            (identical(other.tmpSecretKey, tmpSecretKey) ||
                other.tmpSecretKey == tmpSecretKey) &&
            (identical(other.sessionToken, sessionToken) ||
                other.sessionToken == sessionToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, tmpSecretId, tmpSecretKey, sessionToken);

  /// Create a copy of TemporaryCredentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemporaryCredentialsImplCopyWith<_$TemporaryCredentialsImpl>
  get copyWith =>
      __$$TemporaryCredentialsImplCopyWithImpl<_$TemporaryCredentialsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TemporaryCredentialsImplToJson(this);
  }
}

abstract class _TemporaryCredentials implements TemporaryCredentials {
  const factory _TemporaryCredentials({
    required final String tmpSecretId,
    required final String tmpSecretKey,
    required final String sessionToken,
  }) = _$TemporaryCredentialsImpl;

  factory _TemporaryCredentials.fromJson(Map<String, dynamic> json) =
      _$TemporaryCredentialsImpl.fromJson;

  @override
  String get tmpSecretId;
  @override
  String get tmpSecretKey;
  @override
  String get sessionToken;

  /// Create a copy of TemporaryCredentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemporaryCredentialsImplCopyWith<_$TemporaryCredentialsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
