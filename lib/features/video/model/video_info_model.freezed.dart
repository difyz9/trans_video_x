// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_info_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoInfo _$VideoInfoFromJson(Map<String, dynamic> json) {
  return _VideoInfo.fromJson(json);
}

/// @nodoc
mixin _$VideoInfo {
  int get code => throw _privateConstructorUsedError;
  VideoData get data => throw _privateConstructorUsedError;

  /// Serializes this VideoInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoInfoCopyWith<VideoInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoInfoCopyWith<$Res> {
  factory $VideoInfoCopyWith(VideoInfo value, $Res Function(VideoInfo) then) =
      _$VideoInfoCopyWithImpl<$Res, VideoInfo>;
  @useResult
  $Res call({int code, VideoData data});

  $VideoDataCopyWith<$Res> get data;
}

/// @nodoc
class _$VideoInfoCopyWithImpl<$Res, $Val extends VideoInfo>
    implements $VideoInfoCopyWith<$Res> {
  _$VideoInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as VideoData,
    ) as $Val);
  }

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoDataCopyWith<$Res> get data {
    return $VideoDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoInfoImplCopyWith<$Res>
    implements $VideoInfoCopyWith<$Res> {
  factory _$$VideoInfoImplCopyWith(
          _$VideoInfoImpl value, $Res Function(_$VideoInfoImpl) then) =
      __$$VideoInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int code, VideoData data});

  @override
  $VideoDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$VideoInfoImplCopyWithImpl<$Res>
    extends _$VideoInfoCopyWithImpl<$Res, _$VideoInfoImpl>
    implements _$$VideoInfoImplCopyWith<$Res> {
  __$$VideoInfoImplCopyWithImpl(
      _$VideoInfoImpl _value, $Res Function(_$VideoInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? data = null,
  }) {
    return _then(_$VideoInfoImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as VideoData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoInfoImpl with DiagnosticableTreeMixin implements _VideoInfo {
  const _$VideoInfoImpl({required this.code, required this.data});

  factory _$VideoInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoInfoImplFromJson(json);

  @override
  final int code;
  @override
  final VideoData data;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'VideoInfo(code: $code, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'VideoInfo'))
      ..add(DiagnosticsProperty('code', code))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, data);

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoInfoImplCopyWith<_$VideoInfoImpl> get copyWith =>
      __$$VideoInfoImplCopyWithImpl<_$VideoInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoInfoImplToJson(
      this,
    );
  }
}

abstract class _VideoInfo implements VideoInfo {
  const factory _VideoInfo(
      {required final int code,
      required final VideoData data}) = _$VideoInfoImpl;

  factory _VideoInfo.fromJson(Map<String, dynamic> json) =
      _$VideoInfoImpl.fromJson;

  @override
  int get code;
  @override
  VideoData get data;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoInfoImplCopyWith<_$VideoInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoData _$VideoDataFromJson(Map<String, dynamic> json) {
  return _VideoData.fromJson(json);
}

/// @nodoc
mixin _$VideoData {
  String get title => throw _privateConstructorUsedError;
  String get videoUrl => throw _privateConstructorUsedError;
  String get videoId => throw _privateConstructorUsedError;
  String get srtUrl => throw _privateConstructorUsedError;
  String get imgUrl => throw _privateConstructorUsedError;

  /// Serializes this VideoData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoDataCopyWith<VideoData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoDataCopyWith<$Res> {
  factory $VideoDataCopyWith(VideoData value, $Res Function(VideoData) then) =
      _$VideoDataCopyWithImpl<$Res, VideoData>;
  @useResult
  $Res call(
      {String title,
      String videoUrl,
      String videoId,
      String srtUrl,
      String imgUrl});
}

/// @nodoc
class _$VideoDataCopyWithImpl<$Res, $Val extends VideoData>
    implements $VideoDataCopyWith<$Res> {
  _$VideoDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? videoUrl = null,
    Object? videoId = null,
    Object? srtUrl = null,
    Object? imgUrl = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      srtUrl: null == srtUrl
          ? _value.srtUrl
          : srtUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imgUrl: null == imgUrl
          ? _value.imgUrl
          : imgUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoDataImplCopyWith<$Res>
    implements $VideoDataCopyWith<$Res> {
  factory _$$VideoDataImplCopyWith(
          _$VideoDataImpl value, $Res Function(_$VideoDataImpl) then) =
      __$$VideoDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String videoUrl,
      String videoId,
      String srtUrl,
      String imgUrl});
}

/// @nodoc
class __$$VideoDataImplCopyWithImpl<$Res>
    extends _$VideoDataCopyWithImpl<$Res, _$VideoDataImpl>
    implements _$$VideoDataImplCopyWith<$Res> {
  __$$VideoDataImplCopyWithImpl(
      _$VideoDataImpl _value, $Res Function(_$VideoDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? videoUrl = null,
    Object? videoId = null,
    Object? srtUrl = null,
    Object? imgUrl = null,
  }) {
    return _then(_$VideoDataImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      videoId: null == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String,
      srtUrl: null == srtUrl
          ? _value.srtUrl
          : srtUrl // ignore: cast_nullable_to_non_nullable
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
class _$VideoDataImpl with DiagnosticableTreeMixin implements _VideoData {
  const _$VideoDataImpl(
      {required this.title,
      required this.videoUrl,
      required this.videoId,
      required this.srtUrl,
      required this.imgUrl});

  factory _$VideoDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoDataImplFromJson(json);

  @override
  final String title;
  @override
  final String videoUrl;
  @override
  final String videoId;
  @override
  final String srtUrl;
  @override
  final String imgUrl;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'VideoData(title: $title, videoUrl: $videoUrl, videoId: $videoId, srtUrl: $srtUrl, imgUrl: $imgUrl)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'VideoData'))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('videoUrl', videoUrl))
      ..add(DiagnosticsProperty('videoId', videoId))
      ..add(DiagnosticsProperty('srtUrl', srtUrl))
      ..add(DiagnosticsProperty('imgUrl', imgUrl));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.srtUrl, srtUrl) || other.srtUrl == srtUrl) &&
            (identical(other.imgUrl, imgUrl) || other.imgUrl == imgUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, title, videoUrl, videoId, srtUrl, imgUrl);

  /// Create a copy of VideoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoDataImplCopyWith<_$VideoDataImpl> get copyWith =>
      __$$VideoDataImplCopyWithImpl<_$VideoDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoDataImplToJson(
      this,
    );
  }
}

abstract class _VideoData implements VideoData {
  const factory _VideoData(
      {required final String title,
      required final String videoUrl,
      required final String videoId,
      required final String srtUrl,
      required final String imgUrl}) = _$VideoDataImpl;

  factory _VideoData.fromJson(Map<String, dynamic> json) =
      _$VideoDataImpl.fromJson;

  @override
  String get title;
  @override
  String get videoUrl;
  @override
  String get videoId;
  @override
  String get srtUrl;
  @override
  String get imgUrl;

  /// Create a copy of VideoData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoDataImplCopyWith<_$VideoDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubtitleModel _$SubtitleModelFromJson(Map<String, dynamic> json) {
  return _SubtitleModel.fromJson(json);
}

/// @nodoc
mixin _$SubtitleModel {
  int get id => throw _privateConstructorUsedError;
  String get start => throw _privateConstructorUsedError;
  String get end => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get audio => throw _privateConstructorUsedError;

  /// Serializes this SubtitleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubtitleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubtitleModelCopyWith<SubtitleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtitleModelCopyWith<$Res> {
  factory $SubtitleModelCopyWith(
          SubtitleModel value, $Res Function(SubtitleModel) then) =
      _$SubtitleModelCopyWithImpl<$Res, SubtitleModel>;
  @useResult
  $Res call({int id, String start, String end, String text, String audio});
}

/// @nodoc
class _$SubtitleModelCopyWithImpl<$Res, $Val extends SubtitleModel>
    implements $SubtitleModelCopyWith<$Res> {
  _$SubtitleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubtitleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? start = null,
    Object? end = null,
    Object? text = null,
    Object? audio = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubtitleModelImplCopyWith<$Res>
    implements $SubtitleModelCopyWith<$Res> {
  factory _$$SubtitleModelImplCopyWith(
          _$SubtitleModelImpl value, $Res Function(_$SubtitleModelImpl) then) =
      __$$SubtitleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String start, String end, String text, String audio});
}

