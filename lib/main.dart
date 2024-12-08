import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/image_list_page.dart';

void main() async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    // 只在非移动平台初始化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '图片管理软件',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageListPage(),
    );
  }
}
