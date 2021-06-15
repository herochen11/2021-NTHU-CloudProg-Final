import 'package:flutter/material.dart';


class WelcomePage extends StatelessWidget {
  
  final VoidCallback shouldLogOut;
  WelcomePage({Key? key,required this.shouldLogOut})
      : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        bottomOpacity: 0.0,
        elevation: 0.0,
        title: Text(
          'Safe Driving',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          textAlign: TextAlign.right,
        ),
        leading: IconButton(onPressed:(){}, icon: Icon(Icons.menu), color: Colors.black,iconSize: 50,),
        actions: [
          // 4
          // Log Out Button
          Padding(
            padding: const EdgeInsets.all(8),
            child:
                GestureDetector(child: Icon(Icons.logout,color: Colors.black,), onTap: shouldLogOut),
          )
        ],
      ),
    );
  }
}

