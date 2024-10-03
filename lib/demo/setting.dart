import 'dart:async';

import 'package:dashcam/index.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingUI extends StatefulWidget {
  SettingUI();

  @override
  _SettingUIState createState() => _SettingUIState();
}

class _SettingUIState extends State<SettingUI> {
  DashcamPlatform dashcam = DashcamPlatform.instance;
  String password = '123456789';

  @override
  void initState() {
    dashcam.startSetting();
    super.initState();
  }

  initData() async {
    Map? resultSetting = await dashcam.startSetting();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        dashcam.finishSetting();
        return Future.value(true);
      },
      child: Material(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Setting'),
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              InkWell(
                onTap: () {
                  dashcam.changePassword('1234567A');
                },
                child: renderSettngItem('Wifi Address', password),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderSettngItem(String title, String value) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(12),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
          const Gap(4),
          const Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
