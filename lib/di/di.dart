import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((Ref ref) {
  return Supabase.instance.client;
});

final googleSignInProvider = Provider<GoogleSignIn>((Ref ref) {
  return GoogleSignIn.instance;
});

final geolocatorProvider = Provider<GeolocatorPlatform>((Ref ref) {
  return GeolocatorPlatform.instance;
});

final httpClientProvider = Provider<http.Client>((Ref ref) {
  return http.Client();
});

// .env에는 URL-Encode된 형태로 저장되어 있어, 쿼리 파라미터로 사용할 때
// http 패키지가 다시 인코딩하면서 이중 인코딩되지 않도록 미리 디코딩해둔다.
final tourApiServiceKeyProvider = Provider<String>((Ref ref) {
  final rawServiceKey = dotenv.env['TOUR_API_SERVICE_KEY'] ?? '';
  return Uri.decodeComponent(rawServiceKey);
});
