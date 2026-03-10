import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'package:taskflow_app/features/tasks/presentation/pages/tasks_page.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<TasksCubit>().watchTasks(state.user.uid);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const _LoadingPage();
          }

          if (state is Authenticated) {
            return TasksPage(userId: state.user.uid);
          }

          if (state is AuthError) {
            return _ErrorPage(message: state.message);
          }

          return const _LoadingPage();
        },
      ),
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorPage extends StatelessWidget {
  final String message;

  const _ErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Erro ao autenticar: $message',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
