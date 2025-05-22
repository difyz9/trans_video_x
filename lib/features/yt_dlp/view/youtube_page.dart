import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:trans_video_x/core/constants/app_constants.dart' as constants;
import 'package:trans_video_x/features/task/model/yt_dlp_params.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_response.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_video.dart';
import 'package:trans_video_x/features/task/model/yt_dlp_video_status.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/youtube_modal_download.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/youtube_opcao_formato.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/youtube_table.dart';
import 'package:trans_video_x/features/task/utils/ffmpeg_wrapper.dart';
import 'package:trans_video_x/features/task/utils/yt_dlp_wrapper.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/modal_dependencias.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/youtube_url.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/tile_checkbox.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/youtube_opcao_download.dart';
import 'package:trans_video_x/features/yt_dlp/widgets/youtube_video_preview.dart';
import 'package:trans_video_x/core/constants/app_config.dart';
import 'package:skeletonizer/skeletonizer.dart';

// YoutubePage是一个有状态的小部件，用于显示YouTube下载器页面

@RoutePage()
class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key, required this.tabController});

  // TabController用于控制标签页的切换
  final TabController tabController;

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

// _YoutubePageState是YoutubePage的状态类
class _YoutubePageState extends State<YoutubePage> {
  // YtDlpWrapper的实例，用于与yt-dlp命令行工具交互
  YtDlpWrapper ytdlp = YtDlpWrapper();
  // 布尔值，指示是否已安装依赖项（ffmpeg和ffprobe）
  bool temDeps = false;
  // 字符串，存储用户输入的YouTube URL
  String youtubeUrl ='https://www.youtube.com/watch?v=36d_MJ5pBtc';
  // 字符串，存储用户选择的视频扩展名
  String? valorExtensao;
  // 字符串，存储用户选择的视频分辨率
  String? valorResolucao;
  // TextEditingController，用于控制扩展名下拉菜单的文本
  TextEditingController extController = TextEditingController();
  // TextEditingController，用于控制分辨率下拉菜单的文本
  TextEditingController resController = TextEditingController();
  // TextEditingController，用于控制转换格式输入框的文本
  TextEditingController formatoController = TextEditingController();
  // 布尔值，指示是否需要转换视频格式
  bool converter = false;
  // 布尔值，指示是否显示视频信息表格
  bool mostrarTabela = false;
  // 布尔值，指示当前是否正在加载数据
  bool carregando = false;
  // 布尔值，指示转换格式是否为空（错误状态）
  bool erroFormato = false;
  // YtDlpVideo对象，存储获取到的视频信息
  YtDlpVideo? video;
  // 字符串列表，存储可用的视频扩展名
  List<String> extensoes = [];
  // 字符串列表，存储可用的视频分辨率
  List<String> resolucoes = [];
  // 字符串，存储用户在表格中选择的视频ID
  String? idSelecionado;

  // getter，指示是否已准备好下载（视频信息已加载且未在加载中）
  bool get pronto => video != null && !carregando;

  @override
  void initState() {
    super.initState();
    // 初始化时检查依赖项
    verificarDependencias();
  }

  // 检查ffmpeg和ffprobe依赖项是否已安装
  void verificarDependencias() async {
    var (ffmpeg, ffprobe) = await FFmpegWrapper.verificarDependencias();
    temDeps = ffmpeg && ffprobe;
    // 如果依赖项未安装，则延迟1秒后显示对话框
    if (!temDeps) {
      Future.delayed(Duration(seconds: 1), () {
        _mostrarDialogoDeps(ffmpeg, ffprobe);
      });
    }
  }

