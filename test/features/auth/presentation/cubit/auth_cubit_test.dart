import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow_app/features/auth/data/auth_repository.dart';
import 'package:taskflow_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:taskflow_app/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  late AuthRepository authRepository;
  late User user;

  setUp(() {
    authRepository = MockAuthRepository();
    user = MockUser();

    when(() => user.uid).thenReturn('123');
  });

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, Authenticated] when start succeeds',
    build: () {
      when(() => authRepository.ensureSignedIn()).thenAnswer((_) async => user);
      return AuthCubit(authRepository);
    },
    act: (cubit) => cubit.start(),
    expect: () => [const AuthLoading(), isA<Authenticated>()],
  );

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthError] when start fails',
    build: () {
      when(
        () => authRepository.ensureSignedIn(),
      ).thenThrow(Exception('auth failed'));
      return AuthCubit(authRepository);
    },
    act: (cubit) => cubit.start(),
    expect: () => [const AuthLoading(), isA<AuthError>()],
  );
}
