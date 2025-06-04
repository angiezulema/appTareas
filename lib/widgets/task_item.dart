import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesario para formatear fechas.
import '../models/task.dart';
import '../utils/app_colors.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  // Función para formatear la fecha y hora de la tarea como en la imagen.
  String _getTaskTiming(Task task) {
    String timing = "";
    if (task.dueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final taskDateOnly = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

      if (taskDateOnly == today) {
        timing = "Hoy";
      } else if (taskDateOnly == tomorrow) {
        timing = "Mañana";
      } else {
        // Para otras fechas, usar formato "dd MMM" (ej: "03 jun").
        // Asegúrate de tener 'es_ES' inicializado en main.dart.
        timing = DateFormat('dd MMM', 'es_ES').format(task.dueDate!);
      }
    }

    // Añadir la hora si está presente y es relevante (no "Todo el día" o descripciones genéricas).
    // La imagen muestra la hora específica para algunas tareas.
    if (task.time.isNotEmpty &&
        task.time.toLowerCase() != "todo el día" &&
        !task.time.toLowerCase().contains("tarde") && // Si es "Tarde", se maneja abajo.
        !task.time.toLowerCase().contains("mañana")) { // Si es "Mañana" en time, ya se maneja con dueDate.
      timing += (timing.isNotEmpty ? ", ${task.time}" : task.time); // Ej: "Hoy, 15:30" o "03 jun, 10:00"
    } else if (task.time.toLowerCase().contains("tarde") && timing.isNotEmpty) {
      timing += ", Tarde"; // Ej: "03 jun, Tarde"
    } else if (timing.isEmpty && task.time.isNotEmpty) {
      // Si no hay dueDate pero sí 'time' (ej: "Próxima semana", aunque la imagen no muestra esto).
      timing = task.time;
    }

    return timing.isEmpty ? "Sin fecha" : timing;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // El margen vertical entre TaskItems se manejará en el ListView.builder de HomeScreen.
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0), // Padding interno.
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco.
        borderRadius: BorderRadius.circular(12.0), // Bordes redondeados como en la imagen.
        boxShadow: [ // Sombra sutil.
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0, // Reducir spread para una sombra más difusa.
            blurRadius: 6,   // Aumentar blur.
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Alinear elementos verticalmente al centro.
        children: [
          // Checkbox circular personalizado.
          InkWell(
            onTap: onToggleComplete,
            customBorder: const CircleBorder(), // Para que el efecto ripple sea circular.
            child: Container(
              width: 26,  // Tamaño del contenedor del checkbox.
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  // Color del borde cambia si está completado o no.
                  color: task.isCompleted ? AppColors.headerBlue : AppColors.taskItemCheckboxBorder,
                  width: 2,
                ),
                // Color de fondo del círculo interno.
                color: task.isCompleted ? AppColors.headerBlue : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 15, color: Colors.white) // Icono de check.
                  : null, // Vacío si no está completado.
            ),
          ),
          const SizedBox(width: 16), // Espacio entre checkbox y texto.

          // Columna para el título y la información secundaria (categoría, fecha).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500, // Semi-bold.
                    // Color del texto y decoración cambian si la tarea está completada.
                    color: task.isCompleted ? AppColors.taskItemTextLight : AppColors.taskItemTextDark,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.taskItemTextLight,
                  ),
                  maxLines: 2, // Permitir hasta 2 líneas.
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6), // Espacio entre título e info secundaria.
                Row(
                  children: [
                    // Tag de categoría.
                    if (task.category.isNotEmpty && task.category.toLowerCase() != "general")
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.taskCategoryTagBackground, // Fondo azul pálido.
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.category,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.taskCategoryTagText, // Texto azul.
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    // Espacio si hay tag de categoría.
                    if (task.category.isNotEmpty && task.category.toLowerCase() != "general")
                      const SizedBox(width: 8),

                    // Icono de calendario y texto de fecha/hora.
                    const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.taskItemTextLight),
                    const SizedBox(width: 5),
                    Flexible( // Para que el texto de la fecha no cause overflow si es largo.
                      child: Text(
                        _getTaskTiming(task), // Llama a la función de formateo.
                        style: const TextStyle(fontSize: 12.5, color: AppColors.taskItemTextLight),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menú de opciones (tres puntos verticales).
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.taskItemTextLight),
            tooltip: "Más opciones",
            onSelected: (value) { // Manejar la selección del menú.
              if (value == 'edit') onEdit();
              else if (value == 'delete') onDelete();
              else if (value == 'favorite') onToggleFavorite();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'favorite',
                child: Row(children: [
                  Icon(task.isFavorite ? Icons.star : Icons.star_border, color: AppColors.favoriteStarBlue, size: 20),
                  const SizedBox(width: 10),
                  Text(task.isFavorite ? 'Quitar de Favoritos' : 'Marcar Favorito'),
                ]),
              ),
              const PopupMenuDivider(), // Separador.
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(children: const [Icon(Icons.edit_outlined, size: 20, color: AppColors.taskItemTextDark), SizedBox(width: 10), Text('Editar')]),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red.shade600), const SizedBox(width: 10), Text('Eliminar', style: TextStyle(color: Colors.red.shade600))]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}