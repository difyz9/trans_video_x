import 'package:flutter/material.dart';

class SettingsPanel extends StatefulWidget {
  final int? currentSubmenuIndex;
  final Function(int) onSubmenuSelected;
  final VoidCallback onClose;
  final bool stableVolume;
  final bool showAnnotations;
  final Function(bool) onStableVolumeChanged;
  final Function(bool) onAnnotationsChanged;
  final String currentSubtitleMode;
  final Function(String) onSubtitleModeChanged;
  final String currentSleepTimer;
  final Function(String) onSleepTimerChanged;
  final String currentPlaybackSpeed;
  final Function(String) onPlaybackSpeedChanged;
  final String currentQuality;
  final Function(String) onQualityChanged;

  const SettingsPanel({
    Key? key,
    required this.currentSubmenuIndex,
    required this.onSubmenuSelected,
    required this.onClose,
    required this.stableVolume,
    required this.showAnnotations,
    required this.onStableVolumeChanged,
    required this.onAnnotationsChanged,
    required this.currentSubtitleMode,
    required this.onSubtitleModeChanged,
    required this.currentSleepTimer,
    required this.onSleepTimerChanged,
    required this.currentPlaybackSpeed,
    required this.onPlaybackSpeedChanged,
    required this.currentQuality,
    required this.onQualityChanged,
  }) : super(key: key);

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> with SingleTickerProviderStateMixin {
  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // 子菜单动画
  bool _isAnimatingSubmenu = false;
  int? _previousSubmenuIndex;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // 滑动动画
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // 淡入淡出动画
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // 启动动画
    _animationController.forward();
  }
  
