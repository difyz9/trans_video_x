import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_cors_headers/shelf_cors_headers.dart'; // Added import for CORS
import 'package:trans_video_x/models/add_url_model.dart'; // Import UrlVo class
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trans_video_x/core/constants/app_constants.dart';


class ApiService {


  Future<void> startServer() async {



    // Use any available host or container IP (usually `0.0.0.0`).
    final ip = InternetAddress.anyIPv4;

    // Configure routes.
    final router = shelf_router.Router()..post('/media/video/save-url', _postHandler);

    // Configure a pipeline that logs requests.
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsHeaders()) // Added CORS middleware
        .addHandler(router);

    // For running in containers, we respect the PORT environment variable.
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final server = await shelf_io.serve(handler, ip, port);

    print('Shelf server listening on port ${server.port}');
  }

  Future<Response> _postHandler(Request request) async {
    try {
      final requestBody = await request.readAsString();
      print('Received POST request with body: $requestBody');

      // Parse JSON and create UrlVo object
      final Map<String, dynamic> jsonData = jsonDecode(requestBody);
      final urlVo = AddUrlModel.fromJson(jsonData);
      
      print('Processed URL: ${urlVo.url}');
      
      // 存储到Hive
      final box = await Hive.openBox<AddUrlModel>(AppConstants.addUrlModelBoxName);
      await box.add(urlVo);
      
      print('Saved URL to Hive with ID: ${urlVo.id}');
      
      return Response.ok(json.encode({
        'success': true,
        'message': 'Received and processed URL: ${urlVo.url}',
        'id': urlVo.id,
        'code':200,
      }));
    } catch (e, s) {
      print('Error handling POST request: $e\n$s');
      return Response.internalServerError(body: 'Error processing request: $e');
    }
  }
}
