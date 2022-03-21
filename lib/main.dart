import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_leaks/object_util.dart';
import 'package:flutter_leaks/service_util.dart';
import 'package:vm_service/vm_service.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final data = [];

  Future<void> _incrementCounter() async {

    Singleton().value = Leak(this);

    Expando? expando = Expando();
    expando[Singleton().value] = true;
    //模拟释放资源
   // Singleton().value = null;
    await gc();

    final weakPropertyKeys = await getWeakPropertyKeys(expando);
    //
    expando = null;
    weakPropertyKeys.forEach((element) async {

       getRetainingPath(element.id!).then((path){
         print('path length = ${path.length}');

         path.elements?.forEach((p) {
           print('${p.value}');
           if(p.value is InstanceRef){
             InstanceRef instanceRef = p.value as InstanceRef;
             print('内存泄漏链路 ---->  ${instanceRef}');
           }else if(p.value is FieldRef){
             FieldRef fieldRef = p.value as FieldRef;
             print('内存泄漏链路 ---->  ${fieldRef}');
           }

         });
       });
    });
   // print('weakPropertyKeys = $weakPropertyKey');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();

  }
}

class Singleton {
  static final Singleton _singleton = Singleton._();

  factory Singleton() => _singleton;

  Singleton._();

  dynamic value;
}

class Leak{
  dynamic obj;
  Leak(this.obj);
}
