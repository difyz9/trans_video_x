import 'package:flutter/material.dart';
import 'package:trans_video_x/core/constants/app_config.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_video_status.dart';

class ModalDownload extends StatelessWidget {
  const ModalDownload({super.key, required this.video});

  final YtDlpVideoStatus video;

  String get texto {
    switch (video.status) {
      case VideoStatus.carregando:
        return 'Carregando...';
      case VideoStatus.video:
        return 'Baixando vídeo...';
      case VideoStatus.audio:
        return 'Baixando áudio...';
      case VideoStatus.videoAudio:
        return 'Baixando arquivo...';
      case VideoStatus.combinando:
        return 'Combinando vídeo e áudio...';
      case VideoStatus.convertendo:
        return 'Convertendo...';
    }
  }

  bool get mostrarBarra {
    return video.status != VideoStatus.carregando &&
        video.status != VideoStatus.combinando &&
        video.status != VideoStatus.convertendo;
  }

  String get progresso {
    return '${video.progresso.toStringAsFixed(2)}%';
  }

  Color barraCor(BuildContext context) {
    return AppConfig.instance.modoEscuro.value
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              texto,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            if (mostrarBarra) ...[
              const SizedBox(height: 16),
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: LinearProgressIndicator(color: barraCor(context), minHeight: 8, value: video.progresso / 100)),
              const SizedBox(height: 8),
              Text(progresso),
            ]
          ],
        ),
      ),
    );
  }
}
