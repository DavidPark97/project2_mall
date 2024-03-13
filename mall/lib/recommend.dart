import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class reList {
  String items;
  double perc;
  String idx;
  String keys;
  reList(this.keys,this.items,this.idx,this.perc);
}

class plList{
  String p_name;
  String idx;
  plList(this.p_name,this.idx);
}

class Recommend extends StatefulWidget {
  @override
  RecommendScreen createState() => RecommendScreen();
}

class RecommendScreen extends State<Recommend> with TickerProviderStateMixin {
  List<plList> plitems = [];
  List<bool> chks = [];
  List<reList> reitems =[];
  @override
  void initState() {
    getItems();
    Future.delayed(Duration.zero,(){

      super.initState();
    });

  }

  getItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/productlist.php'),
          body: {'user': user.toString()}
      );
      print('statuseCode : ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        var tagsJson = jsonDecode(response.body);
        int idx = 0;
        plitems.clear();
        while (tagsJson['webnautes'][idx] != null) {
          plitems.add(plList(tagsJson['webnautes'][idx]['p_name'],tagsJson['webnautes'][idx]['product_idx']));
          chks.add(false);
          idx++;

        }
        setState(() {

        });
      } else {
        print('error......');
      }
    } catch (e) {
      print('error... $e');
      setState(() {

      });
    }
    setState(() {
      _showdialog(context);
    });

  }

  getList() async {
    if(chks.contains(true)) {
      String selected="";
      for(int i=0;i<plitems.length;i++){
        if(chks[i]==true){
          selected+="${plitems[i].idx},";
        }
      }
      selected=selected.substring(0,selected.length-1);
      Navigator.of(context).pop();
      _waitdialog(context);
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/apriori.php'),
            body: {'selected': selected}
        );
        print('statuseCode : ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          var tagsJson = jsonDecode(response.body);

          int idx = 0;
          reitems.clear();
          while (tagsJson['webnautes'][idx] != null) {
            reitems.add(reList(tagsJson['webnautes'][idx]['keys'],
                tagsJson['webnautes'][idx]['items'],tagsJson['webnautes'][idx]['idx'],double.parse(tagsJson['webnautes'][idx]['perc'])));
            chks.add(false);
            idx++;
          }

        } else {
          print('error......');
        }
      } catch (e) {
        print('error... $e');
      }

    }else{
      flutterToast();
    }
    Navigator.of(context).pop();
    setState(() {

    });
  }

  void flutterToast() {
    Fluttertoast.showToast(
      msg: '아이템을 선택하세요',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.cyanAccent,
      fontSize: 10,
      timeInSecForIosWeb: 1, // 메시지 시간 - iOS 및 웹
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,);

  }

  Future<dynamic> _showdialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(title: const Text("추천 기준 상품 선택"),
              content: SizedBox(width: 350,
                height: 300,
                child: ListView.builder(scrollDirection: Axis.vertical,
                  itemCount: plitems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return dialogContainer(
                        p_name: plitems[index].p_name, idx: index
                    );
                  },),),
              actions: [
                TextButton(onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                    ..pop()..pop();
                }, child: Text("닫기")),
                TextButton(onPressed: () {getList();}, child: Text("검색"))
              ],);
          },
        );
      },
    );
  }

  Future<dynamic> _waitdialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(title: const Text("추천 기준 상품 선택"),
              content: SizedBox(width: 350,
                height: 300,
                child: Column(children: [
                  CircularProgressIndicator(value: 50,),
                  Text("분석중입니다..")
            ],)

            ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) {
        ErrorWidget.builder = (e) {
          Widget error = Text("");
          if (widget is Scaffold || widget is Navigator) {
            error = Scaffold(body: SafeArea(child: error,));
          }
          return error;
        };
        return widget!;
      },
      home: Scaffold(
        appBar: AppBar(title: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back))),
        body: Column(children: [
          Container(width: double.infinity,height: 500, child: ListView.builder(scrollDirection: Axis.vertical,itemCount: reitems.length,itemBuilder: (BuildContext context,int index){
            return postContainer(
                items:reitems[index].items, keys:reitems[index].keys,  perc:reitems[index].perc, idx:reitems[index].idx
            );
          },))
        ],)
        , bottomNavigationBar: bottom(),
      ),
    );
  }

  Container dialogContainer({String p_name = "", int idx = 0}) {
    return Container(
        width: 300,
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black),
            color: Colors.white),
        child: Row(children: [
          Expanded(
              flex: 1, child: Checkbox(value: chks[idx], onChanged: (value) {
            setState(() {
            });
            Navigator.of(context).pop();
            _showdialog(context);
            chks[idx] = value!;

          })),
          Expanded(flex: 3, child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: Text(p_name)
            ,)
          )
        ]
        )
    );
  }

  GestureDetector postContainer(
      {String items="",String keys="",double perc=0.0, String idx=""}) {
    return GestureDetector(
        onTap: (){
          Navigator.of(context,rootNavigator: true).pushNamed("/product",arguments:{"word" : "","category":"","product":idx});
        },child: Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.black)),
      child: Row(children: [
        Text("$keys와 같이 구매된 상품: $items (${perc*100}%확률)")
    ])));
  }
}
