import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? username;
  final bool isLoading;
  final bool isInitializing;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.username,
    this.isLoading = false,
    this.isInitializing = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? username,
    bool? isLoading,
    bool? isInitializing,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isInitializing: true)) {
    _checkAuthStatus();
  }

  final Logger _logger = Logger();

  Future<void> _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final attributes = await Amplify.Auth.fetchUserAttributes();

        String? displayUsername;
        String? userEmail;

        for (var attr in attributes) {
          if (attr.userAttributeKey == AuthUserAttributeKey.preferredUsername) {
            displayUsername = attr.value;
          } else if (attr.userAttributeKey == AuthUserAttributeKey.email) {
            userEmail = attr.value;
          }
        }

        state = state.copyWith(
          isAuthenticated: true,
          userId: user.userId,
          username: displayUsername,
          email: userEmail,
          isInitializing: false,
        );
      } else {
        state = state.copyWith(isInitializing: false);
      }
    } catch (e) {
      _logger.e('Error checking auth status: $e');
      state = state.copyWith(isInitializing: false);
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
            AuthUserAttributeKey.preferredUsername: username,
          },
        ),
      );

      state = state.copyWith(isLoading: false);
      return {'success': true, 'needsVerification': true};
    } on AuthException catch (e) {
      _logger.e('Sign up error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);

      // Check if user already exists but needs verification
      if (e.message.toLowerCase().contains('username') ||
          e.message.toLowerCase().contains('user already exists') ||
          e.message.toLowerCase().contains('already exists')) {
        return {
          'success': false,
          'needsVerification': true,
          'error': 'Account already exists. Please verify your email.',
        };
      }

      return {'success': false, 'needsVerification': false, 'error': e.message};
    } catch (e) {
      _logger.e('Unexpected sign up error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return {
        'success': false,
        'needsVerification': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> confirmSignUp({
    required String email,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: code,
      );

      if (result.isSignUpComplete) {
        state = state.copyWith(isLoading: false);
      }
    } on AuthException catch (e) {
      _logger.e('Confirm sign up error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      if (result.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final attributes = await Amplify.Auth.fetchUserAttributes();

        String? displayUsername;

        for (var attr in attributes) {
          if (attr.userAttributeKey == AuthUserAttributeKey.preferredUsername) {
            displayUsername = attr.value;
          }
        }

        state = state.copyWith(
          isAuthenticated: true,
          userId: user.userId,
          email: email,
          username: displayUsername,
          isLoading: false,
        );
      }
    } on AuthException catch (e) {
      _logger.e('Sign in error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      state = AuthState();
    } on AuthException catch (e) {
      _logger.e('Sign out error: ${e.message}');
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.resetPassword(username: email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      _logger.e('Reset password error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> confirmResetPassword({
    required String email,
    required String newPassword,
    required String confirmationCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      _logger.e('Confirm reset password error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> resendSignUpCode({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.resendSignUpCode(username: email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      _logger.e('Resend sign up code error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> updateEmail({required String newEmail}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.updateUserAttribute(
        userAttributeKey: AuthUserAttributeKey.email,
        value: newEmail,
      );
      state = state.copyWith(isLoading: false, email: newEmail);
    } on AuthException catch (e) {
      _logger.e('Update email error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  Future<void> confirmEmailUpdate({required String confirmationCode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.confirmUserAttribute(
        userAttributeKey: AuthUserAttributeKey.email,
        confirmationCode: confirmationCode,
      );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      _logger.e('Confirm email update error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      _logger.e('Change password error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Amplify.Auth.deleteUser();
      state = AuthState();
    } on AuthException catch (e) {
      _logger.e('Delete account error: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }
}
