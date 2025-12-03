import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/wallpaper_provider.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'dart:typed_data';
import '../models/wallpaper_model.dart';

class DetailScreen extends StatefulWidget {
  final WallpaperModel wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDownloading = false;
  bool _isSettingWallpaper = false;

  Future<void> _downloadWallpaper() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      setState(() {
        _isDownloading = true;
      });
      try {
        var response = await http.get(Uri.parse(widget.wallpaper.src.original));
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.bodyBytes),
          quality: 100,
          name: "wallpaper_${widget.wallpaper.id}",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['isSuccess'] ? 'Saved to Gallery' : 'Failed to save',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Permission denied')));
      }
    }
  }

  // ... inside _DetailScreenState ...

  Future<void> _setWallpaper(int location) async {
    setState(() {
      _isSettingWallpaper = true;
    });
    try {
      var file = await DefaultCacheManager().getSingleFile(
        widget.wallpaper.src.original,
      );

      // 1: Home, 2: Lock, 3: Both
      String result;
      if (location == 1) {
        await WallpaperManagerPlus().setWallpaper(
          file,
          WallpaperManagerPlus.homeScreen,
        );
        result = 'Wallpaper Set on Home Screen';
      } else if (location == 2) {
        await WallpaperManagerPlus().setWallpaper(
          file,
          WallpaperManagerPlus.lockScreen,
        );
        result = 'Wallpaper Set on Lock Screen';
      } else {
        await WallpaperManagerPlus().setWallpaper(
          file,
          WallpaperManagerPlus.bothScreens,
        );
        result = 'Wallpaper Set on Both Screens';
      }

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSettingWallpaper = false;
        });
      }
    }
  }

  void _showSetWallpaperDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home Screen'),
            onTap: () {
              Navigator.pop(context);
              _setWallpaper(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Lock Screen'),
            onTap: () {
              Navigator.pop(context);
              _setWallpaper(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.smartphone),
            title: const Text('Both Screens'),
            onTap: () {
              Navigator.pop(context);
              _setWallpaper(3);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Hero(
            tag: widget.wallpaper.id,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                imageUrl: widget.wallpaper.src.portrait,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'download',
                  onPressed: _isDownloading ? null : _downloadWallpaper,
                  backgroundColor: Colors.white,
                  child: _isDownloading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.download, color: Colors.black),
                ),
                FloatingActionButton.extended(
                  heroTag: 'set',
                  onPressed: _isSettingWallpaper
                      ? null
                      : _showSetWallpaperDialog,
                  backgroundColor: Colors.deepPurple,
                  label: _isSettingWallpaper
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Set Wallpaper',
                          style: TextStyle(color: Colors.white),
                        ),
                  icon: const Icon(Icons.wallpaper, color: Colors.white),
                ),
                Consumer<WallpaperProvider>(
                  builder: (context, provider, child) {
                    final isFav = provider.isFavorite(widget.wallpaper.id);
                    return FloatingActionButton(
                      heroTag: 'favorite',
                      onPressed: () {
                        provider.toggleFavorite(widget.wallpaper);
                      },
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
