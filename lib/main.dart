import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garudahub/core/constants/constants.dart';
import 'package:garudahub/core/database/db_helper.dart';
import 'package:garudahub/features/chant/widgets/chant_animation_overlay.dart';
import 'package:garudahub/features/news/providers/news_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'features/splash/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'core/theme/app_theme.dart';

import 'package:garudahub/features/chant/providers/chant_provider.dart';
import 'package:garudahub/features/shop/merchandise/providers/merchandise_provider.dart';
import 'package:garudahub/features/shop/ticket/providers/ticket_provider.dart';
import 'package:garudahub/features/shop/providers/currency_provider.dart';
import 'package:garudahub/core/providers/timezone_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.database;
  tz.initializeTimeZones();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Kunci orientasi portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChantProvider()..init()),
        ChangeNotifierProvider(create: (_) => MerchandiseProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()..init()),
        ChangeNotifierProvider(create: (_) => TimezoneProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: const GarudaHubApp(),
    ),
  );
}

class GarudaHubApp extends StatelessWidget {
  const GarudaHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GarudaHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },

      builder: (context, child) {
        // Status bar & nav bar adaptive sesuai tema
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
              isDark ? const Color(0xFF0A0A0A) : Colors.white,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ));

        final auth = context.watch<AuthProvider>();
        final chant = context.read<ChantProvider>();

        if (auth.isAuthenticated && chant.isEnabled && !chant.isListening) {
          chant.start();
        }

        if (!auth.isAuthenticated && chant.isListening) {
          chant.stop();
        }

        return Stack(children: [child!, const ChantAnimationOverlay()]);
      },
    );
  }
}