/// @nodoc
class __$$SubtitleModelImplCopyWithImpl<$Res>
    extends _$SubtitleModelCopyWithImpl<$Res, _$SubtitleModelImpl>
    implements _$$SubtitleModelImplCopyWith<$Res> {
  __$$SubtitleModelImplCopyWithImpl(
      _$SubtitleModelImpl _value, $Res Function(_$SubtitleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubtitleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? start = null,
    Object? end = null,
    Object? text = null,
    Object? audio = null,
  }) {
    return _then(_$SubtitleModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtitleModelImpl
    with DiagnosticableTreeMixin
    implements _SubtitleModel {
  const _$SubtitleModelImpl(
      {required this.id,
      required this.start,
      required this.end,
      required this.text,
      required this.audio});

  factory _$SubtitleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtitleModelImplFromJson(json);

  @override
  final int id;
  @override
  final String start;
  @override
  final String end;
  @override
  final String text;
  @override
  final String audio;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SubtitleModel(id: $id, start: $start, end: $end, text: $text, audio: $audio)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SubtitleModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('start', start))
      ..add(DiagnosticsProperty('end', end))
      ..add(DiagnosticsProperty('text', text))
      ..add(DiagnosticsProperty('audio', audio));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.audio, audio) || other.audio == audio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, start, end, text, audio);

  /// Create a copy of SubtitleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtitleModelImplCopyWith<_$SubtitleModelImpl> get copyWith =>
      __$$SubtitleModelImplCopyWithImpl<_$SubtitleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubtitleModelImplToJson(
      this,
    );
  }
}

