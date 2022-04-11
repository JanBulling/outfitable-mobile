import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'technologies/local_storage/database.dart';
import 'utils/routes.dart';
import 'utils/dependency_injection.dart' as injector;
import 'utils/theme/theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // make the app only in portrait-mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // initializing dependency injection
  injector.init();

  // load the .env file with sensible data
  await dotenv.load(fileName: ".env");

  // initializing the local database
  await Database.initDatabase();

  runApp(const OutfitableApp());
}

class OutfitableApp extends StatelessWidget {
  const OutfitableApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outfitable Mobile App',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Routes.generateRoute,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
      ],
    );
  }
}
