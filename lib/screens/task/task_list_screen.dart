import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../models/task_model.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  final bool showCompleted;
  
  const TaskListScreen({
    super.key,
    this.showCompleted = false,
  });

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  TaskCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          widget.showCompleted ? 'Completed Tasks' : 'All Tasks',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<TaskCategory?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (category) {
              setState(() => _selectedCategory = category);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Categories'),
              ),
              ...TaskCategory.values.map(
                (category) => PopupMenuItem(
                  value: category,
                  child: Text(category.name.toUpperCase()),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Task List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // Filter tasks
                var filteredTasks = tasks.where((task) {
                  final matchesCompletion = widget.showCompleted
                      ? task.isCompleted
                      : !task.isCompleted;
                  final matchesCategory = _selectedCategory == null ||
                      task.category == _selectedCategory;
                  final matchesSearch = _searchQuery.isEmpty ||
                      task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      task.description.toLowerCase().contains(_searchQuery.toLowerCase());
                  
                  return matchesCompletion && matchesCategory && matchesSearch;
                }).toList();

                if (filteredTasks.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(task: filteredTasks[index]),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.showCompleted ? Icons.check_circle : Icons.task_alt,
              size: 64,
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              widget.showCompleted ? 'No completed tasks' : 'No tasks found',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.showCompleted
                  ? 'Complete some tasks to see them here'
                  : 'Create your first task to get started',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
