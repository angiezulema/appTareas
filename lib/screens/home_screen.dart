import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener esta importación si usas DateFormat
import '../models/task.dart';
import '../utils/app_colors.dart';
import '../widgets/task_item.dart';
import '../widgets/favorite_card.dart';
import '../widgets/add_task_dialog.dart';
import 'calendar_view.dart'; // Asumiendo que tienes esta vista

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de tareas de ejemplo, adaptada para parecerse a la imagen.
  final List<Task> _tasks = [
    Task(title: "Revisar Wireframes App", time: "", dueDate: DateTime.now().add(const Duration(days: 2)), isFavorite: true, priority: TaskPriority.alta, category: "App"),
    Task(title: "Planificar Sprint Semanal", time: "", dueDate: DateTime.now().add(const Duration(days: 3)), isFavorite: true, priority: TaskPriority.media, category: "Semanal"),
    Task(title: "almorzar con marco", category: "Personal", time: "Tarde", dueDate: DateTime(2023, 6, 3)),
    Task(title: "Llamada Cliente X", category: "Ventas", time: "15:30", dueDate: DateTime(2023, 6, 3)),
    Task(title: "Ir al Gimnasio", category: "Personal", time: "18:00", dueDate: DateTime.now()),
    Task(title: "Comprar Regalo Cumpleaños", category: "Personal", time: "Tarde", dueDate: DateTime.now().add(const Duration(days: 1))),
    Task(title: "Actualizar Documentación API", category: "Trabajo", time: "", dueDate: DateTime.now().add(const Duration(days: 1))),
  ];

  int _currentIndex = 0; // 0: Inicio, 1: Calendario, 2: Perfil

  // Filtra la lista de tareas para obtener solo las favoritas.
  List<Task> get _favoriteTasks => _tasks.where((task) => task.isFavorite).toList();

  // Filtra y ordena las tareas que no son favoritas y están pendientes o son para hoy/futuro.
  List<Task> get _regularTasks {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _tasks.where((task) {
      bool isDueOrUpcoming = task.dueDate == null || task.dueDate!.isAfter(today.subtract(const Duration(days:1))) || task.dueDate!.isAtSameMomentAs(today);
      return !task.isFavorite && (isDueOrUpcoming || !task.isCompleted);
    }).toList()
    ..sort((a, b) { // Ordena: no completadas primero, luego por fecha.
        if (a.isCompleted == b.isCompleted) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        }
        return a.isCompleted ? 1 : -1;
    });
  }

  // --- Métodos para manejar tareas ---
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

  // Cambia el estado de favorito de una tarea.
  void _toggleFavorite(Task task) {
    setState(() {
      task.isFavorite = !task.isFavorite;
      // Opcional: Ajustar la prioridad cuando se (des)marca como favorito.
      if (!task.isFavorite && task.priority != TaskPriority.ninguna) {
        // Si se quita de favoritos y tenía una prioridad, podrías resetearla o mantenerla.
        // task.priority = TaskPriority.ninguna; // Ejemplo de resetear.
      } else if (task.isFavorite && task.priority == TaskPriority.ninguna) {
        // Si se añade a favoritos y no tiene prioridad, asignarle una media por defecto.
        task.priority = TaskPriority.media;
      }
    });
  }

  // Abre el diálogo para añadir o editar una tarea.
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

  // Construye el contenido de la pestaña "Inicio".
  Widget _buildHomeScreenContent() {
    return Container(
      color: Colors.white, // Fondo blanco general.
      child: ListView( // ListView principal para permitir scroll de toda la pantalla.
        padding: EdgeInsets.zero,
        children: [
          // --- Barra de Búsqueda ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar tareas...',
                hintStyle: const TextStyle(color: AppColors.searchHintGrey, fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: AppColors.searchHintGrey, size: 24),
                filled: true,
                fillColor: AppColors.searchBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.headerBlue, width: 1.2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              ),
            ),
          ),

          // --- Sección Favoritos ---
          // Solo se muestra si hay tareas favoritas.
          if (_favoriteTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              child: Row(
                children: const [
                  Icon(Icons.star, color: AppColors.favoriteStarBlue, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Favoritos',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sectionTitleDark),
                  ),
                ],
              ),
            ),
            Container(
              height: 115, // Altura fija para la lista horizontal de favoritos.
              padding: const EdgeInsets.only(left: 20.0, top: 4, bottom: 8, right: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _favoriteTasks.length,
                itemBuilder: (context, index) {
                  final favoriteTask = _favoriteTasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0), // Espacio entre tarjetas de favoritos.
                    child: FavoriteCard(
                      task: favoriteTask,
                      // Se pasa la función _toggleFavorite para que se ejecute al tocar la tarjeta.
                      onToggleFavorite: () => _toggleFavorite(favoriteTask),
                    ),
                  );
                },
              ),
            ),
          ],

          // --- Sección Mis Tareas ---
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, _favoriteTasks.isNotEmpty ? 20.0 : 16.0 , 20.0, 12.0),
            child: const Text(
              'Mis Tareas',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sectionTitleDark),
            ),
          ),
          // Muestra un mensaje si no hay tareas regulares, o la lista de tareas.
          _regularTasks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                  child: Center(child: Text("¡Todo listo por hoy! No hay tareas pendientes.", style: TextStyle(color: AppColors.mediumGreyText, fontSize: 15))),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                      shrinkWrap: true, // Necesario cuando un ListView está dentro de otro scrollable.
                      physics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll propio del ListView interno.
                      itemCount: _regularTasks.length,
                      itemBuilder: (context, index) {
                        final task = _regularTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0), // Espacio vertical entre TaskItems.
                          child: TaskItem(
                            task: task,
                            onToggleComplete: () => _toggleComplete(task),
                            onEdit: () => _openAddTaskDialog(taskToEdit: task),
                            onDelete: () => _deleteTask(task),
                            onToggleFavorite: () => _toggleFavorite(task),
                          ),
                        );
                      },
                    ),
                ),
          // Espacio al final para que el FloatingActionButton no tape la última tarea.
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Construye el AppBar de forma condicional según la pestaña actual.
  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex == 0) { // AppBar para la pestaña de Inicio.
      return PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: AppColors.headerBlue,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom:10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Mis Tareas',
                    style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organiza tu día',
                    style: TextStyle(color: AppColors.textWhite.withOpacity(0.85), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (_currentIndex == 1) { // AppBar para la pestaña de Calendario.
      return AppBar(
        backgroundColor: Colors.white, elevation: 0.8, centerTitle: false, titleSpacing: 20.0,
        title: const Text('Calendario', style: TextStyle(color: AppColors.darkGreyText, fontSize: 26, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      );
    } else { // AppBar para la pestaña de Perfil.
      return PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: AppColors.primaryBlue, // Podrías usar AppColors.headerBlue también para consistencia.
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 45.0, right: 20.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Tu información y configuración', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }
  }

  // Método principal de construcción del widget.
  @override
  Widget build(BuildContext context) {
    Widget currentView;
    // Determina qué vista mostrar basado en el índice de la pestaña actual.
    switch (_currentIndex) {
      case 0:
        currentView = _buildHomeScreenContent();
        break;
      case 1:
        currentView = CalendarView( // Asume que CalendarView está implementado.
          tasks: _tasks,
          onToggleComplete: _toggleComplete,
          onEditTask: _editTask,
          onDeleteTask: _deleteTask,
          onToggleFavorite: _toggleFavorite,
        );
        break;
      case 2:
        currentView = const Center(child: Text("Pantalla de Perfil (Aún no implementada)", style: TextStyle(fontSize: 16, color: AppColors.mediumGreyText)));
        break;
      default:
        currentView = _buildHomeScreenContent();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: currentView,
      // FloatingActionButton solo se muestra en la pestaña de Inicio.
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => _openAddTaskDialog(),
        backgroundColor: AppColors.fabBlue,
        tooltip: 'Nueva Tarea',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Forma cuadrada redondeada.
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Barra de navegación inferior.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Para que todos los labels sean visibles.
        selectedItemColor: AppColors.headerBlue, // Color del ítem seleccionado.
        unselectedItemColor: AppColors.mediumGreyText, // Color de ítems no seleccionados.
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 8.0, // Sombra de la barra.
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}