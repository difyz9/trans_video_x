// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoListResponse _$VideoListResponseFromJson(Map<String, dynamic> json) {
  return _VideoListResponse.fromJson(json);
}

/// @nodoc
mixin _$VideoListResponse {
  int get total => throw _privateConstructorUsedError;
  List<dynamic>? get rows => throw _privateConstructorUsedError;
  List<VideoItem>? get data => throw _privateConstructorUsedError;
  int get code => throw _privateConstructorUsedError;
  String get msg => throw _privateConstructorUsedError;

  /// Serializes this VideoListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoListResponseCopyWith<VideoListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoListResponseCopyWith<$Res> {
  factory $VideoListResponseCopyWith(
          VideoListResponse value, $Res Function(VideoListResponse) then) =
      _$VideoListResponseCopyWithImpl<$Res, VideoListResponse>;
  @useResult
  $Res call(
      {int total,
      List<dynamic>? rows,
      List<VideoItem>? data,
      int code,
      String msg});
}

/// @nodoc
class _$VideoListResponseCopyWithImpl<$Res, $Val extends VideoListResponse>
    implements $VideoListResponseCopyWith<$Res> {
  _$VideoListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? rows = freezed,
    Object? data = freezed,
    Object? code = null,
    Object? msg = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      rows: freezed == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<VideoItem>?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoListResponseImplCopyWith<$Res>
    implements $VideoListResponseCopyWith<$Res> {
  factory _$$VideoListResponseImplCopyWith(_$VideoListResponseImpl value,
          $Res Function(_$VideoListResponseImpl) then) =
      __$$VideoListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total,
      List<dynamic>? rows,
      List<VideoItem>? data,
      int code,
      String msg});
}

