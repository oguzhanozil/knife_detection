import 'package:flutter/material.dart';
import 'settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _cameraIpController = TextEditingController();
  final _galleryIpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    final cameraIp = await SettingsService.getCameraIp();
    final galleryIp = await SettingsService.getGalleryIp();
    
    setState(() {
      _cameraIpController.text = cameraIp;
      _galleryIpController.text = galleryIp;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      await SettingsService.saveCameraIp(_cameraIpController.text);
      await SettingsService.saveGalleryIp(_galleryIpController.text);
      
      setState(() {
        _isLoading = false;
      });
      
      // Kullanıcıya başarılı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String? _validateIpAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'IP adresi gerekli';
    }
    
    // Basit bir IP:port formatı doğrulaması
    final parts = value.split(':');
    if (parts.length != 2) {
      return 'Geçerli bir IP:Port formatı girin (ör. 192.168.1.1:5000)';
    }
    
    return null;
  }

  @override
  void dispose() {
    _cameraIpController.dispose();
    _galleryIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sunucu Bağlantı Ayarları',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Canlı kamera ve galeri için sunucu bağlantı adreslerini giriniz. Format: IP:Port (örn. 192.168.1.1:5000)',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Canlı Kamera IP Adresi
                    TextFormField(
                      controller: _cameraIpController,
                      decoration: const InputDecoration(
                        labelText: 'Canlı Kamera IP:Port',
                        hintText: '192.168.1.34:5000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.videocam),
                      ),
                      validator: _validateIpAddress,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Galeri IP Adresi
                    TextFormField(
                      controller: _galleryIpController,
                      decoration: const InputDecoration(
                        labelText: 'Galeri API IP:Port',
                        hintText: '192.168.1.34:5001',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.photo_library),
                      ),
                      validator: _validateIpAddress,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Kaydetme Düğmesi
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save),
                        label: const Text('Ayarları Kaydet'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Sıfırlama Düğmesi
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _cameraIpController.text = SettingsService.defaultCameraIp;
                            _galleryIpController.text = SettingsService.defaultGalleryIp;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Varsayılan Değerlere Sıfırla'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}