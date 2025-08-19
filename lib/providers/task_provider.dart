import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final tasksProvider = StreamProvider<List<Task>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTasks(user.uid);
});

final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (taskList) => taskList.where((task) => task.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final pendingTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (taskList) => taskList.where((task) => !task.isCompleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.when(
    data: (taskList) {
      final completed = taskList.where((task) => task.isCompleted).length;
      final pending = taskList.where((task) => !task.isCompleted).length;
      final total = taskList.length;
      return {
        'total': total,
        'completed': completed,
        'pending': pending,
      };
    },
    loading: () => {'total': 0, 'completed': 0, 'pending': 0},
    error: (_, __) => {'total': 0, 'completed': 0, 'pending': 0},
  );
});
