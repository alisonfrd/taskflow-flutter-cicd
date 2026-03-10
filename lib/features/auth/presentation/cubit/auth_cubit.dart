import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow_app/features/auth/data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  Future<void> start() async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.ensureSignedIn();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
