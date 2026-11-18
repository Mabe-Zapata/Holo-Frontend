import 'package:material_ui/material_ui.dart';

/// Paleta y tipografía de Holo, tomadas del diseño aprobado.
///
/// Verde menta para superficies y marca, mostaza para acciones y pasteles para
/// el resto. Ningún texto baja de 14 px (guía de estilo, UX-01).
class HoloTema {
  HoloTema._();

  static const Color marca = Color(0xFF005752);
  static const Color mentaContenedor = Color(0xFF25706A);
  static const Color mostaza = Color(0xFFFDBE50);
  static const Color mostazaTexto = Color(0xFF714D00);
  static const Color superficie = Color(0xFFEDFDF9);
  static const Color superficieBaja = Color(0xFFE7F7F3);
  static const Color superficieAlta = Color(0xFFDCECE8);
  static const Color texto = Color(0xFF101E1C);
  static const Color textoSuave = Color(0xFF3F4947);
  static const Color pastelCrisis = Color(0xFFFFDAD6);
  static const Color rosaCrisis = Color(0xFF8B2C2A);

  static ThemeData get claro => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: marca,
          onPrimary: Colors.white,
          primaryContainer: mentaContenedor,
          onPrimaryContainer: Color(0xFFA9F1E9),
          secondary: mostazaTexto,
          onSecondary: Colors.white,
          secondaryContainer: mostaza,
          onSecondaryContainer: Color(0xFF281900),
          surface: superficie,
          onSurface: texto,
          surfaceContainerLow: superficieBaja,
          surfaceContainerHigh: superficieAlta,
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          outline: Color(0xFF6F7977),
        ),
        scaffoldBackgroundColor: superficie,
        appBarTheme: const AppBarTheme(
          backgroundColor: superficie,
          foregroundColor: texto,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        textTheme: const TextTheme(
          headlineSmall:
              TextStyle(fontSize: 26, fontWeight: FontWeight.w600, height: 1.3),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(fontSize: 15, height: 1.5),
          bodySmall: TextStyle(fontSize: 14, height: 1.5),
          labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: mostaza,
            foregroundColor: const Color(0xFF281900),
            disabledBackgroundColor: superficieAlta,
            disabledForegroundColor: const Color(0xFF6F7977),
            minimumSize: const Size(double.infinity, 52),
            shape: const StadiumBorder(),
          ),
        ),
      );
}
