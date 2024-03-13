import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
class Record extends StatelessWidget {

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
        appBar: AppBar(leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),),
        body: Column(children: [
          Container(width: double.infinity,height: 50,child: Text("나의 구매기록",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),textAlign: TextAlign.center,))
          ,Container(width: double.infinity,height: 4,color: Colors.black45,),
          RecordList(),


        ],
        ),
        bottomNavigationBar: bottom(),
      ),
    );
  }
}

class Records{
  String idx;
  String price;
  String date;
  Records(this.idx,this.price,this.date);
}

class Details{
  String d_name;
  String std;
  int cnt;
  int price;
  String name;
  Details(this.d_name,this.std,this.cnt,this.price,this.name);
}

class RecordList extends StatefulWidget {
  RecordListState createState() => RecordListState();

}

class RecordListState extends State<RecordList>{
  final isSelected = <bool>[true, false];
  List<Records> items = [];
  List<Details> details = [];
  var tmp = NumberFormat('###,###,###,###');
  @override
  void initState(){
    getData();
    super.initState();

  }


  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/recorditems.php'),
          body: {"user":user.toString()}

      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        var tagsJson = jsonDecode(response.body);
        int idx = 0;
        items.clear();

        while(tagsJson['webnautes'][idx]!=null){
          items.add(Records(tagsJson['webnautes'][idx]['buy_idx'],tagsJson['webnautes'][idx]['price'],tagsJson['webnautes'][idx]['date']));
          idx++;
        }
        setState(() {
        });
      } else {
        print('error......');
        setState(() {
        });
      }
    }catch(e) {
      print('error... $e');
      setState(() {
      });
    }
  }

  getDatail(int idx) async {
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/recordDetail.php'),
          body: {"buy":items[idx].idx}

      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        var tagsJson = jsonDecode(response.body);
        int idx = 0;
        details.clear();

        while(tagsJson['webnautes'][idx]!=null){
          details.add(Details(tagsJson['webnautes'][idx]['d_name'],tagsJson['webnautes'][idx]['std'],int.parse(tagsJson['webnautes'][idx]['cnt']),int.parse(tagsJson['webnautes'][idx]['price']),tagsJson['webnautes'][idx]['name']));
          idx++;
          }
        setState(() {
           });
      } else {
        print('error......');
        setState(() {
        });

      }
    }catch(e) {
      print('error... $e');
      setState(() {
        _showdialog(context);
      });
    }
  }

  Future<dynamic> _showdialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:Text("내역"),
          content: SizedBox(width: 350,height: 300, child: ListView.builder(scrollDirection: Axis.vertical,itemCount: details.length,itemBuilder: (BuildContext context,int index){
            return dialogContainer(
                d_name: details[index].d_name, price: details[index].price, cnt:details[index].cnt,std:details[index].std, name:details[index].name
            );
          },),),
          actions: [
            TextButton(onPressed: (){Navigator.of(context, rootNavigator: true).pop();}, child: Text("닫기")),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          height: 450,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(width: 4,color: Colors.black,),color: Colors.greenAccent),

          alignment: Alignment.center,
          margin: EdgeInsets.all(10),
          child: ListView.builder(scrollDirection: Axis.vertical,itemCount: items.length,itemBuilder: (BuildContext context,int index){
            return postContainer(
                date: items[index].date, price: items[index].price, idx:index
            );
          },)
      )
    ],);
  }

  GestureDetector postContainer(
      {String date = "2024-01-01", String price = "price", int idx=0}) {
    return GestureDetector(
        onTap: (){getDatail(idx);
        },child: Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.fromLTRB(5, 3, 5, 0),
      decoration: BoxDecoration(border: Border.all(width: 4,color: Colors.black),color:Colors.white),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Expanded(flex: 2,child: Text("구매 날짜: $date")),
        Expanded(flex: 2,child: Text("구매 금액: ${tmp.format(int.parse(price))}원"))
      ],),
    ));
  }

  Container dialogContainer(
      {String d_name = "", int price = 0,int cnt=0, String  std="", String name=""}) {
    return  Container(
      width: 300,
      height: 100,
      decoration: BoxDecoration(border: Border.all(width: 1,color: Colors.black),color:Colors.white),
      child: Row(children: [
        Expanded(flex:1, child: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
          decoration: BoxDecoration(border: Border.all(width: 3,color: Colors.black),color:Colors.white)
          ,child: Image.network("http://172.30.1.1:443/$name",fit: BoxFit.fill,),)),
        Expanded(flex:3,child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex:1, child: Text("$d_name")),
          Expanded(flex:1, child: Text("가격: $std/${tmp.format(price)}원")),
          Expanded(flex:1, child: Text("${tmp.format(price)} X $cnt = ${tmp.format(price*cnt)}원"))
        ],),)
      ],)
    );
  }
}