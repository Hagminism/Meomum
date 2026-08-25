import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meomum/core/auth/auth0_session.dart';
import 'package:meomum/core/routing/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------ 화면 방향 고정 ------------ //
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // ------------ .env 로드 ------------ //
  await dotenv.load(fileName: '.env');

  // ------------ Supabase 초기화 ------------ //
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    accessToken: Auth0Session.idToken,
  );

  // ------------ Naver Map SDK 초기화 ------------ //
  final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
  if (naverMapClientId == null || naverMapClientId.isEmpty) {
    throw StateError('NAVER_MAP_CLIENT_ID가 .env에 설정되지 않았습니다.');
  }

  await FlutterNaverMap().init(
    clientId: naverMapClientId,
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          debugPrint('Naver Map 사용량 초과 (message: $message)');
        case NUnauthorizedClientException() ||
            NClientUnspecifiedException() ||
            NAnotherAuthFailedException():
          debugPrint('Naver Map 인증 실패: $ex');
      }
    },
  );

  // ------------ main 앱 실행 ------------ //
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Meomum',
      routerConfig: router,
    );
  }
}
