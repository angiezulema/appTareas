import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import '../utils/app_colors.dart'; // Asegúrate que esta ruta es correcta

// Opcional, si necesitas inicializar formatos de fecha específicos al inicio:
// import 'package:intl/date_symbol_data_local.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // Descomentar si es necesario para plugins
  // initializeDateFormatting('es_ES', null).then((_) => runApp(const MyApp())); // Opcional
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Tareas App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        // Definir colorScheme puede ser útil para la consistencia de colores en widgets de Material
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: AppColors.accentBlue, // Color de acento
          primary: AppColors.primaryBlue, // Color primario
        ),
        appBarTheme: AppBarTheme( // Estilo global para AppBar si no se sobreescribe
          elevation: 0, // Sin elevación por defecto para un look más plano
          iconTheme: IconThemeData(color: AppColors.darkGreyText), // Color de iconos en AppBar
          titleTextStyle: TextStyle(color: AppColors.darkGreyText, fontSize: 20, fontWeight: FontWeight.w500),
        )
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // Inglés
        const Locale('es', 'ES'), // Español de España
      ],
      locale: const Locale('es', 'ES'), // Establecer español como locale por defecto
      home: const HomeScreen(),
    );
  }
}