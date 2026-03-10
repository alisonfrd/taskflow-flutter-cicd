import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow_app/features/tasks/data/task_repository.dart';
import 'package:taskflow_app/features/tasks/domain/task_item.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TaskRepository _taskRepository;
  StreamSubscription<List<TaskItem>>? _subscription;

  TasksCubit(this._taskRepository) : super(const TasksInitial());

  void watchTasks(String userId) {
    emit(const TasksLoading());

    _subscription?.cancel();
    _subscription = _taskRepository
        .watchTasks(userId)
        .listen(
          (tasks) => emit(TasksLoaded(tasks)),
          onError: (_) => emit(const TasksError('Falha ao carregar tarefas.')),
        );
  }

  Future<void> addTask({required String userId, required String title}) async {
    if (title.trim().isEmpty) return;

    try {
      await _taskRepository.addTask(userId: userId, title: title);
    } catch (_) {
      emit(const TasksError('Falha ao adicionar tarefa.'));
    }
  }

  Future<void> toggleTask({
    required String userId,
    required TaskItem task,
  }) async {
    try {
      await _taskRepository.toggleTask(userId: userId, task: task);
    } catch (_) {
      emit(const TasksError('Falha ao atualizar tarefa.'));
    }
  }

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _taskRepository.deleteTask(userId: userId, taskId: taskId);
    } catch (_) {
      emit(const TasksError('Falha ao remover tarefa.'));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