/// @nodoc
class __$$VideoListResponseImplCopyWithImpl<$Res>
    extends _$VideoListResponseCopyWithImpl<$Res, _$VideoListResponseImpl>
    implements _$$VideoListResponseImplCopyWith<$Res> {
  __$$VideoListResponseImplCopyWithImpl(_$VideoListResponseImpl _value,
      $Res Function(_$VideoListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? rows = freezed,
    Object? data = freezed,
    Object? code = null,
    Object? msg = null,
  }) {
    return _then(_$VideoListResponseImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      rows: freezed == rows
          ? _value._rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<VideoItem>?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoListResponseImpl implements _VideoListResponse {
  const _$VideoListResponseImpl(
      {required this.total,
      final List<dynamic>? rows,
      required final List<VideoItem>? data,
      required this.code,
      required this.msg})
      : _rows = rows,
        _data = data;

  factory _$VideoListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoListResponseImplFromJson(json);

  @override
  final int total;
  final List<dynamic>? _rows;
  @override
  List<dynamic>? get rows {
    final value = _rows;
    if (value == null) return null;
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<VideoItem>? _data;
  @override
  List<VideoItem>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int code;
  @override
  final String msg;

  @override
  String toString() {
    return 'VideoListResponse(total: $total, rows: $rows, data: $data, code: $code, msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoListResponseImpl &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._rows, _rows) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      total,
      const DeepCollectionEquality().hash(_rows),
      const DeepCollectionEquality().hash(_data),
      code,
      msg);

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoListResponseImplCopyWith<_$VideoListResponseImpl> get copyWith =>
      __$$VideoListResponseImplCopyWithImpl<_$VideoListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoListResponseImplToJson(
      this,
    );
  }
}

abstract class _VideoListResponse implements VideoListResponse {
  const factory _VideoListResponse(
      {required final int total,
      final List<dynamic>? rows,
      required final List<VideoItem>? data,
      required final int code,
      required final String msg}) = _$VideoListResponseImpl;

  factory _VideoListResponse.fromJson(Map<String, dynamic> json) =
      _$VideoListResponseImpl.fromJson;

  @override
  int get total;
  @override
  List<dynamic>? get rows;
  @override
  List<VideoItem>? get data;
  @override
  int get code;
  @override
  String get msg;

  /// Create a copy of VideoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoListResponseImplCopyWith<_$VideoListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoItem _$VideoItemFromJson(Map<String, dynamic> json) {
  return _VideoItem.fromJson(json);
}

/// @nodoc
mixin _$VideoItem {
  String? get createBy => throw _privateConstructorUsedError;
  String get createTime => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  String get videoId => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  String get zhSrt => throw _privateConstructorUsedError;
  String get imgUrl => throw _privateConstructorUsedError;

  /// Serializes this VideoItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoItemCopyWith<VideoItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoItemCopyWith<$Res> {
  factory $VideoItemCopyWith(VideoItem value, $Res Function(VideoItem) then) =
      _$VideoItemCopyWithImpl<$Res, VideoItem>;
  @useResult
  $Res call(
      {String? createBy,
      String createTime,
      String id,
      String? userId,
      String status,
      String? title,
      String? videoUrl,
      String videoId,
      String? mediaUrl,
      String zhSrt,
      String imgUrl});
}

/// @nodoc
class _$VideoItemCopyWithImpl<$Res, $Val extends VideoItem>
    implements $VideoItemCopyWith<$Res> {
  _$VideoItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createBy = freezed,
    Object? createTime = null,
    Object? id = null,
    Object? userId = freezed,
    Object? status = null,
    Object? title = freezed,
    Object? videoUrl = freezed,
    Object? videoId = null,
    Object? mediaUrl = freezed,
    Object? zhSrt = null,
    Object? imgUrl = null,
  }) {
    return _then(_value.copyWith(
      createBy: freezed == createBy
          ? _value.createBy
          : createBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createTime: null == createTime
          ? _value.createTime
          : createTime // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      zhSrt: null == zhSrt
          ? _value.zhSrt
          : zhSrt // ignore: cast_nullable_to_non_nullable
              as String,
      imgUrl: null == imgUrl
          ? _value.imgUrl
          : imgUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoItemImplCopyWith<$Res>
    implements $VideoItemCopyWith<$Res> {
  factory _$$VideoItemImplCopyWith(
          _$VideoItemImpl value, $Res Function(_$VideoItemImpl) then) =
      __$$VideoItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? createBy,
      String createTime,
      String id,
      String? userId,
      String status,
      String? title,
      String? videoUrl,
      String videoId,
      String? mediaUrl,
      String zhSrt,
      String imgUrl});
}

/// @nodoc
class __$$VideoItemImplCopyWithImpl<$Res>
    extends _$VideoItemCopyWithImpl<$Res, _$VideoItemImpl>
    implements _$$VideoItemImplCopyWith<$Res> {
  __$$VideoItemImplCopyWithImpl(
      _$VideoItemImpl _value, $Res Function(_$VideoItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createBy = freezed,
    Object? createTime = null,
    Object? id = null,
    Object? userId = freezed,
    Object? status = null,
    Object? title = freezed,
    Object? videoUrl = freezed,
    Object? videoId = null,
    Object? mediaUrl = freezed,
    Object? zhSrt = null,
    Object? imgUrl = null,
  }) {
    return _then(_$VideoItemImpl(
      createBy: freezed == createBy
          ? _value.createBy
          : createBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createTime: null == createTime
          ? _value.createTime
          : createTime // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      zhSrt: null == zhSrt
          ? _value.zhSrt
          : zhSrt // ignore: cast_nullable_to_non_nullable
              as String,
      imgUrl: null == imgUrl
          ? _value.imgUrl
          : imgUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoItemImpl implements _VideoItem {
  const _$VideoItemImpl(
      {this.createBy,
      required this.createTime,
      required this.id,
      this.userId,
      required this.status,
      this.title,
      this.videoUrl,
      required this.videoId,
      this.mediaUrl,
      required this.zhSrt,
      required this.imgUrl});

  factory _$VideoItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoItemImplFromJson(json);

  @override
  final String? createBy;
  @override
  final String createTime;
  @override
  final String id;
  @override
  final String? userId;
  @override
  final String status;
  @override
  final String? title;
  @override
  final String? videoUrl;
  @override
  final String videoId;
  @override
  final String? mediaUrl;
  @override
  final String zhSrt;
  @override
  final String imgUrl;

  @override
  String toString() {
    return 'VideoItem(createBy: $createBy, createTime: $createTime, id: $id, userId: $userId, status: $status, title: $title, videoUrl: $videoUrl, videoId: $videoId, mediaUrl: $mediaUrl, zhSrt: $zhSrt, imgUrl: $imgUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoItemImpl &&
            (identical(other.createBy, createBy) ||
                other.createBy == createBy) &&
            (identical(other.createTime, createTime) ||
                other.createTime == createTime) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.zhSrt, zhSrt) || other.zhSrt == zhSrt) &&
            (identical(other.imgUrl, imgUrl) || other.imgUrl == imgUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, createBy, createTime, id, userId,
      status, title, videoUrl, videoId, mediaUrl, zhSrt, imgUrl);

  /// Create a copy of VideoItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoItemImplCopyWith<_$VideoItemImpl> get copyWith =>
      __$$VideoItemImplCopyWithImpl<_$VideoItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoItemImplToJson(
      this,
    );
  }
}

abstract class _VideoItem implements VideoItem {
  const factory _VideoItem(
      {final String? createBy,
      required final String createTime,
      required final String id,
      final String? userId,
      required final String status,
      final String? title,
      final String? videoUrl,
      required final String videoId,
      final String? mediaUrl,
      required final String zhSrt,
      required final String imgUrl}) = _$VideoItemImpl;

  factory _VideoItem.fromJson(Map<String, dynamic> json) =
      _$VideoItemImpl.fromJson;

  @override
  String? get createBy;
  @override
  String get createTime;
  @override
  String get id;
  @override
  String? get userId;
  @override
  String get status;
  @override
  String? get title;
  @override
  String? get videoUrl;
  @override
  String get videoId;
  @override
  String? get mediaUrl;
  @override
  String get zhSrt;
  @override
  String get imgUrl;

  /// Create a copy of VideoItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoItemImplCopyWith<_$VideoItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoDetailResponse _$VideoDetailResponseFromJson(Map<String, dynamic> json) {
  return _VideoDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$VideoDetailResponse {
  String get msg => throw _privateConstructorUsedError;
  int get code => throw _privateConstructorUsedError;
  VideoItem get data => throw _privateConstructorUsedError;

  /// Serializes this VideoDetailResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoDetailResponseCopyWith<VideoDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoDetailResponseCopyWith<$Res> {
  factory $VideoDetailResponseCopyWith(
          VideoDetailResponse value, $Res Function(VideoDetailResponse) then) =
      _$VideoDetailResponseCopyWithImpl<$Res, VideoDetailResponse>;
  @useResult
  $Res call({String msg, int code, VideoItem data});

  $VideoItemCopyWith<$Res> get data;
}

/// @nodoc
class _$VideoDetailResponseCopyWithImpl<$Res, $Val extends VideoDetailResponse>
    implements $VideoDetailResponseCopyWith<$Res> {
  _$VideoDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
    Object? code = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as VideoItem,
    ) as $Val);
  }

  /// Create a copy of VideoDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoItemCopyWith<$Res> get data {
    return $VideoItemCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoDetailResponseImplCopyWith<$Res>
    implements $VideoDetailResponseCopyWith<$Res> {
  factory _$$VideoDetailResponseImplCopyWith(_$VideoDetailResponseImpl value,
          $Res Function(_$VideoDetailResponseImpl) then) =
      __$$VideoDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String msg, int code, VideoItem data});

  @override
  $VideoItemCopyWith<$Res> get data;
}

/// @nodoc
class __$$VideoDetailResponseImplCopyWithImpl<$Res>
    extends _$VideoDetailResponseCopyWithImpl<$Res, _$VideoDetailResponseImpl>
    implements _$$VideoDetailResponseImplCopyWith<$Res> {
  __$$VideoDetailResponseImplCopyWithImpl(_$VideoDetailResponseImpl _value,
      $Res Function(_$VideoDetailResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
    Object? code = null,
    Object? data = null,
  }) {
    return _then(_$VideoDetailResponseImpl(
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as VideoItem,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoDetailResponseImpl implements _VideoDetailResponse {
  const _$VideoDetailResponseImpl(
      {required this.msg, required this.code, required this.data});

  factory _$VideoDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoDetailResponseImplFromJson(json);

  @override
  final String msg;
  @override
  final int code;
  @override
  final VideoItem data;

  @override
  String toString() {
    return 'VideoDetailResponse(msg: $msg, code: $code, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoDetailResponseImpl &&
            (identical(other.msg, msg) || other.msg == msg) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, msg, code, data);

  /// Create a copy of VideoDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoDetailResponseImplCopyWith<_$VideoDetailResponseImpl> get copyWith =>
      __$$VideoDetailResponseImplCopyWithImpl<_$VideoDetailResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoDetailResponseImplToJson(
      this,
    );
  }
}

abstract class _VideoDetailResponse implements VideoDetailResponse {
  const factory _VideoDetailResponse(
      {required final String msg,
      required final int code,
      required final VideoItem data}) = _$VideoDetailResponseImpl;

  factory _VideoDetailResponse.fromJson(Map<String, dynamic> json) =
      _$VideoDetailResponseImpl.fromJson;

  @override
  String get msg;
  @override
  int get code;
  @override
  VideoItem get data;

  /// Create a copy of VideoDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoDetailResponseImplCopyWith<_$VideoDetailResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoStatusRequest _$VideoStatusRequestFromJson(Map<String, dynamic> json) {
  return _VideoStatusRequest.fromJson(json);
}

/// @nodoc
mixin _$VideoStatusRequest {
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this VideoStatusRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoStatusRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoStatusRequestCopyWith<VideoStatusRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoStatusRequestCopyWith<$Res> {
  factory $VideoStatusRequestCopyWith(
          VideoStatusRequest value, $Res Function(VideoStatusRequest) then) =
      _$VideoStatusRequestCopyWithImpl<$Res, VideoStatusRequest>;
  @useResult
  $Res call({String id, String status});
}

/// @nodoc
class _$VideoStatusRequestCopyWithImpl<$Res, $Val extends VideoStatusRequest>
    implements $VideoStatusRequestCopyWith<$Res> {
  _$VideoStatusRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoStatusRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoStatusRequestImplCopyWith<$Res>
    implements $VideoStatusRequestCopyWith<$Res> {
  factory _$$VideoStatusRequestImplCopyWith(_$VideoStatusRequestImpl value,
          $Res Function(_$VideoStatusRequestImpl) then) =
      __$$VideoStatusRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String status});
}

/// @nodoc
class __$$VideoStatusRequestImplCopyWithImpl<$Res>
    extends _$VideoStatusRequestCopyWithImpl<$Res, _$VideoStatusRequestImpl>
    implements _$$VideoStatusRequestImplCopyWith<$Res> {
  __$$VideoStatusRequestImplCopyWithImpl(_$VideoStatusRequestImpl _value,
      $Res Function(_$VideoStatusRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoStatusRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
  }) {
    return _then(_$VideoStatusRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoStatusRequestImpl implements _VideoStatusRequest {
  const _$VideoStatusRequestImpl({required this.id, required this.status});

  factory _$VideoStatusRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoStatusRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String status;

  @override
  String toString() {
    return 'VideoStatusRequest(id: $id, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoStatusRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status);

  /// Create a copy of VideoStatusRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoStatusRequestImplCopyWith<_$VideoStatusRequestImpl> get copyWith =>
      __$$VideoStatusRequestImplCopyWithImpl<_$VideoStatusRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoStatusRequestImplToJson(
      this,
    );
  }
}

abstract class _VideoStatusRequest implements VideoStatusRequest {
  const factory _VideoStatusRequest(
      {required final String id,
      required final String status}) = _$VideoStatusRequestImpl;

  factory _VideoStatusRequest.fromJson(Map<String, dynamic> json) =
      _$VideoStatusRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get status;

  /// Create a copy of VideoStatusRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoStatusRequestImplCopyWith<_$VideoStatusRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoStatusResponse _$VideoStatusResponseFromJson(Map<String, dynamic> json) {
  return _VideoStatusResponse.fromJson(json);
}

/// @nodoc
mixin _$VideoStatusResponse {
  String get msg => throw _privateConstructorUsedError;
  int get code => throw _privateConstructorUsedError;

  /// Serializes this VideoStatusResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoStatusResponseCopyWith<VideoStatusResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoStatusResponseCopyWith<$Res> {
  factory $VideoStatusResponseCopyWith(
          VideoStatusResponse value, $Res Function(VideoStatusResponse) then) =
      _$VideoStatusResponseCopyWithImpl<$Res, VideoStatusResponse>;
  @useResult
  $Res call({String msg, int code});
}

/// @nodoc
class _$VideoStatusResponseCopyWithImpl<$Res, $Val extends VideoStatusResponse>
    implements $VideoStatusResponseCopyWith<$Res> {
  _$VideoStatusResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoStatusResponseImplCopyWith<$Res>
    implements $VideoStatusResponseCopyWith<$Res> {
  factory _$$VideoStatusResponseImplCopyWith(_$VideoStatusResponseImpl value,
          $Res Function(_$VideoStatusResponseImpl) then) =
      __$$VideoStatusResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String msg, int code});
}

/// @nodoc
class __$$VideoStatusResponseImplCopyWithImpl<$Res>
    extends _$VideoStatusResponseCopyWithImpl<$Res, _$VideoStatusResponseImpl>
    implements _$$VideoStatusResponseImplCopyWith<$Res> {
  __$$VideoStatusResponseImplCopyWithImpl(_$VideoStatusResponseImpl _value,
      $Res Function(_$VideoStatusResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
    Object? code = null,
  }) {
    return _then(_$VideoStatusResponseImpl(
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoStatusResponseImpl implements _VideoStatusResponse {
  const _$VideoStatusResponseImpl({required this.msg, required this.code});

  factory _$VideoStatusResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoStatusResponseImplFromJson(json);

  @override
  final String msg;
  @override
  final int code;

  @override
  String toString() {
    return 'VideoStatusResponse(msg: $msg, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoStatusResponseImpl &&
            (identical(other.msg, msg) || other.msg == msg) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, msg, code);

  /// Create a copy of VideoStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoStatusResponseImplCopyWith<_$VideoStatusResponseImpl> get copyWith =>
      __$$VideoStatusResponseImplCopyWithImpl<_$VideoStatusResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoStatusResponseImplToJson(
      this,
    );
  }
}

abstract class _VideoStatusResponse implements VideoStatusResponse {
  const factory _VideoStatusResponse(
      {required final String msg,
      required final int code}) = _$VideoStatusResponseImpl;

  factory _VideoStatusResponse.fromJson(Map<String, dynamic> json) =
      _$VideoStatusResponseImpl.fromJson;

  @override
  String get msg;
  @override
  int get code;

  /// Create a copy of VideoStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoStatusResponseImplCopyWith<_$VideoStatusResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
