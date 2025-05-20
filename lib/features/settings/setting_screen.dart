import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trans_video_x/core/layout/provider/layout_provider.dart';
import 'package:trans_video_x/features/login/login_page.dart';
import 'package:trans_video_x/features/login/provider/auth_provide.dart';


// Make sure these providers don't have circular dependencies
final localThemeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localLanguageProvider = StateProvider<String>((ref) => 'zh_CN');
final localUserProfileProvider = StateProvider<LocalUserProfile>((ref) {
  return LocalUserProfile(
    isLoggedIn: false,
    nickname: null,
    email: null,
    avatarUrl: null,
  );
});

// Simple local user profile class
class LocalUserProfile {
  final bool isLoggedIn;
  final String? nickname;
  final String? email;
  final String? avatarUrl;

  LocalUserProfile({
    required this.isLoggedIn,
    this.nickname,
    this.email,
    this.avatarUrl,
  });

  LocalUserProfile copyWith({
    bool? isLoggedIn,
    String? nickname,
    String? email,
    String? avatarUrl,
  }) {
    return LocalUserProfile(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// Settings utilities
class SettingsUtils {
  static const String firstVisitKey = 'settings_first_visit';
  
  static List<String> searchSettings(String query) {
    if (query.isEmpty) return [];
    
    // Search index for different setting categories
    final Map<String, List<String>> searchIndex = {
      'account': ['用户', '账户', '登录', '退出', '个人信息', '头像'],
      'theme': ['主题', '颜色', '深色模式', '浅色模式', '夜间模式'],
      'language': ['语言', '中文', '英文', '日语', '韩语'],
      'notification': ['通知', '提醒', '消息'],
      'about': ['关于', '版本', '更新'],
    };
    
    final results = <String>[];
    searchIndex.forEach((key, terms) {
      for (final term in terms) {
        if (term.toLowerCase().contains(query.toLowerCase())) {
          if (!results.contains(key)) {
            results.add(key);
          }
          break;
        }
      }
    });
    
    return results;
  }
}

@RoutePage()
class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> with SingleTickerProviderStateMixin {
  // Settings state
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _version = '';
  String _appName = '';
  String _buildNumber = '';
  
  // Create a provider that depends on authProvider
final userProfileSynchronizerProvider = Provider.autoDispose((ref) {
  // final authState = ref.watch(authProvider);
  
  // Update localUserProfile when auth state changes
  // if (authState.isLoggedIn && authState.user != null) {
  //   ref.read(localUserProfileProvider.notifier).state = LocalUserProfile(
  //     isLoggedIn: true,
  //     nickname: authState.user?.userName ?? "用户",
  //     email: authState.user?.email,
  //     avatarUrl: authState.user?.avatar,
  //   );
  // }
  
  return null; // This provider doesn't need to return anything
});
  // Language options
  final List<LanguageOption> _languages = [
    const LanguageOption(
      code: 'zh_CN',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      flagAsset: 'assets/flags/cn.png',
    ),
    const LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagAsset: 'assets/flags/us.png',
    ),
    const LanguageOption(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flagAsset: 'assets/flags/jp.png',
    ),
    const LanguageOption(
      code: 'ko',
      name: 'Korean',
      nativeName: '한国语',
      flagAsset: 'assets/flags/kr.png',
    ),
  ];
  
  // Color options
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];
  
  // Selected color
  Color _selectedColor = Colors.blue;
  
  // 搜索相关
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchResults = [];

  // 动画控制器
  late AnimationController _animationController;

  // 首次访问指引
  bool _showFirstVisitGuide = false;

  @override
  void initState() {
    super.initState();
    // 加载包信息
    _loadPackageInfo();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 检查是否首次访问
    _checkFirstVisit();

    // 监听搜索
    _searchController.addListener(_onSearchChanged);
    
    // Check auth state when screen initializes
    _checkAuthState();
  }
// Add method to check authentication state
void _checkAuthState() {
  // final authState = ref.read(authProvider);
  // if (authState.isLoggedIn && authState.user != null) {
    // This line is causing the error
    // ref.read(localUserProfileProvider.notifier).state = LocalUserProfile(
    //   isLoggedIn: true,
    //   nickname: authState.user?.userName ?? "用户",
    //   email: authState.user?.email,
    //   avatarUrl: authState.user?.avatar,
    // );
  // }
}
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }



  // 获取当前语言的本地名称
  String get _currentLanguageNativeName {
    final currentLang = ref.watch(languageProvider);
    return _languages
        .firstWhere(
          (lang) => lang.code == currentLang, 
          orElse: () => _languages[0]
        )
        .nativeName;
  }

