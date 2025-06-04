import 'package:flutter/material.dart';

class AppColors {
  // --- Colores principales basados en la imagen de referencia ---
  static const Color headerBlue = Color(0xFF2F80ED); // Azul del header en la imagen de referencia
  static const Color fabBlue = Color(0xFF2F80ED);    // Azul del FloatingActionButton, igual al header
  static const Color favoriteStarBlue = Color(0xFF2F80ED); // Azul para el icono de estrella de Favoritos

  // --- Colores de Texto ---
  static const Color textWhite = Colors.white;                 // Texto blanco (ej. en el header)
  static const Color sectionTitleDark = Color(0xFF333333);    // Para títulos de sección como "Favoritos", "Mis Tareas"
  static const Color taskItemTextDark = Color(0xFF4F4F4F);    // Texto principal del título de las tareas
  static const Color taskItemTextLight = Color(0xFF828282);   // Texto secundario (categoría, fecha) en los items de tarea
  static const Color searchHintGrey = Color(0xFFBDBDBD);      // Color para el texto de placeholder y el icono en la barra de búsqueda

  // --- Colores de UI Elementos ---
  static const Color searchBackground = Color(0xFFF2F2F2); // Fondo de la barra de búsqueda (un gris muy claro)
  static const Color taskItemCheckboxBorder = Color(0xFFE0E0E0); // Borde del checkbox circular cuando no está marcado
  static const Color taskCategoryTagBackground = Color(0xFFEAF2FD); // Fondo para los tags de categoría (un azul muy pálido)
  static const Color taskCategoryTagText = Color(0xFF2F80ED);     // Texto para los tags de categoría (azul)

  // --- Tus colores originales (puedes mantenerlos o unificarlos con los de arriba) ---
  // Es bueno tener una paleta consistente. Si los de arriba cubren tus necesidades,
  // podrías considerar eliminar duplicados o renombrarlos.
  static const Color primaryBlue = Color(0xFF2962FF);       // Este es el que estabas usando como primario
  static const Color lightBlueBackground = Color(0xFFE3F2FD); // Similar a taskCategoryTagBackground
  static const Color lightGrey = Color(0xFFF5F5F5);           // Útil para fondos generales si se diferencia de Colors.white
  static const Color darkGreyText = Color(0xFF333333);        // Similar a sectionTitleDark
  static const Color mediumGreyText = Color(0xFF757575);      // Útil para textos menos prominentes
  static const Color accentBlue = Color(0xFF448AFF);          // Similar a taskCategoryTagText o headerBlue

  // Ejemplo de MaterialColor para ThemeData si usas headerBlue como primario
  static const MaterialColor headerBlueMaterial = MaterialColor(
    0xFF2F80ED, // Valor primario
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: headerBlue, // El color principal
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );
}