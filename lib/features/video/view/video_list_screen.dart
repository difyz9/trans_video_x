import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:async'; // Add this import for Timer
import 'package:trans_video_x/features/video/viewmodel/video_view_model.dart';
import 'package:trans_video_x/core/layout/view/left_screen.dart';

@RoutePage()
class VideoListScreen extends ConsumerStatefulWidget {
  const VideoListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoListScreenState();
}


class _VideoListScreenState extends ConsumerState<VideoListScreen> {
  // 添加滚动控制器
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // 用于存储绝对滚动位置
  double? _scrollPosition;
  // 标记是否正在处理侧边栏状态变化
  bool _handlingSidebarChange = false;

  // 批量选择相关变量
  bool _isSelectionMode = false;
  Set<int> _selectedIndices = {};
  String _selectedAction = "标记为已读"; // 默认选中的操作

  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll > maxScroll * 0.8) {
      _scrollDebounce?.cancel();
      _scrollDebounce = Timer(const Duration(milliseconds: 200), () {
        final videoViewModel = ref.read(videoViewModelProvider.notifier);
        if (!videoViewModel.isLoadingMore) {
          videoViewModel.loadMoreVideos();
        }
      });
    }

    if (!_handlingSidebarChange) {
      _scrollPosition = currentScroll;
    }
  }

// 进入或退出选择模式
void _toggleSelectionMode() {
  if (!mounted) return; // Add this check
  setState(() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedIndices.clear();
    }
  });
}

// 选择或取消选择项目
void _toggleSelection(int index) {
  if (!mounted) return; // Add this check
  setState(() {
    if (_selectedIndices.contains(index)) {
      _selectedIndices.remove(index);
    } else {
      _selectedIndices.add(index);
    }
  });
}

