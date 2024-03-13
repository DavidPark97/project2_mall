import 'package:flutter/material.dart';

class test extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    Map<String,Object> args = ModalRoute.of(context)?.settings.arguments as Map<String,Object>;
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('mall'),
          ),
          body: Column(children: [

            ElevatedButton(onPressed: (){
              Navigator.pushNamed(context,'/login');
            }, child: Text("${args['category']}")),
          ],
          )
      ),
    );
  }
}