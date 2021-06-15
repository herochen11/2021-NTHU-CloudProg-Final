import 'dart:async';
import 'package:test_final/auth_credentials.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// 1
enum AuthFlowStatus { login, signUp, verification, session }

// 2
class AuthState {
  final AuthFlowStatus authFlowStatus;

  AuthState({required this.authFlowStatus});
}

// 3
class AuthService {
  // 4
  final authStateController = StreamController<AuthState>();
  late AuthCredentials _credentials;
  // 5
  void showSignUp() {
    final state = AuthState(authFlowStatus: AuthFlowStatus.signUp);
    authStateController.add(state);
  }

  // 6
  void showLogin() {
    final state = AuthState(authFlowStatus: AuthFlowStatus.login);
    authStateController.add(state);
  }

  void loginWithCredentials(AuthCredentials credentials) async {
    try {
      // 2
      final result = await Amplify.Auth.signIn(
          username: credentials.username, password: credentials.password);

      // 3
      if (result.isSignedIn) {
        final state = AuthState(authFlowStatus: AuthFlowStatus.session);
        authStateController.add(state);
      } else {
        // 4
        print('User could not be signed in');
      }
    } on AuthException catch (authError) {
      print('Could not login - ${authError.message}');
    }
  }

// 2
  void signUpWithCredentials(SignUpCredentials credentials) async {
    try {
      // 2
      final userAttributes = {'email': credentials.email};

      // 3
      final result = await Amplify.Auth.signUp(
          username: credentials.username,
          password: credentials.password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));

      // 4
      print('result message - ${result.nextStep.signUpStep}');
      if (result.nextStep.signUpStep == 'CONFIRM_SIGN_UP_STEP' ) {
        this._credentials = credentials;
        final state = AuthState(authFlowStatus: AuthFlowStatus.verification);
        authStateController.add(state);
      } else {
        
        loginWithCredentials(credentials);
      }
    
    // 7
    } on AuthException catch (authError) {
      print('Failed to sign up - ${authError.message}');
    }
  }

  void verifyCode(String verificationCode) async {
    try {
      // 2
      final result = await Amplify.Auth.confirmSignUp(
          username: _credentials.username, confirmationCode: verificationCode);

      // 3
      if (result.isSignUpComplete) {
        loginWithCredentials(_credentials);
      } else {
        // 4
        // Follow more steps
      }
    } on AuthException catch (authError) {
      print('Could not verify code - ${authError.message}');
    }
  }
  
  void logOut() async {
    try {
      // 1
      await Amplify.Auth.signOut();

      // 2
      showLogin();
    } on AuthException catch (authError) {
      print('Could not log out - ${authError.message}');
    }
  }

  void checkAuthStatus() async {
    
    try {
      AuthSession res = await Amplify.Auth.fetchAuthSession(options: CognitoSessionOptions(getAWSCredentials: true));
     
      final state = AuthState(authFlowStatus: AuthFlowStatus.session);
      authStateController.add(state);
      print('state result1 : ${res.isSignedIn}');
      print('state result2 : ${state.authFlowStatus}');
    } catch (e) {
      
      final state = AuthState(authFlowStatus: AuthFlowStatus.login);
      authStateController.add(state);
     
    }
  }
}