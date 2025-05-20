import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:trans_video_x/core/constants/app_config.dart';
import 'package:trans_video_x/features/task/model/jexception.dart';

import 'package:trans_video_x/features/task/model/yt_dlp_models.dart';
import 'package:trans_video_x/features/task/utils/ffmpeg_wrapper.dart';
import 'package:path_provider/path_provider.dart';

/// YtDlpWrapper 类封装了与 yt-dlp 可执行文件的交互逻辑。
/// 它提供了下载视频、列出可用格式以及管理 yt-dlp 可执行文件本身的方法。
class YtDlpWrapper {
  // yt-dlp 可执行文件的路径。如果为 null，则会在首次需要时尝试查找或提取。
  String? ytDlp;

  // StreamController 用于广播视频下载的状态和进度。
  // 使用 broadcast() 允许多个监听器。
  final _statusProgressoController = StreamController<YtDlpVideoStatus>.broadcast();

  // 公开的 Stream，外部可以订阅以接收下载状态和进度的更新。
  Stream<YtDlpVideoStatus> get statusProgresso => _statusProgressoController.stream;

  /// 构造函数
  YtDlpWrapper();

  /// 查找或提取 yt-dlp 可执行文件。
  /// 首先尝试在系统 PATH 中查找 'yt-dlp'。
  /// 如果未找到，则从应用的 assets 中提取捆绑的 yt-dlp 可执行文件到临时目录。
  /// 在 Linux 和 macOS 上，会给提取的文件添加执行权限。
  /// 最后，会尝试更新提取的 yt-dlp 到最新版本。
  Future<void> _extrairYtDlp() async {
    // 如果 ytDlp 路径已存在，则直接返回
    if (ytDlp != null) return;
    try {
      // 尝试运行系统中已安装的 yt-dlp 来检查其是否存在
      final cmdYtDlp = await Process.run('yt-dlp', ['--version']);
      // 如果命令执行成功 (exitCode == 0)，则表示系统中已安装 yt-dlp
      if (cmdYtDlp.exitCode != 0) throw YtDlpException(cmdYtDlp.stderr);
      // 将 ytDlp 设置为 'yt-dlp'，表示使用系统命令
      ytDlp = 'yt-dlp';
      return;
    } catch (e) {
      // 如果在调试模式下，打印查找系统 yt-dlp 时的错误信息
      if (kDebugMode) print("erro tentando encontrar yt-dlp: $e");
    }

    // 如果系统中没有安装 yt-dlp，则尝试从应用内置的 assets 中提取
    try {
      // 获取应用的临时目录路径
      final Directory tempDir = await getTemporaryDirectory();
      // 根据不同平台确定 yt-dlp 可执行文件的名称
      String nome = Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp';

      // 构建 yt-dlp 可执行文件在临时目录中的完整路径
      final String caminhoExecutavel = '${tempDir.path}${Platform.isWindows ? '\\' : '/'}$nome';
      // 设置 ytDlp 为提取的路径
      ytDlp = caminhoExecutavel;

      // 创建文件对象
      final File arquivo = File(caminhoExecutavel);
      // 检查文件是否已存在，如果不存在则从 assets 中提取
      if (!arquivo.existsSync()) {
        // 从 assets 加载 yt-dlp 可执行文件的字节数据
        final ByteData data = await rootBundle.load('assets/yt-dlp/$nome');
        // 将字节数据写入到临时目录的文件中
        await arquivo.writeAsBytes(data.buffer.asUint8List());
        // 如果是 Linux 或 macOS 系统，则为文件添加执行权限
        if (Platform.isLinux || Platform.isMacOS) {
          await Process.run('chmod', ['+x', caminhoExecutavel]);
        }
        // 尝试使用提取的 yt-dlp 更新自身到最新版本
        await Process.run(caminhoExecutavel, ['-U']);
      }
    } catch (e) {
      // 如果提取过程中发生错误，则抛出 StateError
      throw StateError('Erro ao extrair yt-dlp: $e');
    }
  }

