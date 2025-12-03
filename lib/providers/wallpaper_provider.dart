import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallpaper_model.dart';
import '../services/api_service.dart';

class WallpaperProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<WallpaperModel> _wallpapers = [];
  List<WallpaperModel> get wallpapers => _wallpapers;

  List<WallpaperModel> _favorites = [];
  List<WallpaperModel> get favorites => _favorites;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  int _page = 1;

  WallpaperProvider() {
    _loadFavorites();
    fetchCuratedWallpapers();
  }

  Future<void> _loadFavorites() async {
    final box = await Hive.openBox('favorites');
    _favorites = box.values
        .map((e) => WallpaperModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> toggleFavorite(WallpaperModel wallpaper) async {
    final box = await Hive.openBox('favorites');
    if (_favorites.any((element) => element.id == wallpaper.id)) {
      _favorites.removeWhere((element) => element.id == wallpaper.id);
      await box.delete(wallpaper.id);
    } else {
      _favorites.add(wallpaper);
      await box.put(wallpaper.id, wallpaper.toJson());
    }
    notifyListeners();
  }

  bool isFavorite(int id) {
    return _favorites.any((element) => element.id == id);
  }

  Future<void> fetchCuratedWallpapers({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _wallpapers = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newWallpapers = await _apiService.getCuratedWallpapers(page: _page);
      _wallpapers.addAll(newWallpapers);
      _page++;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchWallpapers(String query) async {
    _isLoading = true;
    _wallpapers = []; // Clear current list for search results
    notifyListeners();

    try {
      final newWallpapers = await _apiService.searchWallpapers(query: query);
      _wallpapers = newWallpapers;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