  // 搜索变化处理
  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _searchResults = SettingsUtils.searchSettings(_searchController.text);
    });
  }

  // 检查是否首次访问
  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = !prefs.containsKey(SettingsUtils.firstVisitKey);

    if (isFirst) {
      setState(() {
        _showFirstVisitGuide = true;
      });
      await prefs.setBool(SettingsUtils.firstVisitKey, false);
    }
  }

  // Add method to load package info
  Future<void> _loadPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.appName;
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {

      ref.watch(userProfileSynchronizerProvider);

    // 监听主题变化
    final themeMode = ref.watch(themeProvider);
    final themeState = ref.watch(themeNotifierProvider);
    _darkModeEnabled = themeMode == ThemeMode.dark;
    
    // 获取当前语言状态
    final currentLanguage = ref.watch(languageProvider);
    // 获取修改语言状态的方法
    final languageNotifier = ref.watch(languageProvider.notifier);
    
    // 获取当前渐变颜色列表
    final currentColors = ref.watch(gradientColorProvider);
    _selectedColor = currentColors.isNotEmpty ? currentColors[0] : Colors.blue;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text('设置', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // 用户信息部分
          _buildUserSection(),
          const SizedBox(height: 12),
          // 设置项部分
          _buildSettingsSection(),
          const SizedBox(height: 12),
          // 退出登录按钮
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserSection() {
    final userProfile = ref.watch(localUserProfileProvider);
    final authState = ref.watch(authProvider); // Add auth state watch
    
    // Use auth state if available
    final bool isLoggedIn = userProfile.isLoggedIn || authState.isLoggedIn;
    final String? nickname = userProfile.nickname ?? authState.user?.userName;
    final String? email = userProfile.email ?? authState.user?.email;
    final String? avatarUrl = userProfile.avatarUrl ?? authState.user?.avatar;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (!isLoggedIn) {
            _showLoginDialog(context);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // 用户头像
            Hero(
              tag: 'user_avatar',
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: isLoggedIn && avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: isLoggedIn && avatarUrl != null
                    ? null
                    : Icon(Icons.person, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(width: 16),
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn 
                        ? nickname ?? '用户' 
                        : '未登录',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLoggedIn 
                        ? email ?? '' 
                        : '点击登录账号',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // 登录弹窗
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: LoginScreen(
              onLoginResult: (bool success) {
                if (success) {
                  Navigator.pop(context); // Close the dialog
                  // No need to call _checkAuthState() anymore
                  // The userProfileSynchronizerProvider will update automatically
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection() {    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsGroup(
          '应用设置',
          [
            _buildCompactSwitchSettingItem('通知提醒', _notificationsEnabled, (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            }),
            _buildCompactSwitchSettingItem('深色模式', _darkModeEnabled, (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // Update theme mode
              ref.read(localThemeModeProvider.notifier).state = 
                value ? ThemeMode.dark : ThemeMode.light;
            }),
            _buildCompactSettingItemWithValue('语言', _currentLanguageNativeName, () {
              _showLanguageSelector(context);
            }),
            // 添加主题色调选择
            _buildColorPickerItem(),
          ],
        ),
        _buildSettingsGroup(
          '支持与反馈',
          [
            _buildCompactSettingItem('意见反馈', Icons.chevron_right, () {
              _showFeedbackDialog();
            }),
            _buildCompactSettingItem('关于', Icons.chevron_right, () {
              _showAboutDialog();
            }),
            _buildCompactUpdateItem(),
          ],
        ),
      ],
    );
  }

  void _updateGradientColor(Color newColor) {
    final gradientColorNotifier = ref.read(gradientColorProvider.notifier);
    final currentColors = ref.read(gradientColorProvider);

    List<Color> updatedColors = [newColor];

    // Create a gradient by keeping one color from current selection
    if (currentColors.length >= 2 && currentColors[1] != newColor) {
      updatedColors.add(currentColors[1]);
    } else {
      // Add a complementary color if needed
      updatedColors.add(newColor == Colors.blue ? Colors.purple : Colors.blue);
    }

    // Update the gradient colors through the provider
    gradientColorNotifier.setColors(updatedColors);
  }

  Widget _buildColorPickerItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
          child: Text(
            '主题色调',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colorOptions.length,
            itemBuilder: (context, index) {
              final color = _colorOptions[index];
              final isSelected = color == _selectedColor;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  _updateGradientColor(color);
                  // HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(isSelected ? 0.6 : 0.3),
                        blurRadius: isSelected ? 8 : 3,
                        spreadRadius: isSelected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: isSelected 
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: List.generate(children.length * 2 - 1, (index) {
              if (index.isEven) {
                return children[index ~/ 2];
              } else {
                return Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.grey.shade200,
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSettingItem(String title, IconData trailingIcon, [VoidCallback? onTap]) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: Icon(trailingIcon, color: Colors.grey.shade400, size: 20),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildCompactSwitchSettingItem(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: CupertinoSwitch(
          value: value,
          activeColor: _selectedColor,
          onChanged: (newValue) {
            // For theme mode switching
            if (title == '深色模式') {
              // Update theme mode using the themeNotifierProvider
              if (newValue) {
              } else {
              }
            }
            
            // Call the original callback
            onChanged(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildCompactSettingItemWithValue(String title, String value, VoidCallback onTap) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildCompactUpdateItem() {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: const Text(
        '检查更新',
        style: TextStyle(fontSize: 15),
      ),
      subtitle: Text(
        '发现新版本',
        style: TextStyle(fontSize: 11, color: _selectedColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '当前版本为 $_version',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
      onTap: () {
        _showUpdateDialog(context);
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final currentLanguage = ref.read(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '选择语言/Select Language',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _selectedColor,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLanguageOption(
                  context,
                  flag: '🇨🇳',
                  language: '简体中文',
                  englishName: 'Chinese',
                  isSelected: currentLanguage == 'zh',
                  onTap: () {
                    languageNotifier.setLanguage('zh');
                    context.setLocale(const Locale('zh', ''));
                    Navigator.pop(context);
                    _showLanguageChangedSnackbar(context, '简体中文', currentLanguage);
                  },
                ),
                _buildLanguageOption(
                  context,
                  flag: '🇺🇸',
                  language: 'English',
                  englishName: 'English',
                  isSelected: currentLanguage == 'en',
                  onTap: () {
                    languageNotifier.setLanguage('en');
                    context.setLocale(const Locale('en', ''));
                    Navigator.pop(context);
                    _showLanguageChangedSnackbar(context, 'English', currentLanguage);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String flag,
    required String language,
    required String englishName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _selectedColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              language,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? _selectedColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              englishName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageChangedSnackbar(BuildContext context, String newLanguage, String oldLanguage) {
    final languageNotifier = ref.read(languageProvider.notifier);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已切换到 $newLanguage'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            // Revert to previous language
            languageNotifier.setLanguage(oldLanguage);
            if (oldLanguage == 'zh') {
              context.setLocale(const Locale('zh', ''));
            } else if (oldLanguage == 'en') {
              context.setLocale(const Locale('en', '')); 
            }
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('意见反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请描述您遇到的问题或建议，我们将尽快处理并回复您。'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: '请输入您的反馈内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (feedbackController.text.isNotEmpty) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('感谢您的反馈！'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('提交', style: TextStyle(color: _selectedColor)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: _appName,
        applicationVersion: 'v$_version (Build $_buildNumber)',
        applicationIcon: const FlutterLogo(size: 40),
        children: [
          const Text('一个简单易用的视频下载转换工具，支持多种视频网站的下载和格式转换。'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('官方网站：'),
              InkWell(
                onTap: () {
                  // 打开网站
                },
                child: Text(
                  'https://example.com',
                  style: TextStyle(
                    color: _selectedColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('© 2025 Your Company. All rights reserved.'),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('发现新版本'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('V1.3.0 版本更新内容:'),
              SizedBox(height: 8),
              Text('• 优化了用户界面'),
              Text('• 修复了已知问题'),
              Text('• 提升了应用性能'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('稍后更新'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('立即更新', style: TextStyle(color: _selectedColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final userProfile = ref.watch(localUserProfileProvider);
    final authState = ref.watch(authProvider); // Add auth state watch
    
    // 如果未登录，不显示退出按钮
    if (!userProfile.isLoggedIn && !authState.isLoggedIn) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.red,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.red.shade300, width: 0.5),
          shadowColor: Colors.black.withOpacity(0.05),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          _showLogoutDialog(context);
        },
        child: const Text('退出登录', style: TextStyle(fontSize: 15)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                // 退出登录处理 - using auth provider
                await ref.read(authProvider.notifier).signOut();
                
                // Update local user profile
                ref.read(localUserProfileProvider.notifier).state = LocalUserProfile(
                  isLoggedIn: false,
                  nickname: null,
                  email: null,
                  avatarUrl: null,
                );
                
                Navigator.of(context).pop();
                
                // 显示登出成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('您已成功退出登录'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // 触发反馈
                HapticFeedback.mediumImpact();
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// A simplified language option class
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String? flagAsset;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    this.flagAsset,
  });
}