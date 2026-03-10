import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow_app/features/tasks/domain/task_item.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_state.dart';
import 'package:taskflow_app/features/tasks/presentation/widgets/add_task_dialog.dart';

class TasksPage extends StatelessWidget {
  final String userId;

  const TasksPage({super.key, required this.userId});

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const AddTaskDialog(),
    );

    if (title == null || title.trim().isEmpty || !context.mounted) return;

    await context.read<TasksCubit>().addTask(userId: userId, title: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaskFlow')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading || state is TasksInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar tarefas:\n${state.message}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is TasksLoaded) {
            if (state.tasks.isEmpty) {
              return const Center(child: Text('Nenhuma tarefa ainda.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return _TaskTile(userId: userId, task: task);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String userId;
  final TaskItem task;

  const _TaskTile({required this.userId, required this.task});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<TasksCubit>().deleteTask(userId: userId, taskId: task.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa "${task.title}" removida')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: CheckboxListTile(
          value: task.isDone,
          onChanged: (_) {
            context.read<TasksCubit>().toggleTask(userId: userId, task: task);
          },
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Text(
            '${task.createdAt.day.toString().padLeft(2, '0')}/'
            '${task.createdAt.month.toString().padLeft(2, '0')}/'
            '${task.createdAt.year} '
            '${task.createdAt.hour.toString().padLeft(2, '0')}:'
            '${task.createdAt.minute.toString().padLeft(2, '0')}',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
