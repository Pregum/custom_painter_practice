import 'dart:math';
import 'package:flutter/material.dart';
import 'my_custom_painter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class RandomColor {
  static Color randomColor() {
    var ran = Random();
    var r = ran.nextInt(255);
    var g = ran.nextInt(255);
    var b = ran.nextInt(255);
    return Color.fromARGB(255, r, g, b);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<MovableStackItem> movableItems = <MovableStackItem>[];

  MovableStackItem _item;
  GlobalKey<_MovableStackItemState> _itemKey;
  Widget lineWidget = Container();

  void remove(MovableStackItem item) {
    setState(() {
      // var result = this.movableItems.remove(item);
      // var result = this.movableItems.removeWhere((s) => s.key))
      print('item key: ${item.key}');
      this.movableItems.removeWhere((x) => item.id == x.id);
      // print('remove result: $result');
    });
  }

  void zorderMove(MovableStackItem item) {
    remove(item);
    setState(() {
      // this.movableItems.insert(0, item);
      this.movableItems.add(item);
    });
  }

  void setItem(MovableStackItem item) {
    setState(() {
      _item = item;
      _itemKey = item.key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: <Widget>[
                    RaisedButton(
                      child: Icon(Icons.adjust),
                      onPressed: () {
                        setState(() {
                          lineWidget = _getLine();
                        });
                      },
                    )
                  ],
                )),
          ),
          Expanded(
            flex: 10,
            child: Stack(
              children: [
                ...movableItems,
                ...?[lineWidget],
                // (movableItems.length >= 2 ? MyPainterWidget() : null)
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              // color: Theme.of(context).primaryColor,
              child: (_item != null && _itemKey != null)
                  ? Slider(
                      value: _itemKey.currentState.scale,
                      // value: _item.scale,
                      onChanged: (double value) {
                        setState(() {
                          // _itemKey.currentState.scale = value;
                          _itemKey.currentState.setScale(value);
                          // _item.scale = value;
                          print('item.scale: ${_itemKey.currentState.scale}');
                        });
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            var movableStackItem = MovableStackItem(
              this,
              key: GlobalKey<_MovableStackItemState>(),
            );
            movableItems.add(movableStackItem);
            // movableStackItem.deleteStream
            //     .listen((result) => movableItems.remove(movableStackItem));
          });
        },
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _getLine() {
    if (movableItems.length < 2) {
      print('movableItems length is less than 2.');
      return Container();
    }
    print('draw line.');
    var startPos = movableItems[0].key.currentState as _MovableStackItemState;
    var endPos = movableItems[1].key.currentState as _MovableStackItemState;
    var startXPos = startPos.xPosition + (startPos.width / 2);
    var startYPos = startPos.yPosition + (startPos.height / 2);
    var endXPos = endPos.xPosition + (endPos.width / 2);
    var endYPos = endPos.yPosition + (endPos.height / 2);

    // return MyPainterWidget(startPos.xPosition , endPos.xPosition,
    //     startPos.yPosition, endPos.yPosition);
    return MyPainterWidget(startXPos, endXPos, startYPos, endYPos);
  }

  void updateLine(){
    setState(() {
      lineWidget = _getLine();
    });
  }
}

class MovableStackItem extends StatefulWidget {
  // final StreamController<bool> _deleteStreamController =
  //     StreamController<bool>.broadcast();
  // Stream<bool> get deleteStream => _deleteStreamController.stream;

  _MyHomePageState parent;
  Key id;
  GlobalKey key;

  MovableStackItem(this.parent, {this.key, this.id}) : super(key: key);

  @override
  _MovableStackItemState createState() => _MovableStackItemState();
}

class _MovableStackItemState extends State<MovableStackItem> {
  double xPosition = 0;
  double yPosition = 0;
  final double width = 80;
  final double height = 80;
  Color color;
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
    color = RandomColor.randomColor();
    this.widget.id ??= Key(color.red.toString());
  }

  @override
  void dispose() {
    super.dispose();
    // this.widget._deleteStreamController.close();
  }

  void setScale(double val) {
    setState(() {
      scale = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
        onTap: () {
          this.widget.parent.setItem(this.widget);
          this.widget.parent.zorderMove(this.widget);
        },
        onPanUpdate: (DragUpdateDetails tapInfo) {
          setState(() {
            xPosition += tapInfo.delta.dx;
            yPosition += tapInfo.delta.dy;
            this.widget.parent.updateLine();
          });
        },
        onLongPress: () async {
          var result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('confirm'),
                content: Text('delete confirm'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      return Navigator.of(context).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () {
                      return Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (result ?? false) {
            // this.widget._deleteStreamController.add(true);
            print('delete xPos: $xPosition, yPos: $yPosition');
            this.widget.parent.remove(this.widget);
          }
        },
        child: Transform.scale(
          child: Container(
            width: width,
            height: height,
            color: color,
          ),
          scale: this.scale,
        ),
      ),
    );
  }
}
