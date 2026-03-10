import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow_app/features/tasks/data/task_repository.dart';
import 'package:taskflow_app/features/tasks/domain/task_item.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_state.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late TaskRepository taskRepository;

  final task = TaskItem(
    id: '1',
    title: 'Estudar CI/CD',
    isDone: false,
    createdAt: DateTime(2026, 3, 10, 10, 0),
  );

  setUpAll(() {
    registerFallbackValue(task);
  });

  setUp(() {
    taskRepository = MockTaskRepository();
  });

  group('watchTasks', () {
    blocTest<TasksCubit, TasksState>(
      'emite [TasksLoading, TasksLoaded] quando watchTasks tem sucesso',
      build: () {
        when(
          () => taskRepository.watchTasks('user-1'),
        ).thenAnswer((_) => Stream.value([task]));
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.watchTasks('user-1'),
      expect: () => [
        const TasksLoading(),
        TasksLoaded([task]),
      ],
    );

    blocTest<TasksCubit, TasksState>(
      'emite [TasksLoading, TasksError] quando watchTasks falha',
      build: () {
        when(
          () => taskRepository.watchTasks('user-1'),
        ).thenAnswer((_) => Stream.error(Exception('erro')));
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.watchTasks('user-1'),
      expect: () => [
        const TasksLoading(),
        const TasksError('Falha ao carregar tarefas.'),
      ],
    );
  });

  group('addTask', () {
    blocTest<TasksCubit, TasksState>(
      'chama o repositório e não emite estado quando addTask tem sucesso',
      build: () {
        when(
          () => taskRepository.addTask(userId: 'user-1', title: 'Nova tarefa'),
        ).thenAnswer((_) async {});
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.addTask(userId: 'user-1', title: 'Nova tarefa'),
      expect: () => [],
      verify: (_) {
        verify(
          () => taskRepository.addTask(userId: 'user-1', title: 'Nova tarefa'),
        ).called(1);
      },
    );

    blocTest<TasksCubit, TasksState>(
      'emite TasksError quando addTask lança exceção',
      build: () {
        when(
          () => taskRepository.addTask(userId: 'user-1', title: 'Nova tarefa'),
        ).thenThrow(Exception('erro'));
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.addTask(userId: 'user-1', title: 'Nova tarefa'),
      expect: () => [const TasksError('Falha ao adicionar tarefa.')],
    );

    blocTest<TasksCubit, TasksState>(
      'não chama o repositório quando o título é vazio ou apenas espaços',
      build: () => TasksCubit(taskRepository),
      act: (cubit) => cubit.addTask(userId: 'user-1', title: '   '),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => taskRepository.addTask(
            userId: any(named: 'userId'),
            title: any(named: 'title'),
          ),
        );
      },
    );
  });

  group('toggleTask', () {
    blocTest<TasksCubit, TasksState>(
      'chama o repositório e não emite estado quando toggleTask tem sucesso',
      build: () {
        when(
          () => taskRepository.toggleTask(userId: 'user-1', task: task),
        ).thenAnswer((_) async {});
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.toggleTask(userId: 'user-1', task: task),
      expect: () => [],
      verify: (_) {
        verify(
          () => taskRepository.toggleTask(userId: 'user-1', task: task),
        ).called(1);
      },
    );

    blocTest<TasksCubit, TasksState>(
      'emite TasksError quando toggleTask lança exceção',
      build: () {
        when(
          () => taskRepository.toggleTask(userId: 'user-1', task: task),
        ).thenThrow(Exception('erro'));
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.toggleTask(userId: 'user-1', task: task),
      expect: () => [const TasksError('Falha ao atualizar tarefa.')],
    );
  });

  group('deleteTask', () {
    blocTest<TasksCubit, TasksState>(
      'chama o repositório e não emite estado quando deleteTask tem sucesso',
      build: () {
        when(
          () => taskRepository.deleteTask(userId: 'user-1', taskId: task.id),
        ).thenAnswer((_) async {});
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.deleteTask(userId: 'user-1', taskId: task.id),
      expect: () => [],
      verify: (_) {
        verify(
          () => taskRepository.deleteTask(userId: 'user-1', taskId: task.id),
        ).called(1);
      },
    );

    blocTest<TasksCubit, TasksState>(
      'emite TasksError quando deleteTask lança exceção',
      build: () {
        when(
          () => taskRepository.deleteTask(userId: 'user-1', taskId: task.id),
        ).thenThrow(Exception('erro'));
        return TasksCubit(taskRepository);
      },
      act: (cubit) => cubit.deleteTask(userId: 'user-1', taskId: task.id),
      expect: () => [const TasksError('Falha ao remover tarefa.')],
    );
  });
}
