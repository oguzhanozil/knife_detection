import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dashboard_page.dart';
import 'camera_page.dart';
import 'gallery_page.dart';
import 'settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      print("Firebase başlatılırken hata oluştu: $e");
      // Hata durumunda kullanıcıya bilgi verebilirsiniz.
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Kullanıcı bildirim izni verdi: ${settings.authorizationStatus}');

      String? token;
      try {
        token = await messaging.getToken();
        print('FCM Token: $token');
      } catch (e) {
        print('Token alınırken hata oluştu: $e');
      }

      try {
        await messaging.subscribeToTopic('all');
        print('Başarıyla "all" konusuna abone olundu.');
      } catch (e) {
        print('Konuya abone olurken hata oluştu: $e');
      }

      messaging.onTokenRefresh.listen((newToken) async {
        print('Yeni FCM Token: $newToken');
        try {
          await messaging.subscribeToTopic('all');
          print('Yeni token ile "all" konusuna abone olundu.');
        } catch (e) {
          print('Yeni token ile konuya abone olurken hata oluştu: $e');
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Ön planda mesaj alındı: ${message.notification?.body}');
        _showNotificationDialog(message.notification!);
      }, onError: (e) {
        print('onMessage hata: $e');
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } else {
      print('Kullanıcı bildirim izni vermedi: ${settings.authorizationStatus}');
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print("Arka planda mesaj işleniyor: ${message.notification?.body}");
      // Arka planda bildirim işleme mantığını buraya ekleyebilirsiniz.
    } catch (e) {
      print('Arka plan işleyicide Firebase başlatılırken hata: $e');
    }
  }

  void _showNotificationDialog(RemoteNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(notification.title ?? "Yeni Bildirim"),
        content: Text(notification.body ?? "Bildirim içeriği"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          DashboardPage(),
          CameraPage(),
          GalleryPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Kamera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}