
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:trans_video_x/models/task_model.dart'; // Assuming TaskModel is here

part 'post_service.g.dart'; // Ensure this is generated

@RestApi(baseUrl: "YOUR_BASE_API_URL") // Replace with your actual base URL
abstract class PostService {
  factory PostService(Dio dio, {String baseUrl}) = _PostService;

  @POST("/tasks") // Adjust endpoint as needed
  Future<void> postTask(@Body() TaskModel task);

  // Add other API calls here if any
}
