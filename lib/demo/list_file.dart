import 'dart:io';
import 'package:dashcam/index.dart';
import 'package:dashcam_demo/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';

class ListFileInfoUI extends StatefulWidget {
  ListFileInfoUI();

  @override
  _ListFileInfoUIState createState() => _ListFileInfoUIState();
}

class _ListFileInfoUIState extends State<ListFileInfoUI> {
  DashcamPlatform dashcam = DashcamPlatform.instance;
  List<dynamic>? infors;
  @override
  void initState() {
    initData();
    super.initState();
  }

  Stream<List<dynamic>> initData() async* {
    List<dynamic>? list = [];
    int indexLoades = 0;
    await Future.delayed(const Duration(milliseconds: 500), () async {
      indexLoades = infors?.indexWhere((element) =>
              element["ThumbnailFilePath"] == Configs.MESSAGE_LODING_THUMBNAIL ||
              element["FileName"] == Configs.MESSAGE_LODING_THUMBNAIL) ??
          0;
      if (indexLoades > -1) {
        list = await dashcam.getFileRecordInfos();
      }
    });
    if (indexLoades > -1 || infors?.length != list?.length) {
      if (mounted) {
        setState(() {
          if ((list?.length ?? 1) > 0 && indexLoades > -1) {
            infors = list ?? [];
          }
        });
      }
      if (list!.isNotEmpty) {
        yield list ?? [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //if (infors == null) return Center(child: CircularProgressIndicator());
    return WillPopScope(
      onWillPop: () async {
        await dashcam.finishPlayBackFileList();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Material(
          child: StreamBuilder<List<dynamic>?>(
              builder: (BuildContext context, AsyncSnapshot<List<dynamic>?> snapshot) {
                if ((snapshot.data ?? []).isEmpty) return const Center(child: CircularProgressIndicator());
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      ...snapshot.data!
                          .sublist(0, 20)
                          .map(
                            (e) => InkWell(
                              onTap: () async {
                                await dashcam.finishPlayBackFileList();
                                int index =
                                    snapshot.data!.indexWhere((element) => element['FileTime'] == e['FileTime']);
                                await dashcam.setModeStreaming(2);
                                await dashcam.startStream();
                                await dashcam.playBackFile(index);
                                //await dashcam.downloadFileByIndex(0);
                                //await dashcam.deleteFileByIndex(0);
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              },
                              child: FileItem(
                                infor: e,
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                );
              },
              stream: initData(),
              initialData: []),
        ),
      ),
    );
  }
}

class FileItem extends StatefulWidget {
  dynamic infor = {};
  FileItem({this.infor});

  @override
  _FileItem createState() => _FileItem();
}

class _FileItem extends State<FileItem> {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  String? _thumbnailPath;
  String videoPath = '';
  int fileSize = 0;
  String duration = '';
  String? fileName = '';
  @override
  void initState() {
    super.initState();
    videoPath = widget.infor['ThumbnailFilePath'];
    fileSize = widget.infor['FileSize'];
    duration = widget.infor['FileTime'];
    fileName = widget.infor['FileName'];
    if (videoPath != "Unknown") {
      _generateThumbnail();
    }
  }

  @override
  void didUpdateWidget(covariant FileItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.infor['ThumbnailFilePath'] != widget.infor['ThumbnailFilePath']) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    try {
      if (videoPath.contains("jpg")) {
        _thumbnailPath = videoPath;
        return;
      }
      // Lấy thư mục tạm để lưu thumbnail
      final String dir = (await getTemporaryDirectory()).path;
      final String thumbnailPath = '$dir/$duration.png';
      File file = File(thumbnailPath);
      bool exitFile = await file.existsSync();
      if (exitFile) {
        setState(() {
          _thumbnailPath = thumbnailPath;
        });
        return;
      }
      int maxRequest = 3;

      // Lệnh FFmpeg để lấy khung hình (frame) tại giây 1
      String ffmpegCommand = '-i $videoPath -ss 00:00:00 -vframes 1 $thumbnailPath';
      // Chạy lệnh FFmpeg
      // await _flutterFFmpeg.execute(ffmpegCommand).then((rc) {
      //   if (rc == 0) {
      //     print('Thumbnail created successfully');
      //     setState(() {
      //       _thumbnailPath = thumbnailPath;
      //     });
      //   } else {
      //   }
      // });
      while (maxRequest > 0) {
        int result = await _flutterFFmpeg.execute(ffmpegCommand);
        if (result == 0) {
          setState(() {
            _thumbnailPath = thumbnailPath;
          });
          break;
        } else {
          maxRequest--;
        }
      }
    } catch (e) {
      print("Error generating thumbnail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // return _thumbnailPath != null
    //     ? Image.file(File(_thumbnailPath!)) // Hiển thị thumbnail từ file
    //     : Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          renderThumbnail(),
          const Gap(12),
          renderInfo(),
        ],
      ),
    );
  }

  Widget renderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File name: $fileName',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const Gap(16),
        Text(
          'File size: $fileSize',
          style: const TextStyle(fontSize: 14),
        ),
        const Gap(4),
        Text(
          'Duration: $duration',
          style: const TextStyle(fontSize: 14),
        )
      ],
    );
  }

  Widget renderThumbnail() {
    return _thumbnailPath != null
        ? Image.file(
            File(_thumbnailPath!),
            height: 70,
          ) // Hiển thị thumbnail từ file
        : const Center(child: CircularProgressIndicator());
  }
}
