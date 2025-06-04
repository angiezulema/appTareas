import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';

class FavoriteCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleFavorite; // Callback para (des)marcar como favorito

  const FavoriteCard({
    super.key,
    required this.task,
    required this.onToggleFavorite, // Añadir el callback al constructor
  });

  String _getTagText() {
    if (task.category.isNotEmpty && task.category.toLowerCase() != "general") {
      return task.category;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final String tagText = _getTagText();

    return GestureDetector( // Usamos GestureDetector para el tap en toda la tarjeta
      onTap: onToggleFavorite, // Llamar al callback cuando se tapea la tarjeta
      // podrías usar onLongPress si prefieres una acción diferente al tap corto.
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila para el título y el icono de estrella
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded( // Para que el texto no se desborde si es largo
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.taskItemTextDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Icono de estrella para indicar que es favorito y permitir quitarlo
                  // Podrías hacer solo el icono clickeable si no quieres toda la tarjeta
                  Icon(
                    Icons.star, // Siempre estrella llena porque está en la sección de favoritos
                    color: AppColors.favoriteStarBlue.withOpacity(0.8), // Un poco más tenue
                    size: 20,
                  ),
                ],
              ),

              // Empujar el tag hacia abajo
              const Spacer(),

              if (tagText.isNotEmpty)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.taskCategoryTagBackground.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tagText,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.taskCategoryTagText,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}