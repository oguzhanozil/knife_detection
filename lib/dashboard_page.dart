import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'settings_service.dart';
import 'camera_page.dart';
import 'gallery_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _cameraIp = '';
  String _galleryIp = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final cameraIp = await SettingsService.getCameraIp();
    final galleryIp = await SettingsService.getGalleryIp();
    
    setState(() {
      _cameraIp = cameraIp;
      _galleryIp = galleryIp;
      _isLoading = false;
    });
  }

  String _getCurrentDate() {
  final now = DateTime.now();
  final formatter = DateFormat('dd MMMM yyyy');
  return formatter.format(now);
}
  String _getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik Kamera Sistemi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
              _loadSettings(); // Ayarlar güncellenmiş olabilir
            },
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarih ve Saat Kartı
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 36,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getCurrentDate(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getCurrentTime(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bağlantı Durumu
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sistem Bağlantı Bilgileri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _connectionInfoRow(
                            'Canlı Kamera',
                            _cameraIp,
                            Icons.videocam,
                            Colors.blue,
                          ),
                          const Divider(),
                          _connectionInfoRow(
                            'Galeri API',
                            _galleryIp,
                            Icons.photo_library,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Ana İşlevler
                  const Text(
                    'Hızlı Erişim',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // İşlev Butonları Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        context,
                        'Canlı Kamera',
                        Icons.videocam,
                        Colors.red,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  CameraPage(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Kayıtlar',
                        Icons.photo_library,
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GalleryPage(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Ayarlar',
                        Icons.settings,
                        Colors.orange,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context,
                        'Yardım',
                        Icons.help_outline,
                        Colors.blue,
                        () {
                          // Yardım sayfası veya dialog gösterilebilir
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Yardım & Hakkında'),
                              content: const Text(
                                'Bu uygulama, güvenlik kamera sistemini kontrol etmek ve kayıtları görüntülemek için tasarlanmıştır.\n\n'
                                'IP adreslerini değiştirmek için Ayarlar sayfasını kullanabilirsiniz.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tamam'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _connectionInfoRow(
      String title, String address, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'http://$address',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}