import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:dotted_border/dotted_border.dart';

// 回调函数类型定义，用于将文件信息传递给父组件
typedef OnFilesSelected = void Function(List<Map<String, dynamic>> files);

class FileDropWidget extends StatefulWidget {
  final OnFilesSelected? onFilesSelected; // 回调函数，用于将文件信息传递给父组件
  final double height; // 组件高度
  final double width; // 组件高度
  final List<String> allowedExtensions; // 允许的文件扩展名
  final int maxFileSizeInBytes; // 最大文件大小（字节）
  final List<Map<String, dynamic>>? initialFiles; // 初始文件列表

  const FileDropWidget({
    super.key, 
    this.onFilesSelected,
    this.height = 200, // 默认高度
    this.width = 200,
    this.allowedExtensions = const ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv'], // 默认允许的视频格式
    this.maxFileSizeInBytes = 2 * 1024 * 1024 * 1024, // 默认2GB
    this.initialFiles,
  });

  @override
  State<FileDropWidget> createState() => _FileDropWidgetState();
}

class _FileDropWidgetState extends State<FileDropWidget> {
  List<Map<String, dynamic>> _fileInfoList = []; // 存储文件信息
  bool _dragging = false; // 拖拽状态
  bool _isProcessing = false; // 处理状态

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null) {
      _fileInfoList = List.from(widget.initialFiles!);
    }
  }

  @override
  void didUpdateWidget(FileDropWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFiles != oldWidget.initialFiles) {
      setState(() {
        _fileInfoList = widget.initialFiles ?? [];
      });
    }
  }

  // 处理拖拽完成事件
