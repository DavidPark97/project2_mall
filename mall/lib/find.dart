import 'package:flutter/material.dart';
import 'bottom.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Find extends StatelessWidget {
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

        body: Column(children: [
          Searchs()
        ],
        ),
        bottomNavigationBar: bottom(),
      ),
    );
  }
}


class Searchs extends StatefulWidget {
  SearchState createState() => SearchState();
}

class SearchState extends State<Searchs>{
  List<String> items = [];
  String keyword ="";
  recommend() async {

    try {
      http.Response response = await http.post(
        Uri.parse('http://172.30.1.1:443/recommend.php'),
          body: {'keyword': keyword}
      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        setState(() {
          var tagsJson = jsonDecode(response.body);
          int idx = 0;
          items.clear();
          while(tagsJson['webnautes'][idx]!=null){
            items.add(tagsJson['webnautes'][idx]['d_name']);
            print(items[idx]);
            idx++;
          }
          setState(() {
          });
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
    return Container(

        alignment: Alignment.center,
        margin: EdgeInsets.fromLTRB(20, 100, 20, 0),
        child: SearchAnchor(
          builder: (context,controller){
            return SearchBar(controller: controller,
              elevation: MaterialStateProperty.all(15),overlayColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey),
              hintText: 'Input Product Name',hintStyle: MaterialStateProperty.all(const TextStyle(color: Colors.white)),
              trailing: [Icon(Icons.search)],
              side: MaterialStateProperty.all(
                  BorderSide(color:Colors.blueAccent,width: 2)
              ),
              onChanged: (value){
              setState(() {

                if(value.length!=0) {
                  keyword = value;
                  Future.delayed(Duration(milliseconds: 100), () {
                    recommend();
                  });
                  Future.delayed(Duration(milliseconds: 300), () {
                    controller.openView();
                  });
                }
              });
              },
              onSubmitted: (value){
                Navigator.of(context,rootNavigator: true).pushNamed("/product",arguments:{"word" : value,"category":"","product":""});
              },
              onTap: (){
              recommend();
              Future.delayed(Duration(milliseconds: 300),(){controller.openView();});

              }
            );

          },  suggestionsBuilder: (context,controller) async {  return [
          ListView.builder(shrinkWrap: true,itemCount: items.length,itemBuilder: (c,idx){
            return ListTile(
              title: Text(items[idx]),
              onTap: () {
                setState((){keyword=items[idx];controller.closeView(items[idx]);});
              },
            );
          })
        ];},)

    );
  }
}