import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskflow_app/core/constants/firestore_paths.dart';
import 'package:taskflow_app/features/tasks/domain/task_item.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _firestore.collection(FirestorePaths.userTasks(userId));
  }

  Stream<List<TaskItem>> watchTasks(String userId) {
    return _tasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskItem.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addTask({required String userId, required String title}) async {
    final task = TaskItem(
      id: '',
      title: title.trim(),
      isDone: false,
      createdAt: DateTime.now(),
    );

    await _tasksRef(userId).add(task.toMap());
  }

  Future<void> toggleTask({
    required String userId,
    required TaskItem task,
  }) async {
    await _tasksRef(userId).doc(task.id).update({'isDone': !task.isDone});
  }

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _tasksRef(userId).doc(taskId).delete();
  }
}
