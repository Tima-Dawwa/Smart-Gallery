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

  // Helper method to validate and fix image URLs
  static String _validateImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'assets/travel.jpeg'; // Default fallback
    }

    // If it's a relative path that starts with /static/ or /assets/
    if (imageUrl.startsWith('/static/') || imageUrl.startsWith('/assets/')) {
      // Convert to proper asset path
      String assetPath = imageUrl.replaceFirst(RegExp(r'^/'), '');

      // If it's a static path, convert to assets
      if (assetPath.startsWith('static/images/')) {
        assetPath = assetPath.replaceFirst('static/images/', 'assets/');
      }

      return assetPath;
    }

    // If it's already a proper asset path
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }

    // If it's a proper network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // For any other case, treat as asset
    return imageUrl.startsWith('assets/') ? imageUrl : 'assets/$imageUrl';
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse integers
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
      // FIXED: Check for 'idfolder' first (matches API response)
      idFolder: parseIntValue(
        json['idfolder'] ?? json['id_folder'] ?? json['idFolder'] ?? json['id'],
        0,
      ),
      // Use the helper method to validate image URLs
      image: _validateImageUrl(
        json['image'] ?? json['cover_image'] ?? json['coverImage'],
      ),
      password: json['password']?.toString(), // Ensure it's a string
      photoCount: parseIntValue(json['photo_count'] ?? json['photoCount'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folderName': folderName,
      'has_password': hasPassword,
      'idfolder': idFolder, // Changed to match API format
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
      'id': idFolder, // Keep as int instead of converting to string
      'name': folderName,
      'photoCount': photoCount ?? 0,
      'coverImage': image,
      'isLocked': isLocked,
      'password': password,
    };
  }

  // Create Folder from UI Map format
  factory Folder.fromUIMap(Map<String, dynamic> uiMap) {
    // Helper function to safely parse integers
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
      image: _validateImageUrl(uiMap['coverImage']),
      password: uiMap['password']?.toString(), // Ensure it's a string
      photoCount: parseIntValue(uiMap['photoCount'], 0),
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
      image: image != null ? _validateImageUrl(image) : this.image,
      password: password ?? this.password,
      photoCount: photoCount ?? this.photoCount,
    );
  }

  @override
  String toString() {
    return 'Folder{folderName: $folderName, hasPassword: $hasPassword, idFolder: $idFolder, image: $image, password: $password, photoCount: $photoCount}';
  }
}
