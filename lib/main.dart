import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'amplifyconfiguration.dart';

import 'package:test_final/login_page.dart';
import 'package:test_final/sign_up_page.dart';
import 'package:test_final/auth_service.dart';
import 'package:test_final/Verification_page.dart';
import 'package:test_final/welcome_page.dart';

void main() {
  runApp(MyApp());
}

// 1
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      // 2
      home: StreamBuilder<AuthState>(
      stream: _authService.authStateController.stream,
      builder: (context, snapshot) {
        // 3
        if (snapshot.hasData) {
          return Navigator(
            pages: [
              // 4
              // Show Login Page

              if ( snapshot.data?.authFlowStatus == AuthFlowStatus.login)
                MaterialPage(
                  child: LoginPage(
                      didProvideCredentials: _authService.loginWithCredentials,
                      shouldShowSignUp: _authService.showSignUp)),

              // 5
              // Show Sign Up Page
              if (snapshot.data?.authFlowStatus == AuthFlowStatus.signUp)
                MaterialPage(
                  child: SignUpPage(
                      didProvideCredentials: _authService.signUpWithCredentials,
                      shouldShowLogin: _authService.showLogin)),
            
              if (snapshot.data?.authFlowStatus == AuthFlowStatus.verification)
                MaterialPage(child: VerificationPage(
                  didProvideVerificationCode: _authService.verifyCode)),
              
              if (snapshot.data?.authFlowStatus == AuthFlowStatus.session)
                MaterialPage(
                  child: WelcomePage(shouldLogOut: _authService.logOut ))
            ],
            onPopPage: (route, result) => route.didPop(result),
          );
        } else {
          // 6
          return Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
  void _configureAmplify() async {
    
    Amplify.addPlugin(AmplifyAuthCognito());
    Amplify.addPlugin(AmplifyAPI());

    try {
      await Amplify.configure(amplifyconfig);
       _authService.checkAuthStatus();
      print('Successfully configured Amplify ????');
    } catch (e) {
      print('Could not configure Amplify ??????');
    }
  }
}
