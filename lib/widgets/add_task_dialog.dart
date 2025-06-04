import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';

Future<Task?> showAddTaskDialog(BuildContext context, {Task? taskToEdit}) {
  final _formKey = GlobalKey<FormState>();
  String title = taskToEdit?.title ?? '';
  String category = taskToEdit?.category ?? 'General';
  String time = taskToEdit?.time ?? 'Todo el día';
  DateTime? dueDate = taskToEdit?.dueDate ?? DateTime.now();
  TaskPriority priority = taskToEdit?.priority ?? TaskPriority.ninguna;
  bool isFavorite = taskToEdit?.isFavorite ?? false;

  final List<String> categories = ["Diseño", "Trabajo", "Ventas", "IT", "Personal", "Estudios", "General"];
  final List<String> timeSuggestions = ["Todo el día", "Mañana", "Tarde", "Noche", "09:00", "10:00", "14:30", "16:00"];

  return showDialog<Task>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(taskToEdit == null ? 'Nueva Tarea' : 'Editar Tarea', style: TextStyle(color: AppColors.darkGreyText)),
            contentPadding: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      initialValue: title,
                      decoration: InputDecoration(labelText: 'Título de la tarea'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un título';
                        }
                        return null;
                      },
                      onSaved: (value) => title = value!,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: categories.contains(category) ? category : categories.first,
                      decoration: InputDecoration(labelText: 'Categoría'),
                      items: categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          category = newValue!;
                        });
                      },
                      onSaved: (value) => category = value!,
                    ),
                    SizedBox(height: 16),
                    Text("Fecha de Vencimiento:", style: TextStyle(fontSize: 13, color: AppColors.mediumGreyText)),
                    SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          locale: const Locale('es', 'ES'),
                          builder: (context, child) { // Opcional: Para tematizar el DatePicker
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primaryBlue, // Color primario del DatePicker
                                  onPrimary: Colors.white, // Color del texto sobre el primario
                                ),
                                buttonTheme: ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary
                                ),
                              ),
                              child: child!,
                            );
                          }
                        );
                        if (picked != null && picked != dueDate) {
                          setStateDialog(() {
                            dueDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dueDate == null ? 'Seleccionar fecha' : DateFormat('EEE, dd MMM, yyyy', 'es_ES').format(dueDate!),
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.mediumGreyText),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                     DropdownButtonFormField<String>(
                      value: timeSuggestions.contains(time) ? time : timeSuggestions.first,
                      decoration: InputDecoration(labelText: 'Hora / Momento del día'),
                      items: timeSuggestions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                         setStateDialog(() {
                          time = newValue!;
                        });
                      },
                      onSaved: (value) => time = value!,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text("Marcar como Favorito:", style: TextStyle(fontSize: 13, color: AppColors.mediumGreyText)),
                        Spacer(),
                        Switch(
                          value: isFavorite,
                          onChanged: (bool value) {
                            setStateDialog(() {
                              isFavorite = value;
                              if (!isFavorite) {
                                priority = TaskPriority.ninguna;
                              }
                            });
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                    if (isFavorite)
                      DropdownButtonFormField<TaskPriority>(
                        value: priority,
                        decoration: InputDecoration(labelText: 'Prioridad (Favorito)'),
                        items: TaskPriority.values.map((TaskPriority value) {
                          return DropdownMenuItem<TaskPriority>(
                            value: value,
                            child: Text(value.toString().split('.').last.capitalize()),
                          );
                        }).toList(),
                        onChanged: (TaskPriority? newValue) {
                           setStateDialog(() {
                            priority = newValue!;
                          });
                        },
                        onSaved: (value) => priority = value!,
                      ),
                  ],
                ),
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar', style: TextStyle(color: AppColors.mediumGreyText)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text(taskToEdit == null ? 'Agregar' : 'Guardar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (dueDate == null) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Por favor, selecciona una fecha de vencimiento.')),
                       );
                       return;
                    }
                    Navigator.of(context).pop(Task(
                      id: taskToEdit?.id,
                      title: title,
                      category: category,
                      time: time,
                      dueDate: dueDate,
                      isCompleted: taskToEdit?.isCompleted ?? false,
                      isFavorite: isFavorite,
                      priority: isFavorite ? priority : TaskPriority.ninguna,
                    ));
                  }
                },
              ),
            ],
          );
        }
      );
    },
  );
}

extension StringExtension on String {
    String capitalize() {
      if (this.isEmpty) return this;
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}