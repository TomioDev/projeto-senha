import 'package:flutter/material.dart';
import './component/sign_in_form.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Força da senha',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        textTheme: TextTheme().copyWith(
            bodyText2: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      home: MyHomePage(title: 'Força da senha'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(child: SignInForm()),
    );
  }
}
