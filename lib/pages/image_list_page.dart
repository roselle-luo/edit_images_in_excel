import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_app/utils/db_helper.dart';
import 'package:my_app/models/image_data.dart';
import 'package:my_app/utils/excel_utils.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class ImageListPage extends StatefulWidget {
  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  List<ImageData> images = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  _loadImages() async {
    List<ImageData> imageList = await DBHelper.getAllImages();
    setState(() {
      images = imageList;
    });
  }

  _deleteImage(int id) async {
    await DBHelper.deleteImage(id);
    _loadImages();  // Reload images after deletion
  }

  _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xls', 'xlsx']);

    if (result != null) {
      File file = File(result.files.single.path!);
      await importExcel(file);
      _loadImages();  // Reload images after importing Excel file
    }
  }

_exportToExcel() async {
  // 创建一个 Excel 工作簿
  var excel = Excel.createExcel();
  
  // 添加一个工作表
  Sheet sheet = excel['Sheet1'];

  // 添加标题行
  sheet.appendRow(['Name', 'URL']);

  // 添加图片数据
  for (var image in images) {
    sheet.appendRow([image.name, image.url]);
  }

  // 根据平台获取桌面路径
  String? desktopPath;
  if (Platform.isMacOS) {
    desktopPath = '/Users/jiangxiyu/Desktop';  // 修改为正确的桌面路径
  } else if (Platform.isWindows) {
    desktopPath = '${Platform.environment['USERPROFILE']}\\Downloads';
  } else if (Platform.isLinux) {
    desktopPath = '${Platform.environment['HOME']}/Desktop';
  }
  
  // 如果桌面路径未找到
  if (desktopPath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('无法获取桌面路径'))
    );
    return;
  }

  final path = '$desktopPath/exported_images.xlsx';

  // 将 Excel 数据写入文件
  final excelData = excel.encode();
  final file = File(path);
  await file.writeAsBytes(excelData!);

  // 显示导出成功的提示
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('数据已导出到桌面：$path')),
  );
}

  _clearDatabase() async {
    await DBHelper.clearAllImages();
    _loadImages();  // Reload images after clearing the database
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('数据库已清空')));
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('图片列表'),
        ),
        body: Center(child: Text('没有图片数据')),
        floatingActionButton: FloatingActionButton(
          onPressed: _importExcel,
          child: Icon(Icons.file_upload),
        ),
      );
    }

    var currentImage = images[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('图片列表'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportToExcel,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(currentImage.url, width: 200, height: 200),
            Text(currentImage.name),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: currentIndex > 0
                      ? () {
                          setState(() {
                            currentIndex--;
                          });
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: currentIndex < images.length - 1
                      ? () {
                          setState(() {
                            currentIndex++;
                          });
                        }
                      : null,
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteImage(currentImage.id!);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importExcel,
        child: Icon(Icons.file_upload),
      ),
      // 添加清空数据库的按钮
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _clearDatabase,
          child: Text('清空数据库'),
        ),
      ),
    );
  }
}
