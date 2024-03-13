import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class newAccount extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('mall'),
        ),
        body: newAccountScreen(),
      ),
    );
  }
}

class newAccountScreen extends StatefulWidget{
  @override
  newAccountState createState() => newAccountState();
}

class newAccountState extends State<newAccountScreen>{
  final _formKey = GlobalKey<FormState>();
  String? id;
  String? passwd;
  String? passwdchk;
  String? phone;
  String? address;
  bool flag = false;

  void flutterToast() {
    Fluttertoast.showToast(
      msg: 'not unique ID',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.cyanAccent,
      fontSize: 10,
      timeInSecForIosWeb: 1, // 메시지 시간 - iOS 및 웹
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,);

  }

  void chkPasswd() {
    Fluttertoast.showToast(
      msg: 'not accord passwd',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.cyanAccent,
      fontSize: 10,
      timeInSecForIosWeb: 1, // 메시지 시간 - iOS 및 웹
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,);

  }

  idChk() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/idchk.php'),
          body: {'id': id});
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        setState(() {
          var tagsJson = jsonDecode(response.body);
          String user_idx  = "${tagsJson['webnautes'][0]['user_idx']}";
          flag = false;
          flutterToast();
        });
      } else {
        print('error......');
      }
    }catch(e) {
      print('error... $e');
      setState(() {
        flag = true;
      });

    }
  }

  createAccount() async {
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/newAccount.php'),
          body: {'id': id,'passwd':passwd, 'phone':phone, 'address':address});
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        setState(() {
          Navigator.of(context,rootNavigator: true).pushNamed("/login");
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
        Text('new Account',style: TextStyle(color: Colors.black, fontSize: 20),),
        Form(key: _formKey,
          child: Column(
            children: <Widget> [
              Container(
                margin: EdgeInsets.only(left:20,right: 20),
                child: Column(children: [

                    TextFormField(
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
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'passwd check'
                    ),
                    validator: (value){
                      if (value?.isEmpty??false){
                        return 'Please enter check Password';
                      }
                      return null;
                    },
                    onSaved: (String? value){
                      passwdchk = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'phone'
                    ),
                    validator: (value){
                      if (value?.isEmpty??false){
                        return 'Please enter Phone';
                      }
                      return null;
                    },
                    onSaved: (String? value){
                      phone = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'address'
                    ),
                    validator: (value){
                      if (value?.isEmpty??false){
                        return 'Please enter Address';
                      }
                      return null;
                    },
                    onSaved: (String? value){
                      address = value;
                    },
                  ),
                ],
                ),
              )

            ],
          ),),
        ElevatedButton(onPressed: (){
          if(_formKey.currentState?.validate()??false){
            _formKey.currentState?.save();
            idChk();

            Future.delayed(Duration(microseconds: 2000),(){
              if(flag==true) {
                if(passwd == passwdchk) {
                  createAccount();
                }else{
                  chkPasswd();
                }
              }

            });

          }
        }, child: Text('Create')),
      ],
    );
  }
}