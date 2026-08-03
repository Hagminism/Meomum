import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meomum/core/routing/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------ .env 로드 ------------ //
  await dotenv.load(fileName: '.env');

  // ------------ Supabase 초기화 ------------ //
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // ------------ GoogleSignIn 초기화 ------------ //
  final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
  final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];

  if (webClientId == null || webClientId.isEmpty) {
    throw StateError('GOOGLE_WEB_CLIENT_ID가 .env에 설정되지 않았습니다.');
  }

  // webClientId는 웹과 Android 공통으로 사용되고,
  // iOS의 경우 id 자동 매칭이 약하여 clientId에 명시.
  // Android는 Google Cloud Console에 등록만 해두면 됨.
  await GoogleSignIn.instance.initialize(
    clientId: (iosClientId == null || iosClientId.isEmpty) ? null : iosClientId,
    serverClientId: webClientId,
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
