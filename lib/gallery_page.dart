import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'cameraRecords.dart';
import 'video_player_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'settings_service.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<CameraRecords> _cameraRecords = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _galleryApiUrl = '';

  @override
  void initState() {
    super.initState();
    fetchCameraRecords();
  }

  Future<void> fetchCameraRecords() async {
    // Set loading state before starting
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // IP adresini ayarlardan al
      _galleryApiUrl = await SettingsService.getGalleryApiUrl();
      
      final response = await http
          .get(Uri.parse(_galleryApiUrl))
          .timeout(const Duration(seconds: 30));

      // Check if the widget is still mounted before calling setState
      if (!mounted) return;  // Early exit if the widget is disposed

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _cameraRecords = jsonData
              .map((item) => CameraRecords.fromJson(item))
              .toList();

          _cameraRecords.sort((a, b) => b.date.compareTo(a.date));
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Sunucudan veri alınamadı (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Check if the widget is still mounted before calling setState
      if (!mounted) return;  // Early exit if the widget is disposed

      setState(() {
        _hasError = true;
        _errorMessage = 'Bağlantı hatası: Sunucuya ulaşılamıyor';
        _isLoading = false;
      });
      print('Hata: $e');
    }
  

  // Geri kalan kodlar aynı kalacak...
  // Diğer metodlar da korunacak
}

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera Kayıtları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCameraRecords,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Kayıtlar yükleniyor...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchCameraRecords,
              icon: const Icon(Icons.refresh),
              label: const Text('Yeniden Dene'),
            ),
          ],
        ),
      );
    }

    if (_cameraRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kamera kaydı bulunmuyor',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _cameraRecords.length,
      itemBuilder: (context, index) {
        final record = _cameraRecords[index];
        final recordType = record.filePath.toLowerCase().endsWith('.mp4')
            ? 'video'
            : 'image';

        return GestureDetector(
          onTap: () {
            if (recordType == 'video') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerPage(filePath: record.filePath),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(filePath: record.filePath),
                ),
              );
            }
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
  child: Stack(
    fit: StackFit.expand,
    children: [
      CachedNetworkImage(
        imageUrl: recordType == 'video'
            ? 'placeholder-url-for-video-thumbnail' // Videolar için önizleme ekleyebilirsin
            : record.filePath, // Fotoğraflar için gerçek dosya URL'si

        placeholder: (context, url) => Container(
          color: Colors.grey[200], // Arka plan rengi
          child: const Center(
            child: CircularProgressIndicator(), // Yüklenirken gösterilecek animasyon
          ),
        ),

        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300], // Hata durumunda arka plan
          child: const Center(
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red, // Hata durumunda gösterilecek ikon
            ),
          ),
        ),

        fit: BoxFit.cover, // Resmin kutuya tam oturmasını sağlar
      ),

      if (recordType == 'video')
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
    ],
  ),
),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(record.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            recordType == 'video'
                                ? Icons.videocam
                                : Icons.photo,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recordType == 'video' ? 'Video' : 'Fotoğraf',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class FullScreenImage extends StatelessWidget {
  final String filePath;

  const FullScreenImage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görüntü'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Hero(
              tag: filePath,
              child: Image.network(
                filePath,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Görüntü yüklenemedi',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Görüntü yeniden yükleniyor...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Yeniden Dene'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}