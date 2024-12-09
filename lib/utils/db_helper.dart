import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as g;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/image_data.dart';
part 'db_helper.g.dart';

class DBHelper {
  static Future<Database> _getDatabase() async {
    databaseFactory = databaseFactoryFfi;
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

// 定义一个表
class Images extends Table {
  IntColumn get id => integer().autoIncrement()(); // 自动递增的主键
  TextColumn get name => text().withLength(min: 1, max: 200)(); // 名称字段
  TextColumn get url => text().withLength(min: 1, max: 500)(); // 可空的年龄字段
}


@DriftDatabase(tables: [Images])
class AppDatabase extends _$AppDatabase {
  AppDatabase._create() : super(_openConnection());

  static  AppDatabase? _db;

  factory AppDatabase.get() => _db ??= AppDatabase._create();

  @override
  int get schemaVersion => 1;

  Future<int> insertImage(Image imageData) =>
      into(images).insert(ImagesCompanion.insert(name: imageData.name, url: imageData.url));

  Future<List<Image>> getAllImages() => select(images).get();

  Future<int> deleteImage(int id) =>
      (delete(images)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> clearAllImages() => delete(images).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    if (kDebugMode) {
      print(join(directory.path, 'images.db'));
    }
    final file = File(join(directory.path, 'images.db'));
    return NativeDatabase(file);
  });
}
