import 'package:flutter/material.dart';
import 'bottom.dart';
import 'category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context,widget){
        ErrorWidget.builder = (e){
          Widget error = Column(children:[CircularProgressIndicator(value: 70),Text("로딩중입니다.")]);
          if(widget is Scaffold || widget is Navigator){
            error = Scaffold(body:SafeArea(child: error));
          }
          return error;
        };
        return widget!;
      },
      home: Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(100), child: categorytab()),
        body: Column(children: [
          Search(),REList()
        ],
        ),
        bottomNavigationBar: bottom(),
      ),
    );
  }
}

class Home_items {
  String d_name;
  String detail_idx;
  String price;
  String std;
  String name;
  String category;
  Home_items(this.d_name,this.detail_idx,this.price,this.std,this.name,this.category);
}


class Search extends StatefulWidget {
  SearchState createState() => SearchState();
}

class SearchState extends State<Search>{
  var textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return   Container(
        height: 100,
        width: 380,

        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            SearchBar(controller: textController,
              elevation: MaterialStateProperty.all(15),overlayColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              hintText: 'Input Product Name',hintStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
              trailing: [Icon(Icons.search)],
              side: MaterialStateProperty.all(
                  BorderSide(color:Colors.blueAccent,width: 2)
              ),
              onSubmitted: (value){
                Navigator.of(context,rootNavigator: true).pushNamed("/product",arguments:{"word" : value,"category":"","product":""});
              },
            )
          ],
        )
    );
  }
}

class REList extends StatefulWidget {
  REListState createState() => REListState();
}

class REListState extends State<REList>{
  final isSelected = <bool>[true, false];
  List<Home_items> fritems = [];
  List<Home_items> reitems = [];
  List<List> items = [];
  int select=0;
   @override
  void initState(){
    Recent();
    Freq();
    super.initState();

  }

  Recent() async {

    try {
      http.Response response = await http.post(
        Uri.parse('http://172.30.1.1:443/home_recent.php'),
      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        var tagsJson = jsonDecode(response.body);
        int idx = 0;
        reitems.clear();
        while(tagsJson['webnautes'][idx]!=null){
          reitems.add(Home_items(tagsJson['webnautes'][idx]['d_name'],tagsJson['webnautes'][idx]['detail_idx'],tagsJson['webnautes'][idx]['price'],tagsJson['webnautes'][idx]['std'],tagsJson['webnautes'][idx]['name'],tagsJson['webnautes'][idx]['cname']));
          idx++;
        }

      } else {
        print('error......');

      }
    }catch(e) {
      print('error... $e');
      }
    items.insert(0,reitems);
    setState(() {

    });
  }

  Freq() async {
      try {
        http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/home_freq.php'),
        );
        print('statuseCode : ${response.statusCode}');
        if(response.statusCode == 200 || response.statusCode==201){
          var tagsJson = jsonDecode(response.body);
          int idx = 0;
          fritems.clear();
          while(tagsJson['webnautes'][idx]!=null){
            fritems.add(Home_items(tagsJson['webnautes'][idx]['d_name'],tagsJson['webnautes'][idx]['detail_idx'],tagsJson['webnautes'][idx]['price'],tagsJson['webnautes'][idx]['std'],tagsJson['webnautes'][idx]['name'],"${tagsJson['webnautes'][idx]['cname']}(${tagsJson['webnautes'][idx]['perc']}%)",));
            idx++;
          }
        } else {
          print('error......');
        }
      }catch(e) {
        print('error... $e');

      }
      items.insert(1,fritems);
      setState(() {

      });
    }


  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(margin: EdgeInsets.fromLTRB(10, 0, 0, 0), child:
    ToggleButtons( color: Colors.black.withOpacity(0.60),
        selectedColor: Color(0xFF6200EE),
        selectedBorderColor: Color(0xFF6200EE), fillColor: Color(0xFF6200EE).withOpacity(0.08), splashColor: Color(0xFF6200EE).withOpacity(0.12), hoverColor: Color(0xFF6200EE).withOpacity(0.04), borderRadius: BorderRadius.circular(4.0), constraints: BoxConstraints(minHeight: 36.0),
        isSelected: isSelected,
        onPressed: (index) { setState(() { isSelected[index] = true; isSelected[(index+1)%2]=false; select=(select+1)%2;
            setState(() {
            });

        }); },
        children: [ Padding( padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('최신상품'), ),
          Padding( padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('인기상품'), ), ]),)
    ,Container(
        height: 300,
        width: 380,

        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: items[select].length,itemBuilder: (BuildContext context,int index){
              return postContainer(
                d_name: items[select][index].d_name,price: items[select][index].price,std: items[select][index].std,name: items[select][index].name,detail_idx: items[select][index].detail_idx,category: items[select][index].category
              );
      },)
      )
    ],);
  }

  GestureDetector postContainer(
      {String d_name = "Title", String price = "price", String std = "std", String name = "name",String detail_idx = "idx" ,String category="cate"}) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context,rootNavigator: true).pushNamed("/detail",arguments:{"detail_idx": detail_idx});
      },
        child:Stack(
          children: [Container(
      decoration: BoxDecoration(
        border: Border.all(width:3,color:Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          color: Colors.grey
      ),
      width: 300,
      height: 330,
      margin: EdgeInsets.fromLTRB(5, 25, 5, 0),
      child: Column(
        children: [
          Container(
              height: 30,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10),
              child: Text(d_name+std,textAlign: TextAlign.center,style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),)),
          Container(margin: EdgeInsets.all(10), height: 180, width: 200, child: (Image.network("http://172.30.1.1:443/"+name,fit: BoxFit.fill,)),),
          Container(child:(Text("가격:"+price+"원",textAlign: TextAlign.center,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)),)
        ],
      ),
    ),Container(child: Text(category,style: TextStyle(fontStyle: FontStyle.italic,fontSize: 15),),decoration: BoxDecoration(
              border: Border.all(width:3,color:Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
              color: Colors.cyan),alignment: Alignment.topCenter,width: 100,height: 30,margin: EdgeInsets.fromLTRB(30, 0, 0,0),),
          ]));
  }
}