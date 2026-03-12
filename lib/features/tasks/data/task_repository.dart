import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<String> _saveImageLocally(XFile image) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docsDir.path}/task_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final originalName = image.name.trim().isEmpty ? 'image.jpg' : image.name;
    final safeName = originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final localPath =
        '${imagesDir.path}/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final bytes = await image.readAsBytes();
    final targetFile = File(localPath);
    await targetFile.writeAsBytes(bytes, flush: true);
    return localPath;
  }

  Future<void> addTask({
    required String userId,
    required String title,
    XFile? image,
  }) async {
    String? imageUrl;
    if (image != null) {
      try {
        imageUrl = await _saveImageLocally(image);
      } catch (e, st) {
        debugPrint('[TaskRepository] Falha ao salvar imagem localmente: $e');
        debugPrint('$st');
        // Continua criando a tarefa sem imagem
      }
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
