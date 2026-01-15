import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/controllers/auth_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Routes dan binding global
import 'routes/app_pages.dart';
import 'bindings/app_binding.dart';

// Splash screen
import 'pages/splash_page.dart';

// Tambahkan import untuk MenuDosenController
import 'package:inta301/controllers/menu_dosen_controller.dart';
// Alert service
import 'package:inta301/shared/alert_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  Get.put(AuthController(), permanent: true);

  // Tambahkan inisialisasi controller dosen
  Get.put(MenuDosenController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'INTA301',
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        primaryColor: const Color(0xFF88BDF2),
        scaffoldBackgroundColor: Colors.white,
      ),

      // Global binding
      initialBinding: AppBinding(),

      // 👇 Gunakan route splash dari AppPages
      initialRoute: Routes.SPLASH,

      // 👇 Gabungkan route dari AppPages + Splash
      getPages: [
        GetPage(
          name: Routes.SPLASH,
          page: () => const SplashPage(),
        ),
        ...AppPages.routes,
      ],

      // Dukungan lokal Indonesia
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
      ],
    );
  }
}