  List<String> _getCookieArguments(YtDlpParams parametros) {
    final List<String> cookieArgs = [];
    if (parametros.cookiesFromFile != null && parametros.cookiesFromFile!.isNotEmpty) {
      cookieArgs.addAll(['--cookies', parametros.cookiesFromFile!]);
    }
    // Future: Could add --cookies-from-browser logic here if needed
    // else if (parametros.cookiesFromBrowser != null && parametros.cookiesFromBrowser!.isNotEmpty) {
    //   cookieArgs.addAll(['--cookies-from-browser', parametros.cookiesFromBrowser!]);
    // }
    return cookieArgs;
  }

  /// 下载指定 URL 的视频。
  ///
  /// [url] 是要下载的视频的 URL。
  /// [parametros] 是包含下载选项的 YtDlpParams 对象，例如格式、质量等。
  ///
  /// 此方法会处理 yt-dlp 进程的输出，解析进度信息，并在下载完成后返回一个 YtDlpResponse。
  /// 它还会处理一些特殊情况，例如文件已存在或需要将视频转换为 H.26x 格式。
  Future<YtDlpResponse> downloadVideo(String url, String outputDir, {required YtDlpParams parametros}) async {
    try {
      // 确保 yt-dlp 可执行文件已准备好
      await _extrairYtDlp();

      // 从应用配置中获取下载目标路径
      // String caminho = AppConfig.instance.destino;

      print("下载路径: $outputDir"); // 调试时打印下载路径

      // 定义 yt-dlp 进度输出的格式模板
      // %(info.{vcodec,acodec})j: 输出视频和音频编解码器的 JSON 信息
      // %(progress.{status,downloaded_bytes,total_bytes})j: 输出下载状态、已下载字节数和总字节数的 JSON 信息
      String formatacaoSaida =
          '{"info":%(info.{vcodec,acodec})j,"progress":%(progress.{status,downloaded_bytes,total_bytes})j}';
      // 定义 yt-dlp 的基本参数
      List<String> definicoes = [
        '-P', // 指定下载路径
        outputDir,
        '--newline', // 每个 JSON 对象后输出换行符，便于解析
        '--progress-template', // 指定进度输出模板
        formatacaoSaida,
        '-o', // 指定输出文件名模板
        '%(id)s.%(ext)s', // 文件名格式为 "视频标题.扩展名"
        url // 要下载的视频 URL
      ];

      // Add cookies argument using the helper method
      definicoes.addAll(_getCookieArguments(parametros));

      if (kDebugMode) print('definicoes: $definicoes'); // 调试时打印基本参数

      AppConfig.instance.setH26x(true);

      // 合并用户指定的参数、配置参数和基本定义参数
      List<String> args = [...parametros.configuracoes, ...parametros.argumentos, ...definicoes];

      // 如果在调试模式下，打印完整的 yt-dlp 命令
      if (kDebugMode) print([ytDlp, ...args].join(' '));
      // 启动 yt-dlp 进程
      var resultado = await Process.start(ytDlp!, args);

      bool existe = false; // 标记文件是否已存在
      bool h26x = false; // 标记视频是否已经是 H.264/H.265 (AVC/HEVC) 格式

      // 监听 yt-dlp 进程的标准输出 (stdout)
      resultado.stdout.listen((data) {
        // 将接收到的字节数据转换为字符串，并按换行符分割成多行
        final linhas = String.fromCharCodes(data).split('\n');
        for (final String linha in linhas) {
          // 检查输出行是否包含 "has already been downloaded"，表示文件已存在
          if (linha.contains('has already been downloaded')) {
            existe = true; // 设置文件已存在标志
            return; // 不再处理后续输出
          }
          // 检查输出行是否以 '{' 开头，这通常是 JSON 格式的进度信息
          if (linha.startsWith('{')) {
            dynamic json = jsonDecode(linha); // 解析 JSON 字符串
            dynamic jsonInfo = json['info']; // 获取视频信息部分

            // 获取视频编解码器 (vcodec) 和音频编解码器 (acodec)
            String? vcodec = jsonInfo['vcodec'] as String?;
            String? acodec = jsonInfo['acodec'] as String?;
            // 检查视频编解码器是否为 H.264 (avc) 或 H.265 (hevc)
            if (vcodec?.contains(RegExp(r'((?:he|a)vc)')) ?? false) h26x = true;

            // 根据视频和音频编解码器确定当前的下载状态
            VideoStatus status = YtDlpVideoStatus.getFormato(vcodec, acodec);

            // 解析下载进度信息
            dynamic jsonProgress = json['progress'];
            int baixado = (jsonProgress['downloaded_bytes'] as int?) ?? 0; // 已下载字节数，默认为 0
            int total = (jsonProgress['total_bytes'] as int?) ?? 1; // 总字节数，默认为 1 (避免除以零)
            double progresso = (baixado / total) * 100; // 计算下载百分比

            // 将更新后的下载状态和进度添加到 StreamController
            _statusProgressoController.add(YtDlpVideoStatus(status, progresso));
          }
          // 检查输出行是否以 '[Merger]' 开头，表示正在合并音视频文件
          if (linha.startsWith('[Merger]')) {
            _statusProgressoController.add(YtDlpVideoStatus(VideoStatus.combinando, 0)); // 更新状态为合并中
          }
          // 检查输出行是否以 '[ExtractAudio]' 开头，表示正在提取音频（通常用于转换）
          if (linha.startsWith('[ExtractAudio]')) {
            _statusProgressoController.add(YtDlpVideoStatus(VideoStatus.convertendo, 0)); // 更新状态为转换中
          }
        }
      });

      // 用于存储 yt-dlp 进程的标准错误输出 (stderr)
      final stderrBuffer = StringBuffer();
      // 监听 stderr
      resultado.stderr.listen(
        (data) {
          stderrBuffer.write(String.fromCharCodes(data)); // 将错误信息追加到 buffer
        },
      );

      // 等待 yt-dlp 进程执行完成并获取退出码
      int exitCode = await resultado.exitCode;
      // 如果退出码不为 0，表示下载过程中发生错误
      if (exitCode != 0) throw YtDlpException('Erro ao baixar o arquivo: $stderrBuffer');
      // 如果文件已存在 (通过 stdout 中的信息判断)
      if (existe) throw AlreadyExistsException();

      // 如果用户要求转换为 H.26x 格式，并且当前视频不是 H.26x 格式
      if (parametros.converterH26x && !h26x) {
        _statusProgressoController.add(YtDlpVideoStatus(VideoStatus.convertendo, 0)); // 更新状态为转换中
        // 获取下载文件的最终名称
        String titulo = await _getNomeArquivo(url, parametros.argumentos);
        // 使用 FFmpegWrapper 将视频转换为 H.264 格式
        FFmpegWrapper.converterParaH264(titulo, outputDir);
      }
    } on AlreadyExistsException catch (e) {
      // 捕获文件已存在的特定异常
      return YtDlpResponse(status: YtDlpStatus.info, message: e.toString()); // 返回包含提示信息的响应
    } catch (e) {
      // 捕获其他所有下载过程中的异常
      return YtDlpResponse(status: YtDlpStatus.error, message: e.toString()); // 返回包含错误信息的响应
    }
    // 如果一切顺利，返回成功的响应
    return YtDlpResponse(status: YtDlpStatus.success, message: 'Arquivo baixado com sucesso! 😄');
  }

