import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_colors.dart';
import '../widgets/task_item.dart';
import '../widgets/favorite_card.dart';
import '../widgets/add_task_dialog.dart';
import 'calendar_view.dart'; // CAMBIO: Importar la vista de calendario

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CAMBIO: Actualizar datos iniciales con dueDate y más variedad
  final List<Task> _tasks = [
    Task(title: "Revisar Wireframes App", time: "10:00", dueDate: DateTime.now(), isFavorite: true, priority: TaskPriority.alta, category: "Diseño"),
    Task(title: "Llamada Cliente X", time: "15:30", dueDate: DateTime.now(), category: "Ventas"),
    Task(title: "Planificar Sprint Semanal", time: "Mañana", dueDate: DateTime.now().add(Duration(days: 1)), isFavorite: true, priority: TaskPriority.media, category: "Trabajo"),
    Task(title: "Comprar Regalo Cumpleaños", category: "Personal", time: "Tarde", dueDate: DateTime.now().add(Duration(days: 2))),
    Task(title: "Actualizar Documentación API", category: "IT", time: "Todo el día", dueDate: DateTime.now().add(Duration(days: 3))),
    Task(title: "Ir al Gimnasio", category: "Personal", time: "18:00", dueDate: DateTime.now().add(Duration(days: 1))),
  ];

  int _currentIndex = 0; // 0: Inicio, 1: Calendario, 2: Perfil

  List<Task> get _favoriteTasks => _tasks.where((task) => task.isFavorite).toList();

  // CAMBIO: Mejorar lógica de _regularTasks para ordenar por fecha y estado de completitud
  List<Task> get _regularTasks {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _tasks.where((task) {
      // Mostrar tareas no favoritas que están pendientes o son para hoy/futuro
      bool isDueOrUpcoming = task.dueDate == null || task.dueDate!.isAfter(today.subtract(Duration(days:1))) || task.dueDate == today;
      return !task.isFavorite && (isDueOrUpcoming || !task.isCompleted);
    }).toList()
    ..sort((a, b) { // Ordenar: no completadas primero, luego por fecha
        if (a.isCompleted == b.isCompleted) { // Si ambas están completas o no completas
          if (a.dueDate == null && b.dueDate == null) return 0; // Sin fecha, mantener orden
          if (a.dueDate == null) return 1; // 'a' sin fecha va después
          if (b.dueDate == null) return -1; // 'b' sin fecha va después (así 'a' con fecha va antes)
          return a.dueDate!.compareTo(b.dueDate!); // Comparar por fecha
        }
        return a.isCompleted ? 1 : -1; // No completadas (false = 0) antes que completadas (true = 1)
    });
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _editTask(Task oldTask, Task newTask) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == oldTask.id);
      if (index != -1) {
        _tasks[index] = newTask;
      }
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
  }

  void _toggleComplete(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _toggleFavorite(Task task) {
    setState(() {
      task.isFavorite = !task.isFavorite;
      if (!task.isFavorite) {
        task.priority = TaskPriority.ninguna;
      } else if (task.priority == TaskPriority.ninguna) {
        task.priority = TaskPriority.media;
      }
    });
  }

  void _openAddTaskDialog({Task? taskToEdit}) async {
    final result = await showAddTaskDialog(context, taskToEdit: taskToEdit);
    if (result != null) {
      if (taskToEdit == null) {
        _addTask(result);
      } else {
        _editTask(taskToEdit, result);
      }
    }
  }

  // CAMBIO: Widget para construir el contenido de la pantalla de Inicio
  Widget _buildHomeScreenContent() {
    return Container(
      color: Color(0xFFF9FAFB), // Fondo gris claro para la pantalla de inicio
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(0), // Padding manejado internamente
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar tareas...',
                  prefixIcon: Icon(Icons.search, color: AppColors.mediumGreyText),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
            if (_favoriteTasks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 8.0),
                child: Row(
                  children: [
                    Icon(Icons.star, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Favoritos',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreyText),
                    ),
                  ],
                ),
              ),
              Container(
                height: 110,
                padding: const EdgeInsets.only(left: 20.0, top: 4, bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _favoriteTasks.length,
                  itemBuilder: (context, index) {
                    return FavoriteCard(task: _favoriteTasks[index]);
                  },
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, _favoriteTasks.isNotEmpty ? 16.0 : 10.0 , 20.0, 8.0),
              child: Text(
                'Mis Tareas',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreyText),
              ),
            ),
            _regularTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                    child: Center(child: Text("¡Todo listo por hoy! No hay tareas pendientes.", style: TextStyle(color: AppColors.mediumGreyText, fontSize: 15))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 80.0), // Espacio para FAB
                    itemCount: _regularTasks.length,
                    itemBuilder: (context, index) {
                      final task = _regularTasks[index];
                      return TaskItem(
                        task: task,
                        onToggleComplete: () => _toggleComplete(task),
                        onEdit: () => _openAddTaskDialog(taskToEdit: task),
                        onDelete: () => _deleteTask(task),
                        onToggleFavorite: () => _toggleFavorite(task),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // CAMBIO: Método para construir el AppBar condicionalmente
  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex == 1) { // Si es la pestaña de Calendario
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        centerTitle: false,
        titleSpacing: 20.0,
        title: Text(
          'Calendario',
          style: TextStyle(
            color: AppColors.darkGreyText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      );
    } else { // AppBar para la pestaña de Inicio y Perfil
      return PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 45.0, right: 20.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _currentIndex == 2 ? 'Mi Perfil' : 'Mis Tareas', // Título dinámico para Perfil
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  _currentIndex == 2 ? 'Tu información y configuración' : 'Organiza tu día', // Subtítulo dinámico
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // CAMBIO: Determinar la vista actual (currentView) basada en _currentIndex
    Widget currentView;
    switch (_currentIndex) {
      case 0: // Inicio
        currentView = _buildHomeScreenContent();
        break;
      case 1: // Calendario
        currentView = CalendarView(
          tasks: _tasks, // Pasar la lista de tareas al calendario
          onToggleComplete: _toggleComplete,
          onEditTask: _editTask,
          onDeleteTask: _deleteTask,
          onToggleFavorite: _toggleFavorite,
        );
        break;
      case 2: // Perfil
        currentView = Center(child: Text("Pantalla de Perfil (Aún no implementada)", style: TextStyle(fontSize: 16, color: AppColors.mediumGreyText)));
        break;
      default:
        currentView = _buildHomeScreenContent(); // Por defecto, mostrar contenido de inicio
    }

    return Scaffold(
      appBar: _buildAppBar(), // Usar el AppBar condicional
      body: currentView, // Mostrar la vista actual
      // CAMBIO: FloatingActionButton solo para la vista de Inicio (_currentIndex == 0)
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => _openAddTaskDialog(),
        backgroundColor: AppColors.primaryBlue,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Nueva Tarea',
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // CAMBIO: Actualizar BottomNavigationBar para quitar "Listas"
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGreyText,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 8.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Icono para estado activo
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}