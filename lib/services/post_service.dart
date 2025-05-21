
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:trans_video_x/models/task_model.dart'; // Assuming TaskModel is here
import 'package:json_annotation/json_annotation.dart';

part 'post_service.g.dart'; // Ensure this is generated




@JsonSerializable()
class ApiResponseModel {
  @JsonKey(name: 'msg')
  final String message;
  final int code;

  ApiResponseModel({required this.message, required this.code});

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseModelToJson(this);
}

@RestApi(baseUrl: "http://127.0.0.1:8081") // Replace with your actual base URL
abstract class PostService {
  factory PostService(Dio dio, {String baseUrl}) = _PostService;

  @POST("/media/task/add") // Adjust endpoint as needed
  Future<ApiResponseModel> postTask(@Body() TaskModel task);

  // Add other API calls here if any
}
