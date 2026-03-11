import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow_app/app/app.dart';
import 'package:taskflow_app/core/theme/theme_cubit.dart';
import 'package:taskflow_app/features/auth/data/auth_repository.dart';
import 'package:taskflow_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow_app/features/tasks/data/task_repository.dart';
import 'package:taskflow_app/features/tasks/presentation/cubit/tasks_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepository();
  final taskRepository = TaskRepository();
  final themeCubit = ThemeCubit();
  await themeCubit.load();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<TaskRepository>.value(value: taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider(
            create: (context) =>
                AuthCubit(context.read<AuthRepository>())..start(),
          ),
          BlocProvider(
            create: (context) => TasksCubit(context.read<TaskRepository>()),
          ),
        ],
        child: const TaskFlowApp(),
      ),
    ),
  );
}