  // 显示依赖项缺失的对话框
  void _mostrarDialogoDeps(bool ffmpeg, bool ffprobe) {
    if (!mounted) return; // 检查小部件是否仍在树中
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // ModalDependencias是一个自定义对话框，用于显示依赖项状态并提供跳转到配置页面的选项
        return ModalDependencias(
            ffmpeg: ffmpeg, ffprobe: ffprobe, redirecionar: () => widget.tabController.animateTo(1));
      },
    );
  }

  // 下载YouTube视频的方法
  void baixarYoutube(BuildContext context) async {
    // 如果启用了转换但未指定格式，则设置错误状态并返回
    if (converter && formatoController.text.isEmpty) {
      setState(() {
        erroFormato = true;
      });
      return;
    }

    // 打印调试信息
    print("idSelecionado: $idSelecionado");
    print("valorExtensao: $valorExtensao");
    print("formatoController.text: ${formatoController.text}");
    print("valorResolucao: $valorResolucao");

    // 创建YtDlpParams对象，封装下载参数
    YtDlpParams parametros = YtDlpParams(idSelecionado, valorExtensao, formatoController.text, valorResolucao);

    // 检查小部件是否仍在树中
    if (!mounted) return;
    // 显示下载进度对话框
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击外部关闭对话框
      builder: (BuildContext context) {
        // StreamBuilder用于监听下载进度并更新UI
        return StreamBuilder<YtDlpVideoStatus>(
          stream: ytdlp.statusProgresso, // 从YtDlpWrapper获取下载状态流
          builder: (context, snapshot) {
            // 如果没有数据，则显示默认的加载状态
            final x = snapshot.data ?? YtDlpVideoStatus(VideoStatus.carregando, 0);
            // ModalDownload是一个自定义对话框，用于显示下载进度
  
            return ModalDownload(video: x);
          },
        );
      },
    );

      String caminho = AppConfig.instance.destino;


    // 调用YtDlpWrapper的baixarVideo方法开始下载
    YtDlpResponse res = await ytdlp.downloadVideo(youtubeUrl,"", parametros: parametros);
    // 如果上下文仍然挂载（小部件未被销毁）
    if (context.mounted) {
      // 显示下载结果的Snackbar
      res.showSnackbar(context);
      // 关闭下载进度对话框
      Navigator.pop(context);
    }
  }

  // 列出YouTube视频的可用选项（格式、分辨率等）
  void listarYoutube() async {
    // 重置之前的选项
    resetarOpcoes();
    setState(() {
      video = null; // 清空之前的视频信息
      carregando = true; // 设置为加载状态
    });

    // 调用YtDlpWrapper的listarOpcoes方法获取视频信息
    YtDlpResponse res = await ytdlp.listDownloadOptions(youtubeUrl);
    if (!mounted) return; // 检查小部件是否仍在树中
    res.showSnackbar(context); // 显示获取结果的Snackbar

    setState(() {
      video = res.video; // 更新视频信息
      if (video == null) {
        carregando = false; // 如果没有获取到视频信息，则取消加载状态
        return;
      }
      // 获取所有可用的扩展名
      List<String> extList = video!.items.map((x) => x.ext).toSet().toList();
      // 如果存在纯音频选项，则在扩展名列表中添加“Melhor áudio”
      if (video!.items.any((y) => y.res == 'Somente áudio')) {
        extensoes.add('Melhor áudio');
      }
      extensoes.addAll(extList); // 添加其他扩展名
      filtrarResolucoes(valorResolucao); // 根据当前选择的扩展名筛选分辨率
      carregando = false; // 取消加载状态
    });
  }

  // 根据选择的扩展名筛选分辨率列表
  void filtrarResolucoes(String? ext) {
    if (ext == null) {
      // 如果没有选择扩展名，则显示所有分辨率
      resolucoes = video!.items.map((y) => y.res).toSet().toList();
    } else {
      // 否则，仅显示与所选扩展名匹配的分辨率
      resolucoes = video!.items.where((x) => x.ext == ext).map((y) => y.res).toSet().toList();
    }
  }

  // 当用户选择扩展名时调用
  void escolherExtensao(String? ext) {
    resolucoes.clear(); // 清空分辨率列表
    resController.text = constants.padrao; // 重置分辨率下拉菜单的文本
    valorResolucao = null; // 清空已选择的分辨率
    // 如果选择的是默认值，则valorExtensao为null，否则为选择的扩展名
    valorExtensao = ext == constants.padrao ? null : ext;
    setState(() {
      filtrarResolucoes(valorExtensao); // 根据新的扩展名筛选分辨率
    });
  }

  // 当用户选择分辨率时调用
  void escolherResolucao(String? res) {
    // 如果选择的是默认值，则valorResolucao为null，否则为选择的分辨率
    valorResolucao = res == constants.padrao ? null : res;
  }

  // 重置下载选项
  void resetarOpcoes({bool softReset = false}) {
    if (!mounted) return; // 检查小部件是否仍在树中
    setState(() {
      // 重置扩展名和分辨率下拉菜单的文本及已选值
      extController.text = constants.padrao;
      resController.text = constants.padrao;
      valorExtensao = null;
      valorResolucao = null;
      // 如果不是软重置（例如，输入新的URL时），则清空更多状态
      if (!softReset) {
        extensoes.clear();
        resolucoes.clear();
        formatoController.clear();
        converter = false;
        mostrarTabela = false;
        idSelecionado = null;
      }
    });
  }

  // 当YouTube URL输入框内容改变时调用
  void youtubeUrlOnChanged(String x) {
    if (video != null) video = null; // 如果已有视频信息，则清空
    youtubeUrl = x; // 更新YouTube URL
    resetarOpcoes(); // 重置下载选项
  }

  // 当“显示表格”复选框状态改变时调用
  void tabelaCheckboxOnChanged(bool? value) {
    setState(() {
      mostrarTabela = value!; // 更新显示表格的状态
    });
  }

  // 当“转换”复选框状态改变时调用
  void converterCheckboxOnChanged(bool? value) {
    setState(() {
      converter = value!; // 更新转换状态
      formatoController.clear(); // 清空转换格式输入框
    });
  }

  // 当在表格中选择或取消选择一个项目时调用
  void tableOnSelected(String? id) {
    setState(() {
      // 如果再次点击已选项，则取消选择，否则选择新项
      idSelecionado = id == idSelecionado ? null : id;
    });
    // 软重置选项，保留已有的扩展名和分辨率列表
    resetarOpcoes(softReset: true);
  }

  // 当转换格式输入框内容改变时调用（主要用于清除错误状态）
  void formatoOnSelected(_) {
    setState(() {
      erroFormato = false; // 清除格式错误状态
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          YoutubeUrlWidget(listarYoutube: listarYoutube, baixarYoutube: baixarYoutube, onChanged: youtubeUrlOnChanged),
          if (carregando || pronto) ...[
            const SizedBox(height: 20),
            Skeletonizer(enabled: carregando, child: VideoPreview(video: video)),
            const SizedBox(height: 5),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Skeletonizer(
                    enabled: carregando,
                    
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 20,
                              runSpacing: 10,
                              children: [
                                YoutubeOpcaoDownload(
                                    lista: extensoes,
                                    title: '扩展名',
                                    onSelected: escolherExtensao,
                                    controller: extController,
                                    enabled: idSelecionado == null),
                                YoutubeOpcaoDownload(
                                    lista: resolucoes,
                                    title: '分辨率',
                                    onSelected: escolherResolucao,
                                    controller: resController,
                                    enabled: idSelecionado == null),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TileCheckbox(
                                value: mostrarTabela,
                                enabled: (video?.items.length ?? 0) > 1,
                                onChanged: tabelaCheckboxOnChanged,
                                title: '显示详情',
                                subtitle: '显示可用的视频格式和分辨率'),
                            if (temDeps)
                              TileCheckbox(
                                  value: converter,
                                  enabled: (video?.items.length ?? 0) > 1,
                                  onChanged: converterCheckboxOnChanged,
                                  title: '转换',
                                  subtitle: '启用转换为其他格式'),
                            const SizedBox(height: 20),
                            Visibility(
                              visible: converter && pronto && temDeps,
                              child: YoutubeOpcaoFormato(
                                  controller: formatoController,
                                  enabled: converter,
                                  onSelected: formatoOnSelected,
                                  error: erroFormato),
                            ),
                          ],
                        ),
                      ),
                    
                  ),
                ),
                if (video != null && mostrarTabela && !carregando)
                  Expanded(
                      flex: 5,
                      child:
                          YoutubeTable(items: video!.items, idSelecionado: idSelecionado, onSelected: tableOnSelected))
              ],
            ),
          ],
        ],
      ),
    );
  }
}
