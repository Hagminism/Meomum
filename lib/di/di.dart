import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((Ref ref) {
  return Supabase.instance.client;
});

final geolocatorProvider = Provider<GeolocatorPlatform>((Ref ref) {
  return GeolocatorPlatform.instance;
});

final httpClientProvider = Provider<http.Client>((Ref ref) {
  return http.Client();
});
