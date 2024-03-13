import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class Graph extends StatefulWidget {
  @override
  GraphScreen createState() => GraphScreen();
}

class GraphScreen extends State<Graph> with TickerProviderStateMixin{

  var tmp = NumberFormat('###,###,###,###');
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late TabController controller;
  late TabController bodytab;
  String year="";
  int selected = 0;
  int category=0;
  int month=0;
  List <String> items =[""];
  List<String> years = [];
  List<FlSpot> spotitems = [];
  List<PieChartSectionData> pieitems=[];
  List<Color> coloritems =[Colors.red,Colors.yellow,Colors.blue,Colors.green,Colors.orange,Colors.amber,Colors.cyanAccent];
  @override
  void initState() {
    getYear();
    super.initState();
    controller = TabController(length: 2, vsync: this);
    bodytab = TabController(length: 1, vsync: this);
  }


  getYear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/getYear.php'),
          body: {"user":user.toString()}
      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        years.clear();
        var tagsJson = jsonDecode(response.body);
        int idx = 0;

        while(tagsJson['webnautes'][idx]!=null){
          years.add(tagsJson['webnautes'][idx]['year'].toString());
          print(years[idx]);
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
      });}

  }

  getCategory(String y) async{
    if(selected==0){
      try {
        http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/category.php'),
        );
        print('statuseCode : ${response.statusCode}');
        if(response.statusCode == 200 || response.statusCode==201){
          items.clear();
          var tagsJson = jsonDecode(response.body);
          int idx = 0;
          items.add("전체");
          while(tagsJson['webnautes'][idx]!=null){
            items.add(tagsJson['webnautes'][idx]['cname']);
            idx++;
          }
        } else {
          print('error......');

        }
      }catch(e) {
        print('error... $e');
      }
    }else{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final user = prefs.getInt('user') ?? 0;
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/getMonth.php'),
            body: {"user":user.toString(),"year":y}
        );
          print('statuseCode : ${response.statusCode}');
          if(response.statusCode == 200 || response.statusCode==201){
            items.clear();
            var tagsJson = jsonDecode(response.body);
            int idx = 0;
            while(tagsJson['webnautes'][idx]!=null){
              items.add(tagsJson['webnautes'][idx]['mon']);
              idx++;
            }
          } else {
            print('error......');

          }
        }catch(e) {
          print('error... $e');
        }
    }
    setState(() {
      bodytab = TabController(
          length: items.length,
          vsync: this);
    });
    setState(() {

    });
  }

  drawGraph() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;
    if(selected==0) {
      print(category);
      spotitems.clear();
      for (int i = 0; i <= 12; i++) {
        spotitems.add(FlSpot(i.toDouble(), 0));
      }
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/lineGraph.php'),
            body: {
              "user": user.toString(),
              "category": category.toString(),
              "year": year
            }
        );
        print('statuseCode : ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          var tagsJson = jsonDecode(response.body);
          int idx = 0;
          while (tagsJson['webnautes'][idx] != null) {
            int mon = int.parse(tagsJson['webnautes'][idx]['mon']);
            spotitems.removeAt(mon);
            spotitems.insert(mon, FlSpot(mon.toDouble(),
                double.parse(tagsJson['webnautes'][idx]['price'])));
            idx++;
          }
        } else {
          print('error......');
        }
      } catch (e) {
        print('error... $e');
      }


      spotitems.removeAt(0);
    }else{
      pieitems.clear();
      try {
        http.Response response = await http.post(
            Uri.parse('http://172.30.1.1:443/pieGraph.php'),
            body: {
              "user": user.toString(),
              "month": month.toString(),
              "year": year
            }
        );
        print('statuseCode : ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          var tagsJson = jsonDecode(response.body);
          int idx = 0;
          while (tagsJson['webnautes'][idx] != null) {
            pieitems.add(PieChartSectionData(title: "${tagsJson['webnautes'][idx]['cname']}: ${tmp.format(int.parse(tagsJson['webnautes'][idx]['price']))}원",value: double.parse(tagsJson['webnautes'][idx]['price']),color: coloritems[idx]));
            idx++;
          }
        } else {
          print('error......');
        }
      } catch (e) {
        print('error... $e');
      }
    }
    setState(() {
    });
  }


    @override
    Widget build(BuildContext context){
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
          key:_scaffoldKey,
          appBar: AppBar(title: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
          bottom: TabBar(
            onTap: (index){
              selected = index;
              category = 0;
              getCategory(year);
              setState(() {

              });
            },
            controller: controller, tabs: [
              Tab(text: "년간 지출 현황"),
              Tab(text: "월별 지출 현황")
          ],
          ),),
          body: TabBarView(
            controller: controller, children:<Widget> [
              Column(
                children: [bodyTab(), Container(width: double.infinity,height: 300,child: LineChart(LineChartData(
            borderData: FlBorderData(show:true),
            lineBarsData: [LineChartBarData(
                spots: spotitems
            )]
        )),)]),

          Column(
            children: [bodyTab(),
              Container(width: double.infinity,height: 300,child: PieChart(PieChartData(
                  borderData: FlBorderData(show:true),
                  sections: pieitems
              )),)],
          ),
          ],
        )


          ,endDrawer: yeardrawer(),
          bottomNavigationBar: bottom(),
        ),
      );
    }

  TabBar bodyTab() {
    return  TabBar(
      dividerColor: Colors.greenAccent,
      dividerHeight: 5,
      controller: bodytab,
      indicatorColor: Colors.white,
      labelPadding: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      tabs: List.generate(items.length, (index) => Text(items[index],style: TextStyle(fontSize: 15,fontStyle: FontStyle.italic),)),
      isScrollable: true,onTap: (index) {category=index; if(selected==1){month=int.parse(items[index]);} drawGraph();});
    }

    Drawer yeardrawer() {
      return Drawer( child:ListView.builder(itemCount: years.length,itemBuilder: (c,idx){
        return ListTile(
            title: Text(years[idx]),
            onTap: () {
              year=years[idx];
              getCategory(year);
              if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState!.closeEndDrawer();
              }

            }
        );
      })
      );
    }
}

