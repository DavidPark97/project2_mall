import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Cate {
  String name;
  String idx;
  Cate(this.name,this.idx);
}

class categorytab extends StatefulWidget {
  categoryState createState() => categoryState();
}
List<Cate> cates = [];
class categoryState extends State<categorytab>
    with SingleTickerProviderStateMixin {
  late TabController controller;


  @override
  void initState() {



    controller = TabController(length:11,vsync: this);
    super.initState();

    onPressPost();

  }

  void updateTabs() {
    try {
      controller = TabController(
        length: cates.length,
        vsync: this,
      );
      setState(() {});
    } catch (on) {
      print(on); // TODO: rem
    }
  }

  onPressPost() async {

    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/category.php'),
          );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        cates.clear();
        var tagsJson = jsonDecode(response.body);
        int idx = 0;
        cates.add(Cate("전체","0"));

        while(tagsJson['webnautes'][idx]!=null){
          cates.add(Cate(tagsJson['webnautes'][idx]['cname'],tagsJson['webnautes'][idx]['category_idx']));
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
    return AppBar(
            bottom: TabBar(
              dividerColor: Colors.greenAccent,
              dividerHeight: 5,
              controller: controller,
              indicatorColor: Colors.white,
              labelPadding: EdgeInsets.all(5),
              padding: EdgeInsets.all(10),
              tabs: List.generate(cates.length, (index) => Text("${cates[index].name}",style: TextStyle(fontSize: 15,fontStyle: FontStyle.italic),)),
            isScrollable: true,onTap: (index){
              Navigator.of(context,rootNavigator: true).pushNamed("/product",arguments:{"word" : "","category": cates[index].idx,"product":""});
            },),
        );

  }
}

