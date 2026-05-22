import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_IN', null); // Fix locale data for Indian number/date formatting
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MigrantPayApp());
}

class MigrantPayApp extends StatelessWidget {
  const MigrantPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'MigrantPay',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const SplashScreen(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
