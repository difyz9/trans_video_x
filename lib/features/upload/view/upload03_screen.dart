import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:trans_video_x/features/upload/viewmodel/fileup_view_model.dart';
import 'package:trans_video_x/features/upload/model/file_upload_request.dart';
import 'package:trans_video_x/core/widget/file_drop_screen.dart';
import 'package:trans_video_x/core/widget/dropdown_widget.dart';



@RoutePage()
class Upload03Screen extends ConsumerStatefulWidget {
  const Upload03Screen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _Upload03ScreenState();
}

class _Upload03ScreenState extends ConsumerState<Upload03Screen>  with SingleTickerProviderStateMixin {

// 用于控制上传成功提示的显示和隐藏
  bool _showSuccessMessage = false;
  Timer? _successMessageTimer;
  
  @override
  void dispose() {
    _successMessageTimer?.cancel();
    super.dispose();
  }
  String? selectedCountry = '中国 (简体)';
  String? selectedLanguage = '英语';
  String? selectProvider = '微软';
  String? selectVoice = '微软';

  String description = '';
  String notes = '';

  // 文件信息将由fileUploadNotifierProvider管理

  // 历史上传文件列表
  List<Map<String, dynamic>> uploadedFiles = [
    {
      'name': '示例视频1.mp4',
      'path': '/path/to/file1.mp4',
      'formattedSize': '128 MB',
      'type': 'mp4',
      'uploadDate': '2025-03-01'
    },
    {
      'name': '示例视频2.mp4',
      'path': '/path/to/file2.mp4',
      'formattedSize': '256 MB',
      'type': 'mp4',
      'uploadDate': '2025-02-28'
    }
  ];

  // 分页相关变量
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  int get _totalPages => (uploadedFiles.length / _itemsPerPage).ceil();

  // 处理文件选择
  void _handleFilesSelected(List<Map<String, dynamic>> files) {
    // 使用Provider更新文件列表
    ref.read(fileUploadNotifierProvider.notifier).setFileInfoList(files);
  }

  // 处理文件上传
  Future<void> _handleUpload() async {
    final fileUploadState = ref.read(fileUploadNotifierProvider);
    
    if (fileUploadState.fileInfoList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要上传的文件')),
      );
      return;
    }
    
    try {
      // 提取文件路径列表
      final List<String> filePaths = fileUploadState.fileInfoList
          .map((fileInfo) => fileInfo['path'] as String)
          .toList();
      
      // 使用Provider上传文件
      await ref.read(fileUploadNotifierProvider.notifier).uploadFiles(
        filePaths: filePaths,
        sourceLanguage: selectedCountry ?? '中国 (简体)',
        targetLanguage: selectedLanguage ?? '英语',
        provider: selectProvider ?? '微软',
        voice: selectVoice ?? '微软',
      );
      
      // 将新上传的文件添加到历史记录中
      final newUploadedFiles = fileUploadState.fileInfoList.map((fileInfo) => {
        'name': fileInfo['name'] as String,
        'path': fileInfo['path'] as String,
        'formattedSize': fileInfo['formattedSize'] as String,
        'type': fileInfo['type'] as String,
        'uploadDate': DateTime.now().toString().substring(0, 10)
      }).toList();

      setState(() {
        _showSuccessMessage = true;
        description = '';
        notes = '';
        // 将新上传的文件添加到历史记录列表的开头
        uploadedFiles.insertAll(0, newUploadedFiles);
      });
      
      // 取消之前的计时器（如果有）
      _successMessageTimer?.cancel();
      
      // 设置新的计时器，3秒后隐藏提示信息
      _successMessageTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSuccessMessage = false;
          });
          // 清空上传状态
          ref.read(fileUploadNotifierProvider.notifier).clearFileInfoList();
          // 清空FileDropWidget组件的数据
          _handleFilesSelected([]);
        }
      });
    } catch (e) {
      // 错误处理在Consumer中进行
    }
  }

  // 处理取消操作
  void _handleCancel() {
    // 使用Provider清空文件列表
    ref.read(fileUploadNotifierProvider.notifier).clearFileInfoList();
    
    // 隐藏成功提示信息
    setState(() {
      _showSuccessMessage = false;
      description = '';
      notes = '';
    });
    
    // 取消计时器
    _successMessageTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // 使用Consumer获取fileUploadState
    return Consumer(
      builder: (context, ref, child) {
        final fileUploadState = ref.watch(fileUploadNotifierProvider);
        final fileInfoList = fileUploadState.fileInfoList;
        final isUploading = fileUploadState.status == FileUploadStatus.loading;
        final hasError = fileUploadState.status == FileUploadStatus.error;
        final isSuccess = fileUploadState.status == FileUploadStatus.success;
        
        // 计算价格（示例：每个文件64元）
        final price = fileInfoList.length * 64.0;

        return Scaffold(
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部上传提示区域
                FileDropWidget(
                  height: 180,
                  width:400,
                  onFilesSelected: _handleFilesSelected,
                  initialFiles: fileInfoList,
                ),
                const SizedBox(height: 16.0),

                // 国家/地区和语言下拉菜单
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownWidget(
                      initialValue: selectedCountry,
                      onChanged: (value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      },
                      labelText: '源语言',
                      width: 250,
                      options: const ['中国 (简体)', '美国 (English)'],
                    ),
                    const SizedBox(
                      width: 40,
                    ),

                    // const SizedBox(width: 16.0),
                    DropdownWidget(
                        initialValue: selectedLanguage,
                        onChanged: (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                        labelText: '目标语言',
                        width: 250,
                        options: const ['英语', '中文'])
                  ],
                ),

                const SizedBox(height: 16.0),

                // 价格和按钮区域
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '应付金额： ¥${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: isUploading ? null : _handleCancel,
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: isUploading || fileInfoList.isEmpty ? null : _handleUpload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: isUploading 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                )
                              : const Text('开始上传'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // 上传状态和结果显示
                if (isUploading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16.0),
                          Text('正在上传文件，请稍候...'),
                        ],
                      ),
                    ),
                  ),
                
                // 错误信息显示
                if (hasError && fileUploadState.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            fileUploadState.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 上传结果显示
                if (_showSuccessMessage && isSuccess && fileUploadState.response != null)
                
                  AnimatedOpacity(
                    opacity: _showSuccessMessage ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700),
                              const SizedBox(width: 16.0),
                              Text(
                                '上传成功',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text('任务ID: ${fileUploadState.response!.taskId}'),
                          Text('文件数量: ${fileUploadState.response!.fileCount}'),
                          Text('消息: ${fileUploadState.response!.message}'),
                        ],
                      ),
                    ),
                  ),
                
                // 文件预览区域
                if (uploadedFiles.isNotEmpty && !isUploading) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '最近上传',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      
                      TextButton(
                        onPressed: () {
                          
                        },
                        child: const Text(
                          '查看全部',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  ...uploadedFiles
                      .skip((_currentPage - 1) * _itemsPerPage)
                      .take(_itemsPerPage)
                      .map((file) => Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: _getFileIcon(file['type']),
                              title: Text(file['name']),
                              subtitle: Text(
                                  '${file['formattedSize']} · ${file['uploadDate']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download,
                                        color: Colors.blue),
                                    onPressed: () {
                                      // 下载操作
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('正在下载: ${file['name']}')),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        uploadedFiles.remove(file);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                  // 分页控制器
                  if (_totalPages > 1) ...[  
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        Text('$_currentPage / $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
      
        );
      }
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
