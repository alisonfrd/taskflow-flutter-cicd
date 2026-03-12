import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskItem extends Equatable {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;
  final String? imageUrl;

  const TaskItem({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.imageUrl,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  factory TaskItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Documento de tarefa sem dados.');
    }

    return TaskItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      isDone: data['isDone'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, isDone, createdAt, imageUrl];
}
