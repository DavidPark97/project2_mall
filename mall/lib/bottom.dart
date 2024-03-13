import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BottomCounter extends GetxController{
  int _selectedIndex = 0;

  @override
  onInit(){
    super.onInit();
  }

  @override
  onClose() {
    super.onClose();
}
}

class bottom extends StatefulWidget {
  bottomState createState() => bottomState();
}


class bottomState extends State<bottom>{

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

  final GetxController = Get.put(BottomCounter());
  void _onItemTapped(int index){
    setState(() {
        GetxController._selectedIndex = index;

        if(GetxController._selectedIndex==0){
          Navigator.of(context,rootNavigator: true).pushNamed("/home");
        }else if(GetxController._selectedIndex==1){
          Navigator.of(context,rootNavigator: true).pushNamed("/search");
        }else if(GetxController._selectedIndex==2){
          Navigator.of(context, rootNavigator: true).pushNamed("/cart");
        }else if(GetxController._selectedIndex==3){
          Navigator.of(context, rootNavigator: true).pushNamed("/mypage");
        }

    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
           type: BottomNavigationBarType.shifting,
           showSelectedLabels: true,
           showUnselectedLabels: true,
           items: <BottomNavigationBarItem>[
             BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.black),label:'home',backgroundColor: Colors.cyan),
             BottomNavigationBarItem(icon: Icon(Icons.search,color: Colors.black),label:'search',backgroundColor: Colors.cyan),
             BottomNavigationBarItem(icon: Icon(Icons.shopping_cart,color: Colors.black),label:'cart',backgroundColor: Colors.cyan,),
             BottomNavigationBarItem(icon: Icon(Icons.account_circle,color: Colors.black),label:'my',backgroundColor: Colors.cyan),
           ],
           currentIndex: GetxController._selectedIndex,
           onTap: _onItemTapped,



      );

  }
}