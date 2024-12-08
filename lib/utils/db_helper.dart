import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/image_data.dart';

class DBHelper {
  static Future<Database> _getDatabase() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      // 初始化 databaseFactoryFfi
      databaseFactory = databaseFactoryFfi;
    }

    // 获取数据库路径
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'images.db'); // 拼接数据库文件路径

    // 打开数据库（如果数据库不存在，则创建）
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      // 创建表格
      await db.execute('''
        CREATE TABLE Images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          url TEXT
        )
      ''');
    });
  }

  static Future<void> insertImage(ImageData imageData) async {
    final db = await _getDatabase();
    await db.insert('Images', imageData.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<ImageData>> getAllImages() async {
    final db = await _getDatabase();
    var result = await db.query('Images');
    return result.map((e) => ImageData.fromMap(e)).toList();
  }

  static Future<void> deleteImage(int id) async {
    final db = await _getDatabase();
    await db.delete('Images', where: 'id = ?', whereArgs: [id]);
  }


  // 新增：清空所有图片数据
  static Future<void> clearAllImages() async {
    final db = await _getDatabase();
    await db.delete('Images');  // 删除所有数据
  }
}
