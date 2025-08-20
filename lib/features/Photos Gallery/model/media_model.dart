// class Media {
//   final int idMedia;
//   final String? audioBase64;
//   final String? imageBase64;

//   Media({required this.idMedia, this.audioBase64, this.imageBase64});

//   factory Media.fromJson(Map<String, dynamic> json) {
//     return Media(
//       idMedia: json['idimage'] ?? 0,
//       audioBase64: json['audio_base64'], 
//       imageBase64: json['image_base64'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'idimage': idMedia,
//       'audio_base64': audioBase64,
//       'image_base64': imageBase64,
//     };
//   }

//   bool get hasAudio => audioBase64 != null && audioBase64!.isNotEmpty;
//   bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;
//   bool get hasMedia => hasAudio || hasImage;
// }
