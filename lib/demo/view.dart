import 'package:dashcam/index.dart';
import 'package:flutter/material.dart';

import '../utils/configs.dart';
import 'list_file.dart';

class StreamingPage extends StatefulWidget {
  @override
  _StreamingPageState createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> {
  bool isPlaying = false;
  DashcamPlatform dashcam = DashcamPlatform.instance;
  bool isLoading = true;
  bool isRecording = false;
  int mode = Configs.GPDEVICEMODE_Record;
  @override
  void initState() {
    dashcam.startStream();
    super.initState();
  }

  @override
  void dispose() {
    dashcam.finishStream();
    super.dispose();
  }

  onTapButtonPlay() async {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      // nhớ pause playback-> finish playback -> start stream mới xem lại xem cũ
      dashcam.stopStream();
      //dashcam.pauseStream();
    } else {
      //dashcam.stopPlayBackFile();
      await dashcam.restartStream();
      //dashcam.resumeStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await dashcam.finishPlayBackFile();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Streaming Page'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 8,
              child: AndroidView(
                viewType: 'dash_cam',
                onPlatformViewCreated: (id) {
                  dashcam.startStream();
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: onTapButtonPlay,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          !isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 30,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        dashcam.record();
                        setState(() {
                          isRecording = !isRecording;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          isRecording ? Icons.pause : Icons.video_camera_back,
                          size: 30,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (mode == Configs.GPDEVICEMODE_Record) {
                          mode = Configs.GPDEVICEMODE_Capture;
                        } else {
                          mode = Configs.GPDEVICEMODE_Record;
                        }
                        setState(() {});
                        dashcam.setModeStreaming(mode);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          mode == Configs.GPDEVICEMODE_Capture ? Icons.image : Icons.video_call,
                          size: 30,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListFileInfoUI(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.file_copy,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
