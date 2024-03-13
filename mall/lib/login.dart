import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class login extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('mall'),
        ),
        body: loginScreen(),
      ),
    );
  }
}

class loginScreen extends StatefulWidget{
  @override
  loginState createState() => loginState();
}

class loginState extends State<loginScreen>{
  final _formKey = GlobalKey<FormState>();
  String? id;
  String? passwd;
  String user_idx = '';

  void flutterToast() {
    Fluttertoast.showToast(
      msg: 'check your Id and password',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.cyanAccent,
      fontSize: 10,
      timeInSecForIosWeb: 1, // 메시지 시간 - iOS 및 웹
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,);

  }

  onPressPost() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/login.php'),
          body: {'id': id,'passwd':passwd});
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        setState(() {
          var tagsJson = jsonDecode(response.body);
          user_idx  = "${tagsJson['webnautes'][0]['user_idx']}";

          prefs.setInt('user', int.parse(user_idx));
          Navigator.of(context, rootNavigator: true).pop();
        });
      } else {
        print('error......');
      }
    }catch(e) {
     print('error... $e');
     flutterToast();
    }
  }





  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Login',style: TextStyle(color: Colors.black, fontSize: 20),),
        Form(key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            Container(
              margin: EdgeInsets.only(left:20,right: 20),
              child: Column(children: [   TextFormField(
              decoration: InputDecoration(
                  labelText: 'id'
              ),
              validator: (value){
                if (value?.isEmpty??false){
                  return 'Please enter ID';
                }
                return null;
              },
              onSaved: (String? value){
                id = value;
              },
            ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'passwd'
                ),
                validator: (value){
                  if (value?.isEmpty??false){
                    return 'Please enter Password';
                  }
                  return null;
                },
                onSaved: (String? value){
                  passwd = value;
                },
              ), ],),)

          ],
        ),),
        ElevatedButton(onPressed: (){
          if(_formKey.currentState?.validate()??false){
            _formKey.currentState?.save();
            onPressPost();

          }
        }, child: Text('login')),
        RichText(
          text: TextSpan(
          text: 'New Account',
          style: TextStyle(color:Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blueGrey),
            recognizer: TapGestureRecognizer() .. onTapDown = (details){
            Navigator.of(context,rootNavigator: true).pushNamed("/newAccount");
          }

        ),)
    ],
    );
  }
}