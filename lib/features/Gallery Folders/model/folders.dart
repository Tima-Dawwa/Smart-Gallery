class Folder {
  final String folderName;
  final int hasPassword;
  final int idFolder;
  final String image;
  final String? password;
  final int? photoCount;

  Folder({
    required this.folderName,
    required this.hasPassword,
    required this.idFolder,
    required this.image,
    this.password,
    this.photoCount = 0,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      folderName: json['folder_name'] ?? json['folderName'] ?? '',
      hasPassword: json['has_password'] ?? json['hasPassword'] ?? 0,
      idFolder: json['id_folder'] ?? json['idFolder'] ?? json['id'] ?? 0,
      image:
          json['image'] ??
          json['cover_image'] ??
          json['coverImage'] ??
          'assets/travel.jpeg',
      password: json['password'],
      photoCount: json['photo_count'] ?? json['photoCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder_name': folderName,
      'has_password': hasPassword,
      'id_folder': idFolder,
      'image': image,
      'password': password,
      'photo_count': photoCount,
    };
  }

  // Helper getters for UI
  bool get isLocked => hasPassword == 1;
  String get name => folderName;
  String get id => idFolder.toString();
  String get coverImage => image;

  // Convert to Map format used by UI components
  Map<String, dynamic> toUIMap() {
    return {
      'id': idFolder.toString(),
      'name': folderName,
      'photoCount': photoCount ?? 0,
      'coverImage': image,
      'isLocked': isLocked,
      'password': password,
    };
  }

  // Create Folder from UI Map format
  factory Folder.fromUIMap(Map<String, dynamic> uiMap) {
    return Folder(
      folderName: uiMap['name'] ?? '',
      hasPassword: (uiMap['isLocked'] ?? false) ? 1 : 0,
      idFolder: int.tryParse(uiMap['id'].toString()) ?? 0,
      image: uiMap['coverImage'] ?? 'assets/travel.jpeg',
      password: uiMap['password'],
      photoCount: uiMap['photoCount'] ?? 0,
    );
  }

  // Create a copy with updated values
  Folder copyWith({
    String? folderName,
    int? hasPassword,
    int? idFolder,
    String? image,
    String? password,
    int? photoCount,
  }) {
    return Folder(
      folderName: folderName ?? this.folderName,
      hasPassword: hasPassword ?? this.hasPassword,
      idFolder: idFolder ?? this.idFolder,
      image: image ?? this.image,
      password: password ?? this.password,
      photoCount: photoCount ?? this.photoCount,
    );
  }
}
