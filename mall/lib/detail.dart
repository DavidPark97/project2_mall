import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'bottom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Img{
  String name;
  Img(this.name);
}


class Detail extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Map<String,Object> args = ModalRoute.of(context)?.settings.arguments as Map<String,Object>;
    String detail_idx = "${args['detail_idx']}";

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
          Container(child: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),alignment: Alignment.topLeft,),
          Container(child:detailScreen(detail_idx))
        ],
        ),

        bottomNavigationBar: bottom(),
      ),
    );
  }
}



class detailScreen extends StatefulWidget{
  String detail;
  detailScreen(this.detail) : super();
  detailState createState() => detailState();
}

class detailState extends State<detailScreen> {
  String cate="";
  String product="";
  String price="";
  String d_name="";
  String content="";
  String std="";
  int cnt = 1;
  List<Img> imgs = [];
  int activeIndex = 0;

  insert() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getInt('user') ?? 0;

    if (user == 0) {
      _showdialog(context);
    } else {

        try {
          http.Response response = await http.post(
              Uri.parse('http://172.30.1.1:443/addCart.php'),
              body: {
                'cnt': cnt.toString(),
                'user': user.toString(),
                'detail': widget.detail,
              });
          print('statuseCode : ${response.statusCode}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            Navigator.of(context, rootNavigator: true).pop();

          } else {
            print('error......');
          }
        } catch (e) {
          print('error... $e');

        }
    }
  }

  Future<dynamic> _showdialog(BuildContext context){
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
        title:Text("알림"),
        content: Text("로그인이 필요합니다."),
        actions: [
          TextButton(onPressed: (){Navigator.of(context, rootNavigator: true).pop();}, child: Text("취소")),
          TextButton(onPressed: (){
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context,rootNavigator: true).pushNamed("/login");}, child: Text("확인"))
      ],
    )
    );
  }

  getData() async {
    try {
      http.Response response = await http.post(
          Uri.parse('http://172.30.1.1:443/detail.php'),
          body: {"detail":widget.detail}
      );
      print('statuseCode : ${response.statusCode}');
      if(response.statusCode == 200 || response.statusCode==201){
        var tagsJson = jsonDecode(response.body);
        cate = tagsJson['webnautes'][0]['cname'];
        product = tagsJson['webnautes'][0]['p_name'];
        price = tagsJson['webnautes'][0]['price'];
        d_name = tagsJson['webnautes'][0]['d_name'];
        std = tagsJson['webnautes'][0]['std'];
        content = tagsJson['webnautes'][0]['content'];
        print("$cate $product $price $d_name $std $content");
        int idx = 0;
        while(tagsJson['imgs'][idx]!=null){
          imgs.add(Img(tagsJson['imgs'][idx]['name']));
          print(imgs[idx].name);
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
  void initState() {
    // TODO: implement initState
    getData();

    super.initState();


  }
  void increment(){
    cnt++;
    setState(() {

    });
  }

  void decrement(){
    if(cnt-1>=0) {
      cnt--;
      }else{
      cnt=0;
    }
    setState(() {
    });

  }

  Widget imageSlider(path, index) => Container(
    width: double.infinity,
    height: 240,
    color: Colors.grey,
    child: Image.network(path, fit: BoxFit.cover),
  );

  Widget indicator() => Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      alignment: Alignment.bottomCenter,
      child: AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: imgs.length,
        effect: JumpingDotEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.white,
            dotColor: Colors.white.withOpacity(0.6)),
      ));
  @override
  Widget build(BuildContext context) {

    return Column(children: [
      Stack(alignment: Alignment.bottomCenter, children: <Widget>[
        CarouselSlider.builder(
          options: CarouselOptions(
            initialPage: 0,
            viewportFraction: 1,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) => setState(() {
              activeIndex = index;
            }),
          ),
          itemCount: imgs.length,
          itemBuilder: (context, index, realIndex) {
            String path = "http://172.30.1.1:443/${imgs[index].name}";
            print("${imgs[index]}");
            return imageSlider(path, index);
          },
        ),
        Align(alignment: Alignment.bottomCenter, child: indicator())
      ]),Container(width:double.infinity,margin:EdgeInsets.all(10),alignment: Alignment.topLeft,
          child:Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text("$cate  ▶  $product",style: const TextStyle(fontSize: 17,fontStyle: FontStyle.italic, color: Colors.grey),textAlign: TextAlign.left),
            Row(children: [Text("$d_name",style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
              Spacer(),
              IconButton(onPressed: decrement, icon: Icon(Icons.remove)),
              Text("$cnt",style: TextStyle(fontSize: 15),),
              IconButton(onPressed: increment, icon: Icon(Icons.add))],)
            ,Text("기준/가격: $std / $price원",style: const TextStyle(fontSize: 18),),
            SizedBox(height: 100,),
            ElevatedButton(onPressed: insert, child: Text("${int.parse(price)*cnt}원 장바구니에 담기"),style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,shadowColor: Colors.grey,padding: EdgeInsets.fromLTRB(100, 10, 120, 10)
            ),)
          ]))
    ],);
  }
}