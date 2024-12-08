class ImageData {
  final int? id;
  final String name;
  final String url;

  ImageData({this.id, required this.name, required this.url});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }

  static ImageData fromMap(Map<String, dynamic> map) {
    return ImageData(
      id: map['id'],
      name: map['name'],
      url: map['url'],
    );
  }
}
