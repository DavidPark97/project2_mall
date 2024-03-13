import 'dart:async';

import 'package:flutter/material.dart';
import 'login.dart';
import 'test.dart';
import 'newAccount.dart';
import 'home.dart';
import 'category.dart';
import 'find.dart';
import 'product.dart';
import 'detail.dart';
import 'cart.dart';
import 'mypage.dart';
import 'record.dart';
import 'graph.dart';
import 'recommend.dart';
void main() {
  runZonedGuarded(() {
    runApp(MyApp());
  },(error,stackTrace){
    print('error');
  });
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => home(),
       },
      onGenerateRoute: (settings) {
        if (settings.name=='/test'){
          return MaterialPageRoute(builder: (context)=>test(),settings: settings
          );
        }else if(settings.name=='/newAccount') {
          return MaterialPageRoute(
              builder: (context) => newAccount(), settings: settings
          );
        }
        else if(settings.name=='/login'){
          return MaterialPageRoute(builder: (context)=>login(),settings: settings
          );
        }else if(settings.name=='/search'){
          return MaterialPageRoute(builder: (context)=>Find(),settings: settings
          );
        }else if(settings.name=='/product'){
          return MaterialPageRoute(builder: (context)=>product(),settings: settings
          );
        }else if(settings.name=='/detail'){
          return MaterialPageRoute(builder: (context)=>Detail(),settings: settings
          );
        }else if(settings.name=='/cart'){
          return MaterialPageRoute(builder: (context)=>Cart(),settings: settings
          );
        }else if(settings.name=='/mypage'){
          return MaterialPageRoute(builder: (context)=>Mypage(),settings: settings
          );
        }else if(settings.name=='/record'){
          return MaterialPageRoute(builder: (context)=>Record(),settings: settings
          );
        }else if(settings.name=='/graph'){
          return MaterialPageRoute(builder: (context)=>Graph(),settings: settings
          );
        }else if(settings.name=='/recommend'){
          return MaterialPageRoute(builder: (context)=>Recommend(),settings: settings
          );
        }
    },
    );
  }
}
