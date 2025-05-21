import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trans_video_x/core/cos/providers/cos_providers.dart';
import 'package:trans_video_x/core/widget/file_drop_screen.dart'; // Added import

import 'package:path/path.dart' as p; // For path manipulation

@RoutePage()
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final List<PlatformFile> _files = [];
  String? _folderPath;
  bool _dragging = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _folderPath = null; // Clear folder path if files are selected
        _files.addAll(result.files.where((file) => file.path != null));
      });
    }
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _files.clear(); // Clear files if a folder is selected
        _folderPath = selectedDirectory;
      });
    }
  }



    void _handleFilesSelected(List<Map<String, dynamic>> selectedFilesData) {
    setState(() {
      _files.clear();
      _files.addAll(selectedFilesData.map((fileData) => PlatformFile(
            name: fileData['name'] as String,
            path: fileData['path'] as String,
            size: fileData['size'] as int,
          )));
      // _folderPath = null; // Ensure folderPath is null as we get a flat list
    });
  }

  void _startUpload() {
    final notifier = ref.read(cosOperationProvider.notifier);
    final currentBucket = ref.read(currentBucketProvider);

    if (currentBucket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bucket first.')),
      );
      return;
    }

    if (_folderPath != null) {
      final folderName = p.basename(_folderPath!);
      notifier.uploadDirectory(
          localDirectory: _folderPath!, destinationPrefix: '$folderName/');
    } else if (_files.isNotEmpty) {
      for (var file in _files) {
        if (file.path != null) { // file.path from PlatformFile can be null
          notifier.uploadFile(filePath: file.path!, objectKey: file.name);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select files or a folder to upload.')),
      );
    }
  }

  List<Map<String, dynamic>> _platformFilesToMapList(List<PlatformFile> platformFiles) {
    return platformFiles.map((pf) {
      String formattedSize;
      final size = pf.size;
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
        'name': pf.name,
        'path': pf.path,
        'size': pf.size,
        'formattedSize': formattedSize,
        'type': pf.extension?.toLowerCase() ?? p.extension(pf.name).replaceFirst('.', '').toLowerCase(),
      };
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    final cosState = ref.watch(cosOperationProvider);

    ref.listen<CosOperationState>(cosOperationProvider, (_, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Upload successful: ${next.result ?? 'Operation completed'}')),
        );
        setState(() {
          _files.clear();
          _folderPath = null;
        });
        ref.read(cosOperationProvider.notifier).reset();
        // Invalidate objectsProvider to refresh the list after upload
        ref.invalidate(objectsProvider);
      } else if (next.error != null) {
        String errorMessage = 'Upload failed: ${next.error}';
        if (next.originalError != null) {
          print('Original error: ${next.originalError}'); // Log the original error
          // Optionally, include more details from originalError if needed for the UI
          // For example, if originalError has specific fields like .statusCode or .message
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        ref.read(cosOperationProvider.notifier).reset();
      }
    });
        final initialFilesForDropWidget = _platformFilesToMapList(_files);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload to COS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
        
             FileDropWidget(
              onFilesSelected: _handleFilesSelected,
              initialFiles: initialFilesForDropWidget,
    
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Select Files'),
                  onPressed: _pickFiles,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select Folder'),
                  onPressed: _pickFolder,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_files.isNotEmpty || _folderPath != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _folderPath != null
                          ? 'Selected Folder:'
                          : 'Selected Files:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _folderPath != null
                          ? Card(
                              child: ListTile(
                                leading: const Icon(Icons.folder),
                                title: Text(p.basename(_folderPath!)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _folderPath = null),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _files.length,
                              itemBuilder: (context, index) {
                                final file = _files[index];
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.insert_drive_file),
                                    title: Text(file.name),
                                    subtitle: Text(
                                        // Display N/A if size is 0, otherwise format it
                                        file.size == 0 ? 'Size: N/A' : '${(file.size / 1024).toStringAsFixed(2)} KB'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _files.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (cosState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload to Tencent COS'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: (_files.isNotEmpty || _folderPath != null) && !cosState.isLoading
                    ? _startUpload
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}