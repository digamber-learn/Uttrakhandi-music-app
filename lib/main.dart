import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/player_provider.dart';
import 'providers/songs_provider.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const UttrakhandiMusicApp());
}

class UttrakhandiMusicApp extends StatelessWidget {
  const UttrakhandiMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongsProvider()..load()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'Uttrakhandi Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF81C784),
            surface: Color(0xFF0D1F0E),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D1F0E),
          useMaterial3: true,
        ),
        home: const MainShell(),
      ),
    );
  }
}
