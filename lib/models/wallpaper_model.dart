class WallpaperModel {
  final int id;
  final String url;
  final String photographer;
  final String photographerUrl;
  final SrcModel src;
  bool isFavorite;

  WallpaperModel({
    required this.id,
    required this.url,
    required this.photographer,
    required this.photographerUrl,
    required this.src,
    this.isFavorite = false,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'],
      url: json['url'],
      photographer: json['photographer'],
      photographerUrl: json['photographer_url'],
      src: SrcModel.fromJson(json['src']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'photographer': photographer,
      'photographer_url': photographerUrl,
      'src': src.toJson(),
    };
  }
}

class SrcModel {
  final String original;
  final String large2x;
  final String large;
  final String medium;
  final String small;
  final String portrait;
  final String landscape;
  final String tiny;

  SrcModel({
    required this.original,
    required this.large2x,
    required this.large,
    required this.medium,
    required this.small,
    required this.portrait,
    required this.landscape,
    required this.tiny,
  });

  factory SrcModel.fromJson(Map<String, dynamic> json) {
    return SrcModel(
      original: json['original'],
      large2x: json['large2x'],
      large: json['large'],
      medium: json['medium'],
      small: json['small'],
      portrait: json['portrait'],
      landscape: json['landscape'],
      tiny: json['tiny'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'large2x': large2x,
      'large': large,
      'medium': medium,
      'small': small,
      'portrait': portrait,
      'landscape': landscape,
      'tiny': tiny,
    };
  }
}
