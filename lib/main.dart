import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Clock'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer _timer;
  final PublishSubject<DateTime> _subject = PublishSubject<DateTime>();

  @override
  void initState() {
    super.initState();

    _subject.sink.add(DateTime.now());

    _timer = Timer.periodic(
      Duration(milliseconds: 1000),
      (time) {
        setState(() => _subject.sink.add(DateTime.now()));
        print('now: ${DateTime.now()}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('ぱたぱた時計', style: TextStyle(fontSize: 32)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 0.8,
              color: Colors.blueGrey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FlipWidget(subject: _subject, func: (dt) => dt.minute ~/ 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FlipWidget(subject: _subject, func: (dt) => dt.minute % 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 15.0),
                    child: Text(
                      '分',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 0.8,
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FlipWidget(subject: _subject, func: (dt) => dt.second ~/ 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FlipWidget(
                        subject: _subject, func: (dt) => dt.second % 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 20.0),
                    child: Text(
                      '秒',
                      style: TextStyle(fontSize: 50),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef TResult Func<T, TResult>(T source);

class FlipWidget extends StatefulWidget {
  final Func<DateTime, int> func;
  final PublishSubject<DateTime> subject;
  FlipWidget({Key key, this.subject, this.func}) : super(key: key);

  @override
  _FlipWidgetState createState() => _FlipWidgetState();
}

class _FlipWidgetState extends State<FlipWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _halfTopFlipAnimation;
  Animation _halfBottomFlipAnimation;
  Stream<DateTime> stream;

  Widget _child1;
  Widget _backCard;
  int _oldTime = 0;
  int _newTime = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // 上半分の板を0からpi / 2.0まで回転させるAnimation
    _halfTopFlipAnimation = Tween<double>(begin: 0.0, end: pi / 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.linear),
      ),
    );

    // 下半分の板を-pi / 2.0から0まで回転させるAnimation
    _halfBottomFlipAnimation = Tween<double>(begin: 0.0, end: pi / 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.linear),
      ),
    );

    _child1 = _buildFlipCard('$_oldTime');
    _backCard = _buildFlipCard('$_newTime');

    // streamの設定
    if (this.widget?.subject?.stream == null) {
      print('stream is null');
      return;
    }

    if (this.widget?.func == null) {
      print('func is null');
      return;
    }

    this
        .widget
        .subject
        .stream
        .where((dt) => this.widget.func(dt) != _newTime)
        .listen(
      (time) {
        // print('stream is alive.');
        setState(() {
          _oldTime = _newTime;
          _newTime = this.widget.func(time);
          _child1 = _buildFlipCard('$_oldTime');
          _backCard = _buildFlipCard('$_newTime');
          _animationController.reset();
          _animationController.forward();
        });
      },
    );
  }

  Widget _buildFlipCard(String text) {
    return Container(
      color: Colors.yellow,
      width: 90,
      height: 130,
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget widget) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _backCard,
                    heightFactor: 0.5,
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.006)
                    ..rotateX(_halfTopFlipAnimation.value),
                  alignment: Alignment.bottomCenter,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.5,
                      child: _child1,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.0),
            ),
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ClipRect(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 0.5,
                    child: _child1,
                  ),
                ),
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.006)
                    ..rotateX(-pi / 2.0 + _halfBottomFlipAnimation.value),
                  alignment: Alignment.topCenter,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 0.5,
                      child: _backCard,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}