  @override
  void didUpdateWidget(SettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检测子菜单变化，触发动画
    if (oldWidget.currentSubmenuIndex != widget.currentSubmenuIndex) {
      setState(() {
        _isAnimatingSubmenu = true;
        _previousSubmenuIndex = oldWidget.currentSubmenuIndex;
      });
      
      // 延迟一段时间后完成动画
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isAnimatingSubmenu = false;
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(250 * _slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              color: const Color(0xFF1F1F1F),
              child: _isAnimatingSubmenu
                  ? _buildAnimatedSubmenuTransition()
                  : (widget.currentSubmenuIndex == null
                      ? _buildMainMenu()
                      : _buildSubmenu(widget.currentSubmenuIndex!)),
            ),
          ),
        );
      },
    );
  }
  
  // 构建子菜单切换动画
  Widget _buildAnimatedSubmenuTransition() {
    // 如果是从主菜单到子菜单
    if (_previousSubmenuIndex == null) {
      return Stack(
        children: [
          // 主菜单（淡出）
          Opacity(
            opacity: 0.0,
            child: _buildMainMenu(),
          ),
          // 子菜单（淡入）
          Opacity(
            opacity: 1.0,
            child: _buildSubmenu(widget.currentSubmenuIndex!),
          ),
        ],
      );
    } 
    // 如果是从子菜单到主菜单
    else if (widget.currentSubmenuIndex == null) {
      return Stack(
        children: [
          // 子菜单（淡出）
          Opacity(
            opacity: 0.0,
            child: _buildSubmenu(_previousSubmenuIndex!),
          ),
          // 主菜单（淡入）
          Opacity(
            opacity: 1.0,
            child: _buildMainMenu(),
          ),
        ],
      );
    }
    // 如果是从一个子菜单到另一个子菜单
    else {
      return Stack(
        children: [
          // 前一个子菜单（淡出）
          Opacity(
            opacity: 0.0,
            child: _buildSubmenu(_previousSubmenuIndex!),
          ),
          // 当前子菜单（淡入）
          Opacity(
            opacity: 1.0,
            child: _buildSubmenu(widget.currentSubmenuIndex!),
          ),
        ],
      );
    }
  }

  Widget _buildMainMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.settings, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                '设置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey, height: 1),

        // 稳定音量
        _buildSwitchItem(
          icon: Icons.volume_up,
          title: '稳定音量',
          value: widget.stableVolume,
          onChanged: widget.onStableVolumeChanged,
        ),

        // 注释
        _buildSwitchItem(
          icon: Icons.comment,
          title: '注释',
          value: widget.showAnnotations,
          onChanged: widget.onAnnotationsChanged,
        ),

        // 字幕
        _buildNavigationItem(
          icon: Icons.subtitles,
          title: '字幕',
          subtitle: widget.currentSubtitleMode,
          index: 0,
        ),

        // 休眠定时器
        _buildNavigationItem(
          icon: Icons.timer,
          title: '休眠定时器',
          subtitle: widget.currentSleepTimer,
          index: 1,
        ),

        // 播放速度
        _buildNavigationItem(
          icon: Icons.speed,
          title: '播放速度',
          subtitle: widget.currentPlaybackSpeed,
          index: 2,
        ),

        // 画质
        _buildNavigationItem(
          icon: Icons.high_quality,
          title: '画质',
          subtitle: widget.currentQuality,
          index: 3,
        ),
      ],
    );
  }

  Widget _buildSubmenu(int index) {
    switch (index) {
      case 0:
        return _buildSubtitleSubmenu();
      case 1:
        return _buildSleepTimerSubmenu();
      case 2:
        return _buildPlaybackSpeedSubmenu();
      case 3:
        return _buildQualitySubmenu();
      default:
        return Container();
    }
  }

  Widget _buildSubtitleSubmenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubmenuHeader('字幕'),
        _buildRadioItem('关闭', widget.currentSubtitleMode == '关闭', () => widget.onSubtitleModeChanged('关闭')),
        _buildRadioItem('字幕 (1)', widget.currentSubtitleMode == '字幕 (1)', () => widget.onSubtitleModeChanged('字幕 (1)')),
        _buildRadioItem('自动翻译', widget.currentSubtitleMode == '自动翻译', () => widget.onSubtitleModeChanged('自动翻译')),
      ],
    );
  }

  Widget _buildSleepTimerSubmenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubmenuHeader('休眠定时器'),
        _buildRadioItem('关闭', widget.currentSleepTimer == '关闭', () => widget.onSleepTimerChanged('关闭')),
        _buildRadioItem('15分钟后', widget.currentSleepTimer == '15分钟后', () => widget.onSleepTimerChanged('15分钟后')),
        _buildRadioItem('30分钟后', widget.currentSleepTimer == '30分钟后', () => widget.onSleepTimerChanged('30分钟后')),
        _buildRadioItem('45分钟后', widget.currentSleepTimer == '45分钟后', () => widget.onSleepTimerChanged('45分钟后')),
        _buildRadioItem('60分钟后', widget.currentSleepTimer == '60分钟后', () => widget.onSleepTimerChanged('60分钟后')),
        _buildRadioItem('90分钟后', widget.currentSleepTimer == '90分钟后', () => widget.onSleepTimerChanged('90分钟后')),
      ],
    );
  }

  Widget _buildPlaybackSpeedSubmenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubmenuHeader('播放速度'),
        _buildRadioItem('0.75x', widget.currentPlaybackSpeed == '0.75x', () => widget.onPlaybackSpeedChanged('0.75x')),
        _buildRadioItem('正常', widget.currentPlaybackSpeed == '正常', () => widget.onPlaybackSpeedChanged('正常')),
        _buildRadioItem('1.25x', widget.currentPlaybackSpeed == '1.25x', () => widget.onPlaybackSpeedChanged('1.25x')),
        _buildRadioItem('1.5x', widget.currentPlaybackSpeed == '1.5x', () => widget.onPlaybackSpeedChanged('1.5x')),
        _buildRadioItem('1.75x', widget.currentPlaybackSpeed == '1.75x', () => widget.onPlaybackSpeedChanged('1.75x')),
        _buildRadioItem('2x', widget.currentPlaybackSpeed == '2x', () => widget.onPlaybackSpeedChanged('2x')),
      ],
    );
  }

  Widget _buildQualitySubmenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubmenuHeader('画质'),
        _buildRadioItem('自动 (1080p HD)', widget.currentQuality == '自动 (1080p HD)', () => widget.onQualityChanged('自动 (1080p HD)')),
        _buildRadioItem('480p', widget.currentQuality == '480p', () => widget.onQualityChanged('480p')),
        _buildRadioItem('720p HD', widget.currentQuality == '720p HD', () => widget.onQualityChanged('720p HD')),
        _buildRadioItem('1080p HD', widget.currentQuality == '1080p HD', () => widget.onQualityChanged('1080p HD')),
        _buildRadioItem('1440p HD', widget.currentQuality == '1440p HD', () => widget.onQualityChanged('1440p HD')),
        _buildRadioItem('2160p 4K', widget.currentQuality == '2160p 4K', () => widget.onQualityChanged('2160p 4K')),
      ],
    );
  }

  Widget _buildSubmenuHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => widget.onSubmenuSelected(-1), // -1 表示返回主菜单
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
  }) {
    return InkWell(
      onTap: () => widget.onSubmenuSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioItem(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
