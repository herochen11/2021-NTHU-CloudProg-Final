import 'package:flutter/material.dart';
import 'package:test_final/auth_credentials.dart';

class LoginPage extends StatefulWidget {
  
  final ValueChanged<LoginCredentials> didProvideCredentials;

  final VoidCallback shouldShowSignUp;
  LoginPage({Key? key, required this.didProvideCredentials, required this.shouldShowSignUp}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 2
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 40),
          
          child: Stack(
            alignment: Alignment.center,
            children: [
            // Login For
              Padding(
                padding: EdgeInsets.only(bottom: 350),
                child: Image(
                  image: AssetImage('icon/car.png'),
                  width: 120,
                  height: 120,
                ),
              ),
             _loginForm(),
              Container(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                    style: TextButton.styleFrom( 
                        primary: Colors.black,
                    ),
                    onPressed: widget.shouldShowSignUp,
                    child: Text('Don\'t have an account? Sign up.')),
              ),
          ])),
    );
  }

  // 5
  Widget   _loginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        // Usernazme TextField
        Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("Safe Driving",textScaleFactor: 2),
            ),
        TextField(
          controller: _usernameController,
          decoration:
              InputDecoration(icon: Icon(Icons.mail), labelText: 'Username'),
        ),
        // Password TextField
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
              icon: Icon(Icons.lock_open), labelText: 'Password'),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        ),

        // Login Button
        TextButton(
            style: TextButton.styleFrom( 
                primary: Colors.black,
                backgroundColor: Colors.blueAccent
            ),
            onPressed: _login,
            child: Text('Login')),
      ],
    );
  }

  // 7
  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    print('username: $username');
    print('password: $password');

    final credentials = LoginCredentials(username: username, password: password);
    widget.didProvideCredentials(credentials);
  }
}