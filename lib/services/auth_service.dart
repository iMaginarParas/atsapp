import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(supabaseClientProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? ref.read(supabaseClientProvider).auth.currentUser;
});

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signInWithGoogle() async {
    const webClientId = 'YOUR_WEB_CLIENT_ID'; 
    
    // 1. Initialize
    await GoogleSignIn.instance.initialize(
      // clientId: webClientId,
    );
    
    // 2. Trigger the native Google Sign-In flow
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

    // 3. Obtain the auth details
    final String? idToken = googleUser.authentication.idToken;
    final authz = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
    final String? accessToken = authz.accessToken;

    if (idToken == null || accessToken == null) {
      throw 'Missing Google Auth Tokens';
    }

    // 4. Sign in to Supabase using the Google ID Token
    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});
