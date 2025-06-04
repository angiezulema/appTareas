import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  }) : super(key: key);

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
        // Mostrar día de la semana si es dentro de los próximos 7 días
        if (taskDateOnly.isAfter(today) && taskDateOnly.isBefore(today.add(Duration(days: 7)))) {
            timing = DateFormat('EEEE', 'es_ES').format(task.dueDate!); // ej: Lunes
        } else {
            timing = DateFormat('dd MMM', 'es_ES').format(task.dueDate!); // ej: 15 Feb
        }
      }
    }

    // Añadir la hora si no es "Todo el día" y hay timing de fecha
    if (task.time.isNotEmpty && task.time.toLowerCase() != "todo el día") {
      timing += (timing.isNotEmpty ? ", ${task.time}" : task.time);
    } else if (timing.isEmpty && task.time.isNotEmpty) { // Si no hay fecha pero sí 'time' (ej: "Próxima semana")
        timing = task.time;
    } else if (timing.isNotEmpty && task.time.toLowerCase() == "todo el día"){
        // No añade nada más si ya hay fecha y es todo el día
    }

    return timing.isEmpty ? "Sin fecha" : timing;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(16.0), // Aumentado un poco el padding
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el item
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Sombra más sutil
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onToggleComplete,
            customBorder: CircleBorder(),
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? AppColors.primaryBlue : AppColors.mediumGreyText.withOpacity(0.7),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 11, // Ligeramente más grande
                backgroundColor: task.isCompleted ? AppColors.primaryBlue : Colors.transparent,
                child: task.isCompleted
                    ? Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16), // Un poco más de espacio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: task.isCompleted ? AppColors.mediumGreyText : AppColors.darkGreyText,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.mediumGreyText,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (task.category.isNotEmpty && task.category.toLowerCase() != "general")
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.category,
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    if (task.category.isNotEmpty && task.category.toLowerCase() != "general") const SizedBox(width: 8),
                    Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.mediumGreyText),
                    const SizedBox(width: 4),
                    Text(
                      _getTaskTiming(task),
                      style: TextStyle(fontSize: 12, color: AppColors.mediumGreyText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.mediumGreyText),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              } else if (value == 'favorite') {
                onToggleFavorite();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'favorite',
                child: Text(task.isFavorite ? 'Quitar de Favoritos' : 'Marcar como Favorito'),
              ),
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Editar'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}