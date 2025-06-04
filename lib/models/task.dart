import 'package:uuid/uuid.dart';

enum TaskPriority { alta, media, baja, ninguna }

class Task {
  String id;
  String title;
  String category;
  String time; // Para la hora o descripciones como "Mañana", "Todo el día"
  DateTime? dueDate; // Fecha específica de vencimiento
  bool isCompleted;
  bool isFavorite;
  TaskPriority priority;

  Task({
    String? id,
    required this.title,
    this.category = "General",
    this.time = "Hoy",
    this.dueDate,
    this.isCompleted = false,
    this.isFavorite = false,
    this.priority = TaskPriority.ninguna,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'time': time,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
      'priority': priority.toString(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      time: map['time'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isCompleted: map['isCompleted'],
      isFavorite: map['isFavorite'],
      priority: TaskPriority.values.firstWhere(
            (e) => e.toString() == map['priority'],
        orElse: () => TaskPriority.ninguna,
      ),
    );
  }
}