abstract class _SubtitleModel implements SubtitleModel {
  const factory _SubtitleModel(
      {required final int id,
      required final String start,
      required final String end,
      required final String text,
      required final String audio}) = _$SubtitleModelImpl;

  factory _SubtitleModel.fromJson(Map<String, dynamic> json) =
      _$SubtitleModelImpl.fromJson;

  @override
  int get id;
  @override
  String get start;
  @override
  String get end;
  @override
  String get text;
  @override
  String get audio;

  /// Create a copy of SubtitleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleModelImplCopyWith<_$SubtitleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoUpdate _$VideoUpdateFromJson(Map<String, dynamic> json) {
  return _VideoUpdate.fromJson(json);
}

/// @nodoc
mixin _$VideoUpdate {
  int get code => throw _privateConstructorUsedError;
  bool get data => throw _privateConstructorUsedError;

  /// Serializes this VideoUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoUpdateCopyWith<VideoUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoUpdateCopyWith<$Res> {
  factory $VideoUpdateCopyWith(
          VideoUpdate value, $Res Function(VideoUpdate) then) =
      _$VideoUpdateCopyWithImpl<$Res, VideoUpdate>;
  @useResult
  $Res call({int code, bool data});
}

/// @nodoc
class _$VideoUpdateCopyWithImpl<$Res, $Val extends VideoUpdate>
    implements $VideoUpdateCopyWith<$Res> {
  _$VideoUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoUpdateImplCopyWith<$Res>
    implements $VideoUpdateCopyWith<$Res> {
  factory _$$VideoUpdateImplCopyWith(
          _$VideoUpdateImpl value, $Res Function(_$VideoUpdateImpl) then) =
      __$$VideoUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int code, bool data});
}

/// @nodoc
class __$$VideoUpdateImplCopyWithImpl<$Res>
    extends _$VideoUpdateCopyWithImpl<$Res, _$VideoUpdateImpl>
    implements _$$VideoUpdateImplCopyWith<$Res> {
  __$$VideoUpdateImplCopyWithImpl(
      _$VideoUpdateImpl _value, $Res Function(_$VideoUpdateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? data = null,
  }) {
    return _then(_$VideoUpdateImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoUpdateImpl with DiagnosticableTreeMixin implements _VideoUpdate {
  const _$VideoUpdateImpl({required this.code, required this.data});

  factory _$VideoUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoUpdateImplFromJson(json);

  @override
  final int code;
  @override
  final bool data;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'VideoUpdate(code: $code, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'VideoUpdate'))
      ..add(DiagnosticsProperty('code', code))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoUpdateImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, data);

  /// Create a copy of VideoUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoUpdateImplCopyWith<_$VideoUpdateImpl> get copyWith =>
      __$$VideoUpdateImplCopyWithImpl<_$VideoUpdateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoUpdateImplToJson(
      this,
    );
  }
}

abstract class _VideoUpdate implements VideoUpdate {
  const factory _VideoUpdate(
      {required final int code, required final bool data}) = _$VideoUpdateImpl;

  factory _VideoUpdate.fromJson(Map<String, dynamic> json) =
      _$VideoUpdateImpl.fromJson;

  @override
  int get code;
  @override
  bool get data;

  /// Create a copy of VideoUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoUpdateImplCopyWith<_$VideoUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
