import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_2/main.dart';

void main() {
  runApp(const Timer300());
}

class Timer300 extends StatelessWidget {
  const Timer300({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '3分タイマー'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const FINISH = 'yukumo_0001.mp3';
  final AudioCache _cache = AudioCache(
    fixedPlayer: AudioPlayer(),
  );

  int _timer = 5;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  void startTimer() {
    Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (_timer < 1) {
            timer.cancel();
            _cache.play(FINISH);
          } else {
            _timer = _timer - 1;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("5分タイマー"),
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 32),
            child: Text(
              '残り' + '$_timer' + '秒',
              style: TextStyle(fontSize: 40.0),
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    //timer.cancel();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  },
                  child: Text('タイマーをキャンセル'),
                ),
              ]),
        ]),
      ),
    );
  }
}
