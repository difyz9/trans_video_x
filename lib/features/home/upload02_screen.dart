
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/core/cos/providers/cos_providers.dart';
import 'package:tencent_cos_plus/tencent_cos_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



@RoutePage()
class Upload02Screen extends ConsumerStatefulWidget {
  const Upload02Screen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _Upload02ScreenState();
}

class _Upload02ScreenState extends ConsumerState<Upload02Screen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    
  }

  @override
  Widget build(BuildContext context) {


    final cos_providers = ref.watch(cosOperationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Upload Screen',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                // Handle button press

              print("you click me");

                cos_providers.uploadFile(filePath: "assets/images/avatar1.png", objectKey: "helloworld");

                print("objectKey: helloworld");
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}