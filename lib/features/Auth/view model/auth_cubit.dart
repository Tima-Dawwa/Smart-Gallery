import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_service.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit(this.authService) : super(InitialAuthState());

  final AuthService authService;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(LoadingAuthState());
    var response = await authService.login(username: username, password: password);
    response.fold(
      (failure) {
        emit(FailureAuthState(failure: failure));
      },
      (res) {
        final message = res['message'];
        print(message);
        emit(SuccessAuthState());
      },
    );
  }

  Future<void> register({
    required String username,
    required String password,
    required int age,
  }) async {
    emit(LoadingAuthState());
    var response = await authService.register(
      username: username,
      password: password,
      age: age,
    );

    response.fold(
      (failure) {
        emit(FailureAuthState(failure: failure));
      },
      (res) {
        final message = res['message'];
        print(message);
        emit(SuccessAuthState());
      },
    );
  }
}
