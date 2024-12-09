import 'dart:io';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'db_helper.dart';

Future<void> importExcel(File file) async {
  try {
    // 读取文件字节数据
    var bytes = await file.readAsBytes();
    
    // 解码 Excel 文件
    var excel = Excel.decodeBytes(bytes);

    if (excel == null) return;

    var images = <Image>[];

    // 遍历 Excel 表格的所有 sheet
    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]?.rows ?? [];
      for (var row in rows) {
        // 确保每行至少有两列数据
        
        if (row.length >= 2) {
          // 提取名称和 URL
          
          var name = _getStringValue(row[0]?.value);
          
          var url = _extractUrl(_getStringValue(row[1]?.value));
          // 如果提取到有效的名称和 URL，添加到图片数据列表
          if (name != null && url != null) {
            images.add(Image(name: name, url: url, id: 0));
          }
        }
      }
    }
    // 将提取的图片数据存储到数据库
    for (var imageData in images) {
      await AppDatabase.get().insertImage(imageData);
    }
  } catch (e) {
    print("Error importing Excel file: $e");
  }
}

// 辅助函数，用于确保从 Excel 行中提取的数据是字符串
String? _getStringValue(dynamic value) {
  if (value == null) return null;

  // 如果是日期类型，转换为字符串
  if (value is DateTime) {
    return value.toIso8601String();
  }
  
  // 如果是其他类型，直接转换为字符串
  return value.toString();
}

// 从单元格字符串中提取有效的 URL
String? _extractUrl(String? value) {
  if (value == null) return null;

  // 使用正则表达式提取 URL
  final regex = RegExp(r'https?://[^\s,]+');
  final match = regex.firstMatch(value);
  if (match != null) {
    return match.group(0);  // 返回第一个匹配的 URL
  }

  return null;  // 如果没有找到有效 URL，则返回 null
}