// 全选
void _selectAll(int itemCount) {
  if (!mounted) return; // Add this check
  setState(() {
    if (_selectedIndices.length == itemCount) {
      // 如果已经全选，则取消全选
      _selectedIndices.clear();
    } else {
      // 否则全选
      _selectedIndices = Set.from(List.generate(itemCount, (index) => index));
    }
  });
}


  // 应用批量操作
  Future<void> _applyBatchAction() async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先选择视频')),
      );
      return;
    }

    final videoViewModel = ref.read(videoViewModelProvider.notifier);
    final videoState = ref.read(videoViewModelProvider);
    
    // 获取当前视频列表
    List<dynamic> selectedVideos = [];
    List<String> selectedVideoIds = [];
    
    // 从状态中安全地提取选中的视频ID
    videoState.maybeWhen(
      data: (response) {
        if (response.data != null) {
          // 获取选中的视频对象
          selectedVideos = _selectedIndices
              .where((index) => index < response.data!.length)
              .map((index) => response.data![index])
              .toList();
          
          // 提取视频ID - 确保使用正确的属性名称
          selectedVideoIds = selectedVideos
              .map((video) => video.id.toString()) // 使用videoId而非video_id
              // .map((video) => video.videoId.toString())
              .toList();
        }
      },
      orElse: () {},
    );
    
    if (selectedVideoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取选中视频信息失败')),
      );
      return;
    }



    // 根据选择的操作执行相应的处理
    try {
      switch (_selectedAction) {
        case "标记为已读":
          await _batchUpdateVideoStatus(videoViewModel, selectedVideoIds, "read");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已将${selectedVideoIds.length}个视频标记为已读')),
          );
          break;
        case "标记为未读":
          await _batchUpdateVideoStatus(videoViewModel, selectedVideoIds, "unread");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已将${selectedVideoIds.length}个视频标记为未读')),
          );
          break;
        case "添加到收藏":
          await _batchUpdateVideoStatus(videoViewModel, selectedVideoIds, "favorite");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已将${selectedVideoIds.length}个视频添加到收藏')),
          );
          break;
        case "移出收藏":
          await _batchUpdateVideoStatus(videoViewModel, selectedVideoIds, "unfavorite");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已将${selectedVideoIds.length}个视频从收藏中移除')),
          );
          break;
        case "删除":
          // 显示确认对话框
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认删除'),
            content: Text('确定要删除选中的${selectedVideoIds.length}个视频吗？此操作无法撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () async {                  
                  // Perform batch delete
                  await _batchUpdateVideoStatus(videoViewModel, selectedVideoIds, "delete");
                  
                  // Close progress dialog
                  if (mounted && Navigator.of(context).canPop()) { // Add mounted check
                    Navigator.of(context).pop();
                  }
                  
                  if (mounted) { // Add mounted check
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已删除${selectedVideoIds.length}个视频')),
                    );
                  
                    // Refresh list
                    await videoViewModel.fetchVideoList();
                  
                    // Exit selection mode after operation
                    if (mounted) _toggleSelectionMode(); // Already has mounted check
                  }
                },
                child: Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return; // Return early, don't execute the code below
    }
  } finally {
    // Close progress dialog
    if (mounted && Navigator.of(context).canPop()) { // Add mounted check
      Navigator.of(context).pop();
    }
    
    // Refresh list data after operation
    if (_selectedAction != "删除" && mounted) { // Add mounted check
      await videoViewModel.fetchVideoList();
    }
    
    // Exit selection mode after operation
    if (mounted) _toggleSelectionMode(); // Already has mounted check
  }
}
// 批量更新视频状态的方法
Future<void> _batchUpdateVideoStatus(
  VideoViewModel viewModel, 
  List<String> videoIds, 
  String status
) async {
  // 用于记录失败的视频
  List<String> failedIds = [];
  
  // 依次更新每个视频的状态
  for (final videoId in videoIds) {

    // print('Updating video ID: $videoId to status: $status');
    final success = await viewModel.updateVideoStatus(videoId, status);
    if (!success) {
      failedIds.add(videoId);
    }
  }
  
  // 如果有失败的视频，显示错误信息
  if (failedIds.isNotEmpty && mounted) { // Add mounted check
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('部分视频更新失败 (${failedIds.length}/${videoIds.length})'),
        duration: Duration(seconds: 5),
      ),
    );
  }
}

  // 构建批量操作工具栏
  Widget _buildBatchActionBar(int totalItems) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _toggleSelectionMode,
            tooltip: '退出选择模式',
          ),
          // 已选择数量
          Text(
            '已选择 ${_selectedIndices.length}/${totalItems}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          // 全选按钮
          IconButton(
            icon: Icon(
              _selectedIndices.length == totalItems
                  ? Icons.select_all
                  : Icons.deselect,
              color: Colors.white,
            ),
            onPressed: () => _selectAll(totalItems),
            tooltip: _selectedIndices.length == totalItems ? '取消全选' : '全选',
          ),
          Spacer(),
          // 操作选择下拉菜单
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButton<String>(
              value: _selectedAction,
              dropdownColor: Theme.of(context).primaryColor,
              underline: Container(),
              style: TextStyle(color: Colors.white, fontSize: 14),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
              items: [
                "标记为已读",
                "标记为未读",
                "添加到收藏",
                "移出收藏",
                "删除",
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAction = newValue;
                  });
                }
              },
            ),
          ),
          SizedBox(width: 16),
          // 应用按钮
          ElevatedButton(
            onPressed: _applyBatchAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
            ),
            child: Text('应用'),
          ),
        ],
      ),
    );
  }

  // 修改的筛选方法
  void _filterItems(String query) {
    setState(() {
      // 实现搜索功能
    });
  }

  void _refreshItems() {
    setState(() {
      ref.read(videoViewModelProvider.notifier).fetchVideoList();
      _searchController.clear();
    });
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('History'),
          content: Text('History records will be shown here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _login() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login'),
          content: Text('Login functionality will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoViewModelProvider);
    final videoViewModel = ref.read(videoViewModelProvider.notifier);

    // 监听侧边栏状态变化
    ref.listen(sidebarExpandedProvider, (previous, next) {
      // 当侧边栏状态变化且有保存的滚动位置时
      if (previous != next &&
          _scrollPosition != null &&
          _scrollController.hasClients) {
        // 标记正在处理侧边栏变化，防止滚动监听器更新保存的位置
        _handlingSidebarChange = true;

        // 使用WidgetsBinding确保在布局完成后应用滚动
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 应用保存的绝对滚动位置
          if (_scrollController.hasClients) {
            // 确保滚动位置在有效范围内
            final maxScroll = _scrollController.position.maxScrollExtent;
            final validOffset = _scrollPosition!.clamp(0.0, maxScroll);
            // 使用jumpTo而不是animateTo，避免动画效果
            _scrollController.jumpTo(validOffset);
          }

          // 重置标记
          _handlingSidebarChange = false;
        });
      }
    });

    return Scaffold(
      body: videoState.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $error',
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 重试加载数据
                  videoViewModel.fetchVideoList();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (response) {
          final totalItems = response.data!.length;

          return Column(
            children: [
              // 根据当前模式显示不同的顶部工具栏
              _isSelectionMode
                  ? _buildBatchActionBar(totalItems)
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          SizedBox(
                            width: 360,
                            height: 40,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: _filterItems,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: _refreshItems,
                          ),
                          IconButton(
                            icon: Icon(Icons.history),
                            onPressed: _showHistory,
                          ),
                          IconButton(
                            icon: Icon(Icons.login),
                            onPressed: _login,
                          ),
                          // 添加选择模式按钮
                          IconButton(
                            icon: Icon(Icons.select_all),
                            tooltip: '进入选择模式',
                            onPressed: _toggleSelectionMode,
                          ),
                        ],
                      ),
                    ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // Trigger loading when 80% of the way to the bottom
                    if (scrollInfo.metrics.pixels >
                        scrollInfo.metrics.maxScrollExtent * 0.8) {
                      videoViewModel.loadMoreVideos();
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final video = response.data![index];
                            final isSelected = _selectedIndices.contains(index);
                            
                            return GestureDetector(
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(index);
                                } else {

                                  // todo: 这里需要跳转到视频播放页面
                                  // context.router.push(
                                  //   // YoutubePlayRoute(videoId: video.videoId,currendId: video.id,status: video.status),
                                  //   // PlaymediaRoute(videoId: video.videoId),
                                  // );
                                }
                              },
                              // 添加长按进入选择模式的功能
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  _toggleSelectionMode();
                                  _toggleSelection(index);
                                }
                              },
                              child: Stack(
                                children: [
                                  Card(
                                    // 选中时改变卡片边框颜色
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Image.network(
                                            "https://img.youtube.com/vi/${video.videoId}/maxresdefault.jpg",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            cacheWidth: 500, // Limit cache size
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Center(
                                                child: Image.asset(
                                                  'assets/images/img_error.png',
                                                  height: 100,
                                                  width: 100,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            video.title?? "",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Text(
                                            video.videoUrl ?? "",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 选择模式下显示选择框
                                  if (_isSelectionMode)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                            color: Theme.of(context).primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                          childCount: response.data!.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: ref
                                    .watch(videoViewModelProvider.notifier)
                                    .isLoadingMore
                                ? CircularProgressIndicator()
                                : SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}