import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:trans_video_x/core/constants/app_config.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/tile_checkbox.dart';

class ConfigCard extends StatefulWidget {
  const ConfigCard({super.key});

  @override
  State<ConfigCard> createState() => _ConfigCardState();
}

class _ConfigCardState extends State<ConfigCard> {
  TextEditingController destinoController = TextEditingController(text: AppConfig.instance.destino);

  void onDestinoChange(String? value) {
    AppConfig.instance.setDestino(value ?? '');
  }

  void onPickerPress() async {
    String? pasta = await FilePicker.platform.getDirectoryPath();
    if (pasta != null) {
      destinoController.text = pasta;
      onDestinoChange(pasta);
    }
  }

  void onModoEscuroChanged(bool? value) {
    AppConfig.instance.setModoEscuro(value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Tooltip(
                      message: 'Escolher destino',
                      child: IconButton.outlined(
                        constraints: BoxConstraints(minWidth: 50),
                        icon: Icon(Icons.folder_copy, size: 24),
                        onPressed: onPickerPress,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: destinoController,
                        onChanged: onDestinoChange,
                        decoration: const InputDecoration(
                          labelText: "Endereço",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
                constraints: BoxConstraints.loose(Size(600, double.infinity)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Modo Escuro',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Switch(
                      thumbIcon: WidgetStateProperty.resolveWith<Icon>(
                        (states) {
                          bool selected = states.contains(WidgetState.selected);
                          return Icon(
                            selected ? Icons.dark_mode : Icons.light_mode,
                            color: selected ? Theme.of(context).colorScheme.primary : null,
                          );
                        },
                      ),
                      value: AppConfig.instance.modoEscuro.value,
                      onChanged: onModoEscuroChanged,
                    )
                  ],
                )),
            const SizedBox(height: 8),
            TileCheckbox(
                value: AppConfig.instance.mtime,
                onChanged: (bool? value) {
                  setState(() {
                    AppConfig.instance.setMtime(value ?? false);
                  });
                },
                width: 600,
                title: 'Habilitar --mtime',
                subtitle:
                    'Utiliza o cabeçalho "Modificado pela última vez" do YouTube para definir a data/hora que o arquivo foi modificado no sistema.'),
            TileCheckbox(
                value: AppConfig.instance.h26x,
                onChanged: (bool? value) {
                  setState(() {
                    AppConfig.instance.setH26x(value ?? false);
                  });
                },
                width: 600,
                title: 'Priorizar H264/H265',
                subtitle:
                    '尝试下载采用 H264/H265 编码的视频，否则应用程序会尝试将您的视频编码转换为 H264。'),
          ],
        ),
      ),
    );
  }
}
