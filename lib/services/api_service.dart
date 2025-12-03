import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper_model.dart';

class ApiService {
  // TODO: Replace with your actual Pexels API Key
  static const String _apiKey =
      'tNaACBCxqyW2ajNLIIkVDOfUucjxxsX2VF93fq8wDPKMs21JP0xTGCjg';
  static const String _baseUrl = 'https://api.pexels.com/v1';

  Future<List<WallpaperModel>> getCuratedWallpapers({
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/curated?page=$page&per_page=$perPage'),
      headers: {'Authorization': _apiKey},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> photos = data['photos'];
      return photos.map((json) => WallpaperModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  Future<List<WallpaperModel>> searchWallpapers({
    required String query,
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?query=$query&page=$page&per_page=$perPage'),
      headers: {'Authorization': _apiKey},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> photos = data['photos'];
      return photos.map((json) => WallpaperModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search wallpapers');
    }
  }
}
