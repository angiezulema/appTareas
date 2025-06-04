import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';

class FavoriteCard extends StatelessWidget {
  final Task task;

  const FavoriteCard({Key? key, required this.task}) : super(key: key);

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return "Alta";
      case TaskPriority.media:
        return "Media";
      case TaskPriority.baja:
        return "Baja";
      default:
        return "";
    }
  }

  Color _getPriorityTagColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return Colors.red.shade100;
      case TaskPriority.media:
        return AppColors.lightBlueBackground;
      case TaskPriority.baja:
        return Colors.green.shade100;
      default:
        return Colors.transparent;
    }
  }

   Color _getPriorityTextColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return Colors.red.shade700;
      case TaskPriority.media:
        return AppColors.primaryBlue;
      case TaskPriority.baja:
        return Colors.green.shade700;
      default:
        return AppColors.primaryBlue;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para las tarjetas
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.darkGreyText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                task.time, // "Hoy", "Mañana"
                style: TextStyle(fontSize: 12, color: AppColors.mediumGreyText),
              ),
              if (task.priority != TaskPriority.ninguna)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityTagColor(task.priority),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPriorityText(task.priority),
                    style: TextStyle(
                        fontSize: 10,
                        color: _getPriorityTextColor(task.priority),
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}