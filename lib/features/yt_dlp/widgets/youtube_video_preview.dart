import 'package:flutter/material.dart';
import 'package:trans_video_x/core/constants/app_config.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_video.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/skeleton_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPreview extends StatelessWidget {
  const VideoPreview({super.key, required this.video});

  final YtDlpVideo? video;

  YtDlpVideo get preview {
    if (video != null) return video!;
    return YtDlpVideo(
        id: '',
        title: BoneMock.words(5),
        url: '',
        thumbnail: '',
        channel: BoneMock.name,
        channelUrl: '',
        items: [],
        timestamp: 1255668923,
        viewCount: 100000);
  }

  Color canalCor(BuildContext context) {
    return AppConfig.instance.modoEscuro.value
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
              onTap: video == null ? null : () => launchUrl(Uri.parse(preview.url)),
              child: Skeleton.replace(
                  width: 384,
                  height: 216,
                  child: SkeletonNetworkImage(
                      url: preview.thumbnail,
                      bone: const Bone(width: 384, height: 216),
                      renderWidget: (child) => Container(
                            width: 384,
                            height: 216,
                            alignment: Alignment.center,
                            color: AppConfig.instance.modoEscuro.value
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.outlineVariant,
                            child: child,
                          )))),
        ),
        Flexible(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                  onTap: () => launchUrl(Uri.parse(preview.url)),
                  child: Text(preview.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => launchUrl(Uri.parse(preview.channelUrl)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: canalCor(context),
                      size: 24,
                    ),
                    Text(preview.channel, style: TextStyle(color: canalCor(context), fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text('${preview.numViews} visualizações', style: TextStyle(fontSize: 16)),
              Text(preview.timeAgo, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
