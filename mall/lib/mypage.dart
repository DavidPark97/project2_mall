import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
class Mypage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context,widget){
        ErrorWidget.builder = (e){
          Widget error = Text("");
          if(widget is Scaffold || widget is Navigator){
            error = Scaffold(body:SafeArea(child: error,));
          }
          return error;
        };
        return widget!;
      },
      home: Scaffold(
        appBar: AppBar(),
        body: Column(children: [
          User(),Container(width: double.infinity,height: 3,color: Colors.black38,),
         GestureDetector(
           onTap: (){Navigator.of(context,rootNavigator: true).pushNamed("/record");},
           child: Container(decoration: BoxDecoration(border: Border.all(width:1,color:Colors.greenAccent),color: Colors.grey
            ),margin: EdgeInsets.fromLTRB(0, 10, 0,0),
           width: double.infinity, height: 80,child: Center( child:Text("기록보기",textAlign: TextAlign.center,style:
           TextStyle(color: Colors.white,fontSize: 20),),),),),
          GestureDetector(onTap:(){Navigator.of(context,rootNavigator: true).pushNamed("/graph");},
            child: Container(margin: EdgeInsets.fromLTRB(0, 5, 0,0),
            decoration: BoxDecoration(border: Border.all(width:3,color:Colors.greenAccent),color: Colors.grey),
            width: double.infinity, height: 80,child: Center(
              child: Text("그래프보기",textAlign: TextAlign.center,style:
              TextStyle(color: Colors.white,fontSize: 20),),),),),
          Spacer(),
         Logout(),
        ],
        ),
        bottomNavigationBar: bottom(),
      ),
    );
  }
}


class User extends StatefulWidget {
  UserState createState() => UserState();
}

class UserState extends State<User>{

  late String id;
  late String phone;
  late String address;
  late int total;
  var tmp = NumberFormat('###,###,###,###');
  Future<dynamic> _showdialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:Text("알림"),
          content: Text("로그인이 필요합니다."),
          actions: [
            TextButton(onPressed: (){Navigator.of(context, rootNavigator: true)..pop()..pop();}, child: Text("취소")),
            TextButton(onPressed: (){
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context,rootNavigator: true).pushNamed("/login");
              setState(() {

              });}, child: Text("확인"))

          ],
        )
    );
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
    if(user==0){
      _showdialog(context);
    }else {
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/mypage.php'),
            body: {'user': user.toString()}
        );
        print('statuseCode : ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            var tagsJson = jsonDecode(response.body);
            id= tagsJson['webnautes'][0]['id'];
            phone= tagsJson['webnautes'][0]['phone'];
            address= tagsJson['webnautes'][0]['address'];
            total = int.parse(tagsJson['webnautes'][0]['total']);
            setState(() {});
          });
        } else {
          print('error......');
          setState(() {});
        }
      } catch (e) {
        print('error... $e');
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      child: Row(
        children: [
          Expanded(flex: 1, child: Container(decoration: BoxDecoration(border: Border.all(width:3,color:Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ), child: Column(children: [
            Expanded(flex: 2, child: Container(
              child: Icon(Icons.account_circle),
            ),),
            Expanded(flex:1,child:
            Container(child: Text("$id님")))
          ],),),),
          Expanded(flex: 2, child: Container(decoration: BoxDecoration(border: Border.all(width:3,color:Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex:1, child: Container(child: Text("핸드폰: $phone"),)),
            Container(width: double.infinity,height: 1,color: Colors.black,),
            Expanded(flex:1, child: Container(child: Text("주소: $address",overflow: TextOverflow.ellipsis,),)),
            Container(width: double.infinity,height: 1,color: Colors.black,),
            Expanded(flex:1, child: Container(child: Text("총 사용금액:${tmp.format(total)}원"),)),
          ],),),)
        ],
      ),
    );
  }
}


class Logout extends StatefulWidget {
  logoutState createState() => logoutState();
}

class logoutState extends State<Logout>{


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
     child: Text("로그아웃",style: TextStyle(decoration: TextDecoration.underline),),onPressed: () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      Navigator.of(context,rootNavigator: true).pushNamed("/home");
    },
    );
  }
}