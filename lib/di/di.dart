import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((Ref ref) {
  return Supabase.instance.client;
});

final googleSignInProvider = Provider<GoogleSignIn>((Ref ref) {
  return GoogleSignIn.instance;
});
