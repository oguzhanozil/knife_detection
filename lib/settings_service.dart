import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _cameraIpKey = 'camera_ip';
  static const String _galleryIpKey = 'gallery_ip';
  
  // Varsayılan IP adresleri
  static const String defaultCameraIp = '192.168.1.34:5000';
  static const String defaultGalleryIp = '192.168.1.34:5001';
  
  // IP adreslerini kaydetme
  static Future<void> saveCameraIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cameraIpKey, ip);
  }
  
  static Future<void> saveGalleryIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_galleryIpKey, ip);
  }
  
  // IP adreslerini yükleme
  static Future<String> getCameraIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cameraIpKey) ?? defaultCameraIp;
  }
  
  static Future<String> getGalleryIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_galleryIpKey) ?? defaultGalleryIp;
  }
  
  // Tam URL'leri oluşturma
  static Future<String> getCameraStreamUrl() async {
    final ip = await getCameraIp();
    return 'http://$ip/video_feed';
  }
  
  static Future<String> getGalleryApiUrl() async {
    final ip = await getGalleryIp();
    return 'http://$ip/camera_records';
  }
}