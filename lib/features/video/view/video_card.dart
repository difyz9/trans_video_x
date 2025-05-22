import 'package:flutter/material.dart';

/// 视频数据模型
class Video {
  final String title;
  final String thumbnailUrl;
  final String channelName;
  final int views;
  final Duration duration;

  Video({
    required this.title,
    required this.thumbnailUrl,
    required this.channelName,
    required this.views,
    required this.duration,
  });
}


/// 视频卡片组件
class VideoCard extends StatelessWidget {
  final Video video;

  const VideoCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频缩略图
          Image.network(
            video.thumbnailUrl,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
          // 视频标题
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              video.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 频道名称和观看次数
        
          // 视频时长
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '时长: ${video.duration.inMinutes}分钟',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
