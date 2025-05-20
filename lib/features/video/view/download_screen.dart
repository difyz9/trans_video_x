import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/features/video/view/info_screen.dart';
import 'package:trans_video_x/features/video/view/youtube_page.dart';
import 'package:trans_video_x/features/config/view/config_screen.dart';


@RoutePage()
class DownloadScreen extends ConsumerStatefulWidget {
  const DownloadScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends ConsumerState<DownloadScreen> with TickerProviderStateMixin {

late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: !isDarkMode ? Theme.of(context).colorScheme.inversePrimary : null,
        bottom: TabBar(
          dividerHeight: 0,
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.subscriptions), text: 'Baixar do YouTube'),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Configurações',
            ),
            Tab(icon: Icon(Icons.info), text: 'Créditos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: YoutubePage(
              tabController: _tabController,
            ),
          ),
          SingleChildScrollView(
            child: const Padding(
              padding: EdgeInsets.all(30.0),
              child: ConfigScreen(),
            ),
          ),
          const InfoScreen(),
        ],
      ),
    );
  }
}