Future<void> _onDrop(DropDoneDetails details) async {
  print("_onDrop");
  if (_isProcessing) return; // 如果正在处理，则忽略新的拖放

  setState(() {
    _isProcessing = true;
    _fileInfoList.clear();
  });

  List<Map<String, dynamic>> validFiles = [];
  List<String> errorMessages = [];

  try {
    for (final xFile in details.files) {
      final fileOrDir = File(xFile.path); // 可以是文件或文件夹
      print("Processing: ${fileOrDir.path}");

      // 检查是否存在
      // if (!await fileOrDir.exists()) continue;

      final stat = await fileOrDir.stat();
      if (stat.type == FileSystemEntityType.file) {
        // 处理单个文件
        final fileExtension = path.extension(fileOrDir.path).replaceFirst('.', '').toLowerCase();
        if (!widget.allowedExtensions.contains(fileExtension)) {
          errorMessages.add('${path.basename(fileOrDir.path)}: 不支持的文件类型，仅支持 ${widget.allowedExtensions.join(", ")}');
          continue;
        }

        final fileSize = await fileOrDir.length();
        if (fileSize > widget.maxFileSizeInBytes) {
          errorMessages.add('${path.basename(fileOrDir.path)}: 文件过大，最大支持 ${widget.maxFileSizeInBytes / (1024 * 1024 * 1024)} GB');
          continue;
        }

        final fileInfo = await _getFileInfo(fileOrDir);
        validFiles.add(fileInfo);
      } else if (stat.type == FileSystemEntityType.directory) {
        // 处理文件夹，递归获取所有文件
        final directory = Directory(xFile.path);
        await for (final entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final file = entity;
            final fileExtension = path.extension(file.path).replaceFirst('.', '').toLowerCase();

            // 检查文件类型和大小
            if (!widget.allowedExtensions.contains(fileExtension)) {
              errorMessages.add('${path.basename(file.path)}: 不支持的文件类型，仅支持 ${widget.allowedExtensions.join(", ")}');
              continue;
            }

            final fileSize = await file.length();
            if (fileSize > widget.maxFileSizeInBytes) {
              errorMessages.add('${path.basename(file.path)}: 文件过大，最大支持 ${widget.maxFileSizeInBytes / (1024 * 1024 * 1024)} GB');
              continue;
            }

            final fileInfo = await _getFileInfo(file);
            validFiles.add(fileInfo);
          }
        }
      }
    }

    setState(() {
      _fileInfoList = validFiles;
      _isProcessing = false;
    });

    // 调用回调函数，将文件信息传递给父组件
    if (widget.onFilesSelected != null && validFiles.isNotEmpty) {
      widget.onFilesSelected!(validFiles);
    }

    // 显示错误消息
    if (errorMessages.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('以下文件无法上传:'),
              ...errorMessages.map((msg) => Text(msg, style: const TextStyle(fontSize: 12))),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } catch (e) {
    debugPrint('Error processing files: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('处理文件时出错: $e')),
      );
    }
    setState(() {
      _isProcessing = false;
    });
  }
}
  // 处理点击选择文件
  Future<void> _pickFiles() async {
    if (_isProcessing) return; // 如果正在处理，则忽略新的选择

    setState(() {
      _isProcessing = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<Map<String, dynamic>> validFiles = [];
        List<String> errorMessages = [];

        for (final platformFile in result.files) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            
            // 检查文件大小
            if (platformFile.size > widget.maxFileSizeInBytes) {
              errorMessages.add('${platformFile.name}: 文件过大，最大支持 ${widget.maxFileSizeInBytes / (1024 * 1024 * 1024)} GB');
              continue;
            }
            
            final fileInfo = await _getFileInfo(file);
            validFiles.add(fileInfo);
          }
        }

        setState(() {
          _fileInfoList = validFiles;
        });

        // 调用回调函数，将文件信息传递给父组件
        if (widget.onFilesSelected != null && validFiles.isNotEmpty) {
          widget.onFilesSelected!(validFiles);
        }

        // 显示错误消息
        if (errorMessages.isNotEmpty && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('以下文件无法上传:'),
                  ...errorMessages.map((msg) => Text(msg, style: const TextStyle(fontSize: 12))),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件时出错: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // 获取文件信息
  Future<Map<String, dynamic>> _getFileInfo(File file) async {
    final size = await file.length();
    final type = path.extension(file.path).replaceFirst('.', '').toLowerCase();
    
    // 格式化文件大小
    String formattedSize;
    if (size < 1024) {
      formattedSize = '$size B';
    } else if (size < 1024 * 1024) {
      formattedSize = '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      formattedSize = '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      formattedSize = '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }

    return {
      'name': path.basename(file.path),
      'path': file.path,
      'size': size,
      'formattedSize': formattedSize,
      'type': type,
    };
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: DottedBorder(
          borderType: BorderType.RRect, // 圆角矩形
          radius: const Radius.circular(12), // 圆角半径
          dashPattern: const [6, 4], // 虚线长度和间距
          color: Colors.blue, // 边框颜色
          strokeWidth: 2, // 边框宽度
          child: DropTarget(
            onDragEntered: (details) {
              setState(() {
                _dragging = true;
              });
            },
            onDragExited: (details) {
              setState(() {
                _dragging = false;
              });
            },
            onDragDone: _onDrop,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                color: _dragging ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
                child: _isProcessing
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('处理文件中...', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : _fileInfoList.isEmpty
                        ? Center(
                        
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(onPressed: _pickFiles, icon: Icon(Icons.cloud_upload, color: Colors.blue[300], size: 48))
                                ,
                                const SizedBox(height: 16),
                                const Text(
                                  '点击或拖动文件上传',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '支持 ${widget.allowedExtensions.join(", ")} 等视频格式，单个文件最大 ${widget.maxFileSizeInBytes / (1024 * 1024 * 1024)} GB',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _fileInfoList.length,
                            itemBuilder: (context, index) {
                              final fileInfo = _fileInfoList[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: _getFileIcon(fileInfo['type']),
                                  title: Text(fileInfo['name']),
                                  subtitle: Text('${fileInfo['formattedSize']} · ${fileInfo['type'].toUpperCase()}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _fileInfoList.removeAt(index);
                                      });
                                      // 调用回调函数，将更新后的文件信息传递给父组件
                                      if (widget.onFilesSelected != null) {
                                        widget.onFilesSelected!(_fileInfoList);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ),
          ),
    );
  }
  
  // 根据文件类型返回对应的图标
  Widget _getFileIcon(String fileType) {
    IconData iconData;
    Color iconColor;
    
    switch (fileType.toLowerCase()) {
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
      case 'wmv':
      case 'flv':
        iconData = Icons.video_file;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.blue;
    }
    
    return Icon(iconData, color: iconColor);
  }
}
