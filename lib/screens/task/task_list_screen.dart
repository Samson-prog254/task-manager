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
  String _statusFilter = 'all'; // New filter for task status

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'All Tasks', // Changed to always show "All Tasks"
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          // Status Filter Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, color: Colors.white),
            onSelected: (status) {
              setState(() => _statusFilter = status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('All Tasks'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(Icons.pending_actions, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('In Progress'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Completed'),
                  ],
                ),
              ),
            ],
          ),
          // Category Filter Button
          PopupMenuButton<TaskCategory?>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
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
          // Search Bar with Status Chips
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search TextField
                Container(
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

                const SizedBox(height: 12),

                // Status Filter Chips
                Row(
                  children: [
                    _buildStatusChip('all', 'All Tasks', Icons.list),
                    const SizedBox(width: 8),
                    _buildStatusChip('pending', 'In Progress', Icons.pending_actions),
                    const SizedBox(width: 8),
                    _buildStatusChip('completed', 'Completed', Icons.check_circle),
                  ],
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // UPDATED: Filter tasks to show all, pending, or completed based on _statusFilter
                var filteredTasks = tasks.where((task) {
                  // Status filtering
                  bool matchesStatus = true;
                  switch (_statusFilter) {
                    case 'pending':
                      matchesStatus = !task.isCompleted;
                      break;
                    case 'completed':
                      matchesStatus = task.isCompleted;
                      break;
                    case 'all':
                    default:
                      matchesStatus = true; // Show all tasks
                      break;
                  }

                  // Category filtering
                  final matchesCategory = _selectedCategory == null ||
                      task.category == _selectedCategory;

                  // Search filtering
                  final matchesSearch = _searchQuery.isEmpty ||
                      task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      task.description.toLowerCase().contains(_searchQuery.toLowerCase());

                  return matchesStatus && matchesCategory && matchesSearch;
                }).toList();

                // Sort tasks: pending first, then completed
                filteredTasks.sort((a, b) {
                  if (a.isCompleted == b.isCompleted) {
                    // If both have same completion status, sort by creation date (newest first)
                    return b.createdAt.compareTo(a.createdAt);
                  }
                  // Pending tasks first
                  return a.isCompleted ? 1 : -1;
                });

                if (filteredTasks.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          // Add section headers for better organization
                          if (index == 0 ||
                              (filteredTasks[index - 1].isCompleted != task.isCompleted)) ...[
                            _buildSectionHeader(task.isCompleted),
                            const SizedBox(height: 8),
                          ],
                          TaskCard(task: task),
                        ],
                      ),
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

  Widget _buildStatusChip(String value, String label, IconData icon) {
    final isSelected = _statusFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isCompleted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.pending_actions,
            size: 20,
            color: isCompleted ? Colors.green.shade600 : Colors.orange.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? 'Completed Tasks' : 'In Progress',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title = 'No tasks found';
    String subtitle = 'Create your first task to get started';
    IconData icon = Icons.task_alt;

    switch (_statusFilter) {
      case 'pending':
        title = 'No pending tasks';
        subtitle = 'All your tasks are completed!';
        icon = Icons.pending_actions;
        break;
      case 'completed':
        title = 'No completed tasks';
        subtitle = 'Complete some tasks to see them here';
        icon = Icons.check_circle;
        break;
      default:
        if (_searchQuery.isNotEmpty || _selectedCategory != null) {
          title = 'No matching tasks';
          subtitle = 'Try adjusting your search or filters';
          icon = Icons.search_off;
        }
    }

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
              icon,
              size: 64,
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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