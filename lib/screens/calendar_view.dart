import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';

class CalendarView extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onToggleComplete;
  final Function(Task, Task) onEditTask;
  final Function(Task) onDeleteTask;
  final Function(Task) onToggleFavorite;

  const CalendarView({
    Key? key,
    required this.tasks,
    required this.onToggleComplete,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late Map<DateTime, List<Task>> _groupedTasks;
  DateTime _focusedDay = DateTime.now(); // Inicializado aquí
  DateTime? _selectedDay;
  List<Task> _selectedTasks = [];

  @override
  void initState() {
    super.initState();
    print("CalendarView initState called");
    // Normalizar _focusedDay a medianoche para consistencia si es necesario para la lógica inicial
    // _focusedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day); // Seleccionar el día actual inicialmente

    _groupTasks();
    // Cargar tareas para el día seleccionado inicialmente directamente
    _selectedTasks = _getTasksForDay(_selectedDay!);
    // No es estrictamente necesario llamar a _onDaySelected aquí si ya cargas _selectedTasks
    // Pero si _onDaySelected tiene otra lógica importante, podrías llamarlo.
    // Por ahora, la carga directa de _selectedTasks es suficiente.
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("CalendarView didUpdateWidget called");
    if (widget.tasks != oldWidget.tasks) {
      _groupTasks();
      // Refrescar tareas para el día actualmente seleccionado
      if (_selectedDay != null) {
        _selectedTasks = _getTasksForDay(_selectedDay!);
        // Si setState es necesario aquí, dependerá de si la lista de tareas se actualiza en la UI
        // por otros medios o si necesita un trigger explícito.
        // Como _selectedTasks se usa en ListView.builder, un setState aquí
        // aseguraría que la lista se reconstruya si las tareas subyacentes cambian.
        setState(() {});
      }
    }
  }

  void _groupTasks() {
    _groupedTasks = {};
    for (var task in widget.tasks) {
      if (task.dueDate != null) {
        DateTime dateKey = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (_groupedTasks[dateKey] == null) {
          _groupedTasks[dateKey] = [];
        }
        _groupedTasks[dateKey]!.add(task);
      }
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return _groupedTasks[dateKey] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print("CalendarView _onDaySelected: $selectedDay");
    final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      setState(() {
        _selectedDay = normalizedSelectedDay;
        _focusedDay = focusedDay; // Actualizar focusedDay también es buena práctica
        _selectedTasks = _getTasksForDay(normalizedSelectedDay);
      });
    } else {
      // Si se selecciona el mismo día, podrías querer forzar una actualización si la lógica lo requiere
      // o simplemente asegurarte de que _focusedDay esté sincronizado.
       setState(() {
        _focusedDay = focusedDay;
      });
    }
  }

  void _openEditTaskDialog(Task task) async {
      final result = await showAddTaskDialog(context, taskToEdit: task);
      if (result != null) {
        widget.onEditTask(task, result);
      }
  }

  @override
  Widget build(BuildContext context) {
    print("CalendarView build called. FocusedDay: $_focusedDay, SelectedDay: $_selectedDay");
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: TableCalendar<Task>(
              locale: 'es_ES',
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay, // Usar el _focusedDay del estado
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              eventLoader: _getTasksForDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},

              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(color: AppColors.darkGreyText.withOpacity(0.8)),
                weekendTextStyle: TextStyle(color: AppColors.darkGreyText.withOpacity(0.8)),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.7), width: 1.5)
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                markerDecoration: BoxDecoration(color: Colors.transparent),
                markerSize: 0,
                canMarkersOverflow: false,
                markersMaxCount: 1,
              ),

              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 13, color: AppColors.mediumGreyText, fontWeight: FontWeight.w500),
                weekendStyle: TextStyle(fontSize: 13, color: AppColors.mediumGreyText, fontWeight: FontWeight.w500),
              ),

              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.darkGreyText),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primaryBlue, size: 26),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primaryBlue, size: 26),
                headerPadding: EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                   border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5))
                )
              ),

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    if (!isSameDay(date, _selectedDay)) {
                       return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withOpacity(0.9),
                          ),
                        ),
                      );
                    }
                  }
                  return null;
                },
                dowBuilder: (context, day) {
                  final text = DateFormat.E('es_ES').format(day);
                  return Center(
                    child: Text(
                      text.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 13, color: AppColors.mediumGreyText, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
              // ***** CORRECCIÓN IMPORTANTE AQUÍ *****
              onPageChanged: (focusedDay) {
                setState(() { // Debe llamar a setState para reconstruir con el nuevo mes/año
                  _focusedDay = focusedDay;
                });
                // Opcional: también podrías querer seleccionar el primer día visible
                // del nuevo mes o mantener la selección si el _selectedDay está en el nuevo mes.
                // Por ahora, solo actualizar _focusedDay es lo crucial para la navegación.
                // Si quieres que _selectedDay cambie al cambiar de página:
                // _onDaySelected(focusedDay, focusedDay); // O una lógica más compleja
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Divider(height: 1, color: Colors.grey.shade300),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
            child: Text(
              "Tareas del día",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGreyText),
            ),
          ),
          Expanded(
            child: _selectedTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Center(child: Text("No hay tareas para este día.", style: TextStyle(color: AppColors.mediumGreyText, fontSize: 15))),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                    itemCount: _selectedTasks.length,
                    itemBuilder: (context, index) {
                      final task = _selectedTasks[index];
                      return TaskItem(
                        task: task,
                        onToggleComplete: () => widget.onToggleComplete(task),
                        onEdit: () => _openEditTaskDialog(task),
                        onDelete: () => widget.onDeleteTask(task),
                        onToggleFavorite: () => widget.onToggleFavorite(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}