  /// 使用 yt-dlp 获取指定 URL 和参数下最终下载文件的名称。
  ///
  /// [url] 是视频的 URL。
  /// [argumentos] 是传递给 yt-dlp 的参数列表，用于确定文件名（例如格式选择）。
  ///
  /// 此方法调用 `yt-dlp --get-filename` 来获取预期的文件名。
  Future<String> _getNomeArquivo(String url, List<String> argumentos) async {
    try {
      // 构建获取文件名的参数列表
      List<String> args = [
        ...argumentos, // 用户指定的参数，如格式选择
        '--get-filename', // yt-dlp 命令，用于获取文件名而不是下载
        '-o', // 指定输出文件名模板
        '%(title)s.%(ext)s', // 文件名格式
        url, // 视频 URL
      ];
      // 执行 yt-dlp 命令
      var resultado = await Process.run(ytDlp!, args);
      // 从标准输出中获取文件名
      String titulo = resultado.stdout;
      // 返回去除首尾空格的文件名
      return titulo.trim();
    } catch (e) {
      // 如果获取文件名失败，则抛出异常
      throw YtDlpException('Erro ao obter o nome do arquivo: $e');
    }
  }

  /// 列出指定 URL 视频的可用下载选项 (格式、分辨率等)。
  ///
  /// [url] 是要查询的视频的 URL。
  ///
  /// 此方法调用 `yt-dlp -O` 来获取视频的元数据和可用格式的 JSON 输出，
  /// 然后将其解析为一个 YtDlpVideo 对象。
  Future<YtDlpResponse> listDownloadOptions(String url) async {
    try {
      // 确保 yt-dlp 可执行文件已准备好
      await _extrairYtDlp();

      // 定义 yt-dlp 输出格式信息的模板
      // %(info.{...})j: 输出视频的基本信息 (id, title, thumbnail 等) 的 JSON
      // %(formats.:.{...})j: 输出每个可用格式的详细信息 (format_id, ext, resolution 等) 的 JSON
      String formatacaoSaida = [
        '{"info":%(.{id,title,thumbnail,channel,channel_url,timestamp,view_count})j',
        '"formatos":%(formats.:.{format_id,ext,resolution,height,filesize,filesize_approx,fps,acodec})j}'
      ].join(','); // 使用逗号连接，因为 yt-dlp 的 -O 选项期望一个逗号分隔的键列表

      print("formatacaoSaida: $formatacaoSaida"); // 调试时打印格式化字符串

      // 执行 yt-dlp 命令以获取选项信息
      // '-O' 选项用于打印信息到 stdout 而不是下载
      var resultado = await Process.run(ytDlp!, ['-O', formatacaoSaida, url]);

      // 检查命令是否成功执行
      if (resultado.exitCode != 0) {
        // 如果失败，抛出包含 stderr 错误信息的异常
        throw YtDlpException('Erro ao procurar opções: ${resultado.stderr}');
      }

      // 将 yt-dlp 的输出 (JSON 字符串) 转换为 YtDlpVideo 对象
      YtDlpVideo video = _transformarOpcoes(resultado.stdout, url);
      // 返回包含视频信息的成功响应
      return YtDlpResponse(status: YtDlpStatus.success, message: '${video.items.length} opções encontradas!', video: video);
    } catch (e) {
      // 捕获列出选项过程中的任何异常
      return YtDlpResponse(status: YtDlpStatus.error, message: e.toString()); // 返回错误响应
    }
  }

