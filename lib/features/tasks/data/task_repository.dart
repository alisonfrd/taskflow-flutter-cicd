import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskflow_app/core/constants/firestore_paths.dart';
import 'package:taskflow_app/features/tasks/domain/task_item.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  TaskRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

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

  Future<void> addTask({
    required String userId,
    required String title,
    XFile? image,
  }) async {
    String? imageUrl;
    if (image != null) {
      final ref = _storage.ref(
        'tasks/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(File(image.path));
      imageUrl = await ref.getDownloadURL();
    }

    final task = TaskItem(
      id: '',
      title: title.trim(),
      isDone: false,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
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
