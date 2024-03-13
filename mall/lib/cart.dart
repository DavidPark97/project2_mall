import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cart extends StatelessWidget {

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
          Container(width: double.infinity,height: 50,child: Text("나의 장바구니",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),textAlign: TextAlign.center,))
          ,Container(width: double.infinity,height: 4,color: Colors.black45,)
          ,cartList(),

        ],
        ),
        bottomNavigationBar: bottom(),
      ),
    );
  }
}

class cartItems {
  String d_name;
  String detail_idx;
  String cart_idx;
  String price;
  String std;
  String name;
  int cnt;
  int chk;
  cartItems(this.d_name,this.detail_idx,this.price,this.std,this.name,this.cnt,this.chk,this.cart_idx);
}

class cartList extends StatefulWidget {
  cartState createState() => cartState();
}

class cartState extends State<cartList>{
  final isSelected = <bool>[true, false];
  List<cartItems> items = [];
  List<bool> chks = [];
  int sum=0;
  bool? chkAll=false;
  @override
  void initState(){
    getItems();
    super.initState();
  }

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
              Navigator.of(context,rootNavigator: true).pushNamed("/login");}, child: Text("확인"))
          ],
        )
    );
  }

  Future<dynamic> _buydialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:Text("알림"),
          content: Text("구매를 확정할까요?."),
          actions: [
            TextButton(onPressed: (){Navigator.of(context, rootNavigator: true).pop();}, child: Text("취소")),
            TextButton(onPressed: (){
              buys();
              Navigator.of(context, rootNavigator: true).pushNamed('/home');}, child: Text("확인"))
          ],
        )
    );
  }


  void flutterToast() {
    Fluttertoast.showToast(
      msg: '선택된 아이템이 없습니다',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.cyanAccent,
      fontSize: 10,
      timeInSecForIosWeb: 1, // 메시지 시간 - iOS 및 웹
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,);

  }

  buy() async{

    if(chks.contains(true)) {
      _buydialog(context);
    }else{
      flutterToast();
    }
  }
  buys() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/buy.php'),
            body: {
              'user': user.toString(),
            });
        print('statuseCode : ${response.statusCode}');
        setState(() {

        });
      } catch (e) {
        print('error... $e');
      }
  }

  deleteall() async{
    for(int i=items.length-1;i>=0;i--) {
      if (chks[i] == true) {
        try {
          http.Response response = await http.post(
              Uri.parse('http://172.30.1.1:443/delete.php'),
              body: {
                'cart': items[i].cart_idx,
              });
          print('statuseCode : ${response.statusCode}');
          items.removeAt(i);
          chks.removeAt(i);
          setState(() {

          });
        } catch (e) {
          print('error... $e');
        }
      }
    }
  }

  delete(int idx) async{
        try {
          http.Response response = await http.post(
              Uri.parse('http://172.30.1.1:443/delete.php'),
              body: {
                'cart': items[idx].cart_idx,
              });
          print('statuseCode : ${response.statusCode}');
          items.removeAt(idx);
          chks.removeAt(idx);
          setState(() {

          });
        } catch (e) {
          print('error... $e');
        }
  }
  Future<dynamic> _ask(BuildContext context){
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:Text("경고"),
          content: Text("체크한 아이템들을 삭제할까요?."),
          actions: [
            TextButton(onPressed: (){Navigator.of(context, rootNavigator: true).pop();}, child: Text("취소")),
            TextButton(onPressed: (){deleteall(); Navigator.of(context, rootNavigator: true).pop();},child: Text("삭제")),
          ],
        )
    );
  }

  void chkall() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
    int tmp = 0;
    if(chkAll==true){
      tmp=1;
    }
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/chkall.php'),
          body: {
            'user': user.toString(),
            'chk':tmp.toString(),
             });
      print('statuseCode : ${response.statusCode}');
    } catch (e) {
      print('error... $e');
    }
  }

  void chkchange(int idx) async {
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/chkchange.php'),
          body: {
            'cart': items[idx].cart_idx,
            'chk': items[idx].chk.toString(),
          });
      print('statuseCode : ${response.statusCode}');
    } catch (e) {
      print('error... $e');
    }
  }

  getItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
    if (user == 0) {
      _showdialog(context);
    } else {
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/cartlist.php'),
            body: {'user': user.toString()}
        );
        print('statuseCode : ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          var tagsJson = jsonDecode(response.body);
          int idx = 0;
          items.clear();
          while (tagsJson['webnautes'][idx] != null) {
            items.add(cartItems(
                tagsJson['webnautes'][idx]['d_name'],
                tagsJson['webnautes'][idx]['detail_idx'],
                tagsJson['webnautes'][idx]['price'],
                tagsJson['webnautes'][idx]['std'],
                tagsJson['webnautes'][idx]['name'],
                int.parse(tagsJson['webnautes'][idx]['cnt']),
                int.parse(tagsJson['webnautes'][idx]['chk']),
                tagsJson['webnautes'][idx]['cart_idx']));
            if (items[idx].chk == 1) {
              chks.add(true);
            } else {
              chks.add(false);
            }
            sum += int.parse(items[idx].price) * items[idx].cnt;
            idx++;
          }
          setState(() {});
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
  Future<void> increment(int idx) async {
        try {
          http.Response response = await http.post(
              Uri.parse('http://172.30.1.1:443/increment.php'),
              body: {
                'cart': items[idx].cart_idx,
              });
          print('statuseCode : ${response.statusCode}');
        } catch (e) {
          print('error... $e');
    }
    items[idx].cnt++;
        sum+=int.parse(items[idx].price);
    setState(() {

    });

  }

  Future<void> decrement(int idx) async {
    if(items[idx].cnt-1>=1) {
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/decrement.php'),
            body: {
              'cart': items[idx].cart_idx,
            });
        print('statuseCode : ${response.statusCode}');
      } catch (e) {
        print('error... $e');
      }

      sum-=int.parse(items[idx].price);
      items[idx].cnt--;
    }else{
      items[idx].cnt=1;
    }
    setState(() {
    });

  }

  @override
  Widget build(BuildContext context) {


    return Column(children: [
      Container(
          height: 500,
          width: double.infinity,
          alignment: Alignment.center,
          margin: EdgeInsets.all(5),
          child: Column(children:[
            Container(margin: EdgeInsets.fromLTRB(5, 0, 5, 10),height: 20,width: double.infinity,child: Row(children: [
              Checkbox(value: chkAll, onChanged: (bool? value){
                setState(() {
                  chkAll = value;
                  chkall();
                  for(int i=0;i<items.length;i++){
                    if(chkAll==true){
                      items[i].chk=1;
                    }else{
                      items[i].chk=0;
                    }
                    chks[i] = value!;
                  }
                });
              }),Spacer(flex: 1,),IconButton(onPressed: ()=> _ask(context), icon: Icon(Icons.delete))
            ],),)
            ,Container(width: double.infinity,height: 300, child: ListView.builder(scrollDirection: Axis.vertical,itemCount: items.length,itemBuilder: (BuildContext context,int index){
              return postContainer(
                  d_name: items[index].d_name,price: items[index].price,std: items[index].std,name: items[index].name,detail_idx: items[index].detail_idx, cnt: items[index].cnt, chk:items[index].chk, idx:index
              );
            },)),
            Container(margin: EdgeInsets.fromLTRB(0, 10, 0, 10),width: double.infinity,child: Row(children: [
              TextButton(onPressed: (){Navigator.of(context,rootNavigator: true).pushNamed("/recommend");}, child: Text("상품 추천받기",textAlign: TextAlign.start,style: TextStyle(decoration: TextDecoration.underline,fontSize: 13),)),
              Spacer(),
              Text("총액:$sum원",textAlign: TextAlign.end,style: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),)],)
              ,),
            ElevatedButton(onPressed: buy, child: Text("구매하기"),style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,shadowColor: Colors.grey,padding: EdgeInsets.fromLTRB(100, 10, 120, 10)
            ),)])
      )
    ],);
  }

  GestureDetector postContainer(
      {String d_name = "Title", String price = "price", String std = "std", String name = "name",String detail_idx = "idx", int cnt = 0, int chk=0, int idx =0}) {
    return GestureDetector(
        onTap: (){
          Navigator.of(context,rootNavigator: true).pushNamed("/detail",arguments:{"detail_idx": detail_idx});
        },child: Container(
      width: double.infinity,
      height: 100,
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.black)),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Checkbox(value: chks[idx], onChanged: (value){
        chks[idx] = value!;
        items[idx].chk= (items[idx].chk+1)%2;
        if(value==false){
          chkAll=value;
        }
        chkchange(idx);
        setState(() {

        });

      }),
        Row(children: [
          IconButton(onPressed:()=> decrement(idx), icon: Icon(Icons.remove),constraints: BoxConstraints(),padding: EdgeInsets.zero,),
          Text("${items[idx].cnt}",style: TextStyle(fontSize: 15),),
          IconButton(onPressed:()=> increment(idx), icon: Icon(Icons.add),constraints: BoxConstraints(),padding: EdgeInsets.zero,)
        ],)],),
        Container(decoration: BoxDecoration(border:Border.all(width: 3,color: Colors.lightGreen)),margin: EdgeInsets.all(10), height: 100, width: 100, child: (Image.network("http://172.30.1.1:443/"+name)),)
        ,Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(d_name,textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,overflow:TextOverflow.ellipsis),),IconButton(onPressed: ()=>delete(idx), icon: Icon(Icons.delete))],),
          Row(children: [
            Text("기준/가격: $std / $price원",textAlign: TextAlign.start,style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),),
          ],),
          Row(children: [
            Text("선택수량: $cnt 총액: ${int.parse(price)*cnt}원",textAlign: TextAlign.start,style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),),
          ],)
        ],),)],),
    ));
  }
}
