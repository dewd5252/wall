import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  final List<Map<String, String>> categories = const [
    {
      'name': 'Nature',
      'image':
          'https://images.pexels.com/photos/3408744/pexels-photo-3408744.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'name': 'Abstract',
      'image':
          'https://images.pexels.com/photos/2471234/pexels-photo-2471234.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'name': 'Architecture',
      'image':
          'https://images.pexels.com/photos/1838640/pexels-photo-1838640.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'name': 'Cars',
      'image':
          'https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'name': 'Space',
      'image':
          'https://images.pexels.com/photos/1169754/pexels-photo-1169754.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'name': 'Animals',
      'image':
          'https://images.pexels.com/photos/47547/squirrel-animal-cute-rodents-47547.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Provider.of<WallpaperProvider>(
                context,
                listen: false,
              ).searchWallpapers(category['name']!);
              // Navigate to home or a specific results screen.
              // For now, we switch tab to Home (index 0) via a global key or similar,
              // but simpler is to push a search result page.
              // Let's just update the provider and maybe show a snackbar or navigate.
              // Better UX: Navigate to a "CategoryResultScreen" or reuse SearchScreen logic.
              // For simplicity in this overhaul, let's assume it updates Home.
              DefaultTabController.of(context).animateTo(0);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(category['image']!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
