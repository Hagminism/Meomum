import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/data/repository/auth/auth_repository_impl.dart';
import 'package:meomum/core/domain/enum/auth_session_status.dart';
import 'package:meomum/core/presentation/service/auth_session_controller.dart';
import 'package:meomum/feature/splash/presentation/screen/splash_screen.dart';

class SplashScreenRoot extends ConsumerWidget {
  const SplashScreenRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final authSessionController = ref.watch(authSessionControllerProvider);

    return ListenableBuilder(
      listenable: authSessionController,
      builder: (BuildContext context, Widget? child) {
        final isError = authRepository.sessionStatus == AuthSessionStatus.error;

        return SplashScreen(
          isError: isError,
          errorMessage: authRepository.sessionErrorMessage,
          onRetry: isError ? authRepository.retrySessionRestore : null,
        );
      },
    );
  }
}
