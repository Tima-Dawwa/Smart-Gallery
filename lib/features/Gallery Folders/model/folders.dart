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
    int parseIntValue(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    }

    return Folder(
      folderName: json['folderName'] ?? json['folder_name'] ?? '',
      hasPassword: parseIntValue(
        json['has_password'] ?? json['hasPassword'],
        0,
      ),
      idFolder: parseIntValue(
        json['idfolder'] ?? json['id_folder'] ?? json['idFolder'] ?? json['id'],
        0,
      ),
      image: 
        json['image'] ?? json['cover_image'] ?? json['coverImage'],
    
      password: json['password']?.toString(), 
      photoCount: parseIntValue(json['photo_count'] ?? json['photoCount'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderName': folderName,
      'has_password': hasPassword,
      'idfolder': idFolder, 
      'image': image,
      'password': password,
      'photo_count': photoCount,
    };
  }

  bool get isLocked => hasPassword == 1;
  String get name => folderName;
  String get id => idFolder.toString();
  String get coverImage => image;

  Map<String, dynamic> toUIMap() {
    return {
      'id': idFolder, 
      'name': folderName,
      'photoCount': photoCount ?? 0,
      'coverImage': image,
      'isLocked': isLocked,
      'password': password,
    };
  }

  factory Folder.fromUIMap(Map<String, dynamic> uiMap) {
    int parseIntValue(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    }

    return Folder(
      folderName: uiMap['name'] ?? '',
      hasPassword: (uiMap['isLocked'] ?? false) ? 1 : 0,
      idFolder: parseIntValue(uiMap['id'], 0),
      image: uiMap['coverImage'],
      password: uiMap['password']?.toString(), 
      photoCount: parseIntValue(uiMap['photoCount'], 0),
    );
  }

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

  @override
  String toString() {
    return 'Folder{folderName: $folderName, hasPassword: $hasPassword, idFolder: $idFolder, image: $image, password: $password, photoCount: $photoCount}';
  }
}
