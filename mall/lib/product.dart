import 'package:flutter/material.dart';
import 'bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Categorys {
  String name;
  String idx;
  Categorys(this.name,this.idx);
}

class Products{
  String name;
  String idx;
  Products(this.name,this.idx);
}

class list_items {
  String d_name;
  String detail_idx;
  String price;
  String std;
  String name;
  list_items(this.d_name,this.detail_idx,this.price,this.std,this.name);
}

class product extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Map<String,Object> args = ModalRoute.of(context)?.settings.arguments as Map<String,Object>;
    String word = "${args['word']}";
    String category = "${args['category']}";
    String prss = "${args['product']}";
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
          prSearch(word),item_List(word, prss, category),
        ],
        ),
        drawer: ListDrawer(category),
        bottomNavigationBar: bottom(),
      ),
    );
  }
}



class prSearch extends StatefulWidget {
  final String word;
  prSearch(this.word) : super();
  prSearchState createState() => prSearchState();
}

class prSearchState extends State<prSearch>{

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: 380,
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [

            SearchBar(controller: TextEditingController(text: widget.word),
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

class ListDrawer extends StatefulWidget {
  String category;
  ListDrawer(this.category) : super();
  DrawerState createState() => DrawerState();
}

class DrawerState extends State<ListDrawer>{
  List<Categorys> cates = [];
  List<Products> prs = [];
  @override
  void initState(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onPressPost();
      getProducts(widget.category);
    });

  }

  onPressPost() async {
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/category.php')
      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        cates.clear();
        var tagsJson = jsonDecode(response.body);
        int idx = 0;

        while(tagsJson['webnautes'][idx]!=null){
          cates.add(Categorys(tagsJson['webnautes'][idx]['cname'],tagsJson['webnautes'][idx]['category_idx']));
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

  getProducts(String tmp) async {
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/prlist.php'),
          body: {'category': tmp}
      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        prs.clear();
        var tagsJson = jsonDecode(response.body);
        int idx = 0;

        while(tagsJson['webnautes'][idx]!=null){
          prs.add(Products(tagsJson['webnautes'][idx]['p_name'],tagsJson['webnautes'][idx]['product_idx']));
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

  @override
  Widget build(BuildContext context) {

    return Drawer( child:ListView.builder(itemCount: cates.length,itemBuilder: (c,idx){
      if(widget.category==cates[idx].idx&&prs.length!=0) {
        return Scrollbar(child: Column(children: [
          ListTile(
              title: Text(cates[idx].name),
              onTap: () {

                setState(() {

                });
              }
          ),ListView.builder(shrinkWrap: true,itemCount: prs.length,itemBuilder: (c2,idx2){
            return ListTile(
                horizontalTitleGap: 20,
                leading: Icon(Icons.add),
                title: Text(prs[idx2].name,),
                onTap: () {
                  print(prs[idx2].idx);
                  Navigator.of(context,rootNavigator: true).pushNamed("/product",arguments:{"word" : "","category":cates[idx].idx,"product":prs[idx2].idx});
                }
            );})],),);
      }else{
        return ListTile(
            title: Text(cates[idx].name),
            onTap: () {
              widget.category=cates[idx].idx;
              setState(() {
                getProducts(cates[idx].idx);
              });
            }
        );
      }})
    );}
}


class item_List extends StatefulWidget {
  itemListState createState() => itemListState();
  String word,prs,cates;
  item_List(this.word,this.prs,this.cates) : super();
}

class itemListState extends State<item_List>{
  final isSelected = <bool>[true, false];
  List<list_items> items = [];

  @override
  void initState(){
    getItems(widget.prs,widget.cates,widget.word);
    super.initState();

  }


  getItems(String product,String category, String word) async {
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/listitems.php'),
          body: {'word': word,'product':product,'category':category}

      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        var tagsJson = jsonDecode(response.body);
        int idx = 0;
        items.clear();

        while(tagsJson['webnautes'][idx]!=null){
          items.add(list_items(tagsJson['webnautes'][idx]['d_name'],tagsJson['webnautes'][idx]['detail_idx'],tagsJson['webnautes'][idx]['price'],tagsJson['webnautes'][idx]['std'],tagsJson['webnautes'][idx]['name']));
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


  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          height: 400,
          width: 380,

          alignment: Alignment.center,
          margin: EdgeInsets.all(10),
          child: ListView.builder(scrollDirection: Axis.vertical,itemCount: items.length,itemBuilder: (BuildContext context,int index){
            return postContainer(
                d_name: items[index].d_name,price: items[index].price,std: items[index].std,name: items[index].name,detail_idx: items[index].detail_idx
            );
          },)
      )
    ],);
  }

  GestureDetector postContainer(
      {String d_name = "Title", String price = "price", String std = "std", String name = "name",String detail_idx = "idx"}) {
    return GestureDetector(
        onTap: (){
          Navigator.of(context,rootNavigator: true).pushNamed("/detail",arguments:{"detail_idx": detail_idx});
        },child: Container(
      width: double.infinity,
      height: 100,
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.black)),
      child: Row(children: [
        Container(decoration: BoxDecoration(border:Border.all(width: 3,color: Colors.lightGreen)),margin: EdgeInsets.all(10), height: 100, width: 100, child: (Image.network("http://172.30.1.1:443/"+name)),)
      ,Container(child: Column(children: [
        Text(d_name,textAlign: TextAlign.center,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
          Row(children: [
            Text("판매량: $std",textAlign: TextAlign.start,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
            Text("가격:  $price",textAlign: TextAlign.end,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
          ],)
    ],),)],),
    ));
  }
}