  /// 将 yt-dlp 输出的 JSON 字符串转换为 YtDlpVideo 对象。
  ///
  /// [output] 是 yt-dlp -O 命令的原始 JSON 输出。
  /// [url] 是原始视频的 URL，用于填充 YtDlpVideo 对象。
  YtDlpVideo _transformarOpcoes(String output, String url) {
    // 解析 JSON 字符串
    dynamic json = jsonDecode(output);

    print("json: $json"); // 调试时打印解析后的 JSON
    // 获取格式列表
    final Iterable formatos = json['formatos'];
    // 获取视频基本信息
    final info = json['info'];

    // 将每个格式的 JSON 对象转换为 YtDlpItem 对象
    List<YtDlpItem> items = formatos.map((j) => YtDlpItem.fromJson(j)).toList();
    // 移除非视频或音频格式 (例如 mhtml 格式，它是网页存档)
    YtDlpVideo video = YtDlpVideo.fromJson(info, items.where((j) => j.ext != 'mhtml').toList(), url);

    return video;
  }
}

/// Riverpod Provider，用于提供 YtDlpWrapper 的单例实例。
/// 这使得在 Flutter 应用的其他部分可以方便地访问 YtDlpWrapper 的功能。
final ytDlpWrapperProvider = Provider<YtDlpWrapper>((ref) {
  return YtDlpWrapper();
});