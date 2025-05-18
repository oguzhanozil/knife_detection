import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  VlcPlayerController? _vlcController;
  String? _streamUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadStreamUrl();
  }

  Future<void> _loadStreamUrl() async {
    try {
      final url = await SettingsService.getCameraStreamUrl();
      setState(() {
        _streamUrl = url;
        _vlcController = VlcPlayerController.network(
          _streamUrl!,
          hwAcc: HwAcc.full,
          autoPlay: true,
          options: VlcPlayerOptions(),
        );
        _isLoading = false;
      });

      testServerConnection(url);
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Hata oluştu: $e');
    }
  }

  void testServerConnection(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("Sunucuya başarıyla bağlanıldı!");
      } else {
        print("Bağlantı başarısız: ${response.statusCode}");
      }
    } catch (e) {
      print("Sunucuya bağlanılamadı: $e");
    }
  }

  @override
  void dispose() {
    _vlcController?.stopRendererScanning();
    _vlcController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera Akışı'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text('Kamera akışı yüklenemedi'))
              : VlcPlayer(
                  controller: _vlcController!,
                  aspectRatio: 16 / 9,
                  placeholder: const Center(child: CircularProgressIndicator()),
                ),
    );
  }
}
