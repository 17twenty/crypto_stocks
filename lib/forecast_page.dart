import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto_market/models.dart';
import 'package:http/http.dart' as http;

class ForecastPage extends StatefulWidget {

  ForecastPage({Key key, this.coin}) : super(key: key);

  final Coin coin;

  @override
  _ForecastPageState createState() => new _ForecastPageState();

}

class _ForecastPageState extends State<ForecastPage> {

  static const platform = const MethodChannel('samples.flutter.io/battery');
  Map<String, List> data;
  double max;
  double min;
  double diff;
  bool isLoading = true;
  String graphData = "";
  int n = 0;
  String _batteryLevel = 'Unknown battery level.';

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://coinbin.org/" + widget.coin.symbol + "/forecast"),
        headers: {
          "Accept": "application/json"
        }
    );

    this.setState(() {
      data = json.decode(response.body);
      isLoading = false;
      max = data['forecast'][0]['usd'];
      min = data['forecast'][0]['usd'];
      data['forecast'].forEach((value) {
        max < value['usd'] ? max = value['usd'] : max;
        min > value['usd'] ? min = value['usd'] : min;
        if(n<29) {
          graphData = graphData + value['usd'].toString() + ",";
          n++;
        }
      });
      graphData = graphData.substring(0,graphData.length-1);
      print(max.toString());
      print(min.toString());
      print(diff = max - min);
    });

    return "Success!";
  }

  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<Null> _getOnePlusOne() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getOnePlusOne');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.coin.name),
        centerTitle: true,
      ),
      body: isLoading ? showProgressIndicator() : new RefreshIndicator(
//        child: new ListView.builder(
//          scrollDirection: Axis.horizontal,
//          itemCount: data['forecast'] == null ? 0 : data['forecast'].length,
//          itemBuilder: _itemBuilder,
//        ),
//        child: new CustomPaint(
//          size: new Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
//          painter: new LineGraph(data['forecast'], max, min, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
//        ),
        child: new Image(
          image: new NetworkImage("http://chart.googleapis.com/chart?cht=lc&chxt=x,y&chs=400x200&chd=t:" + graphData + "&chds=" + min.toString() + "," + max.toString() + "&chxl=0:|0|7|14|21|28&chm=o,0066FF,0,-7,6&chls=2,2,2&chg=" + (100/28).toString() + ",20,1,5&chxr=1," + min.toString() + "," + max.toString() + "&chxs=1N*cUSD*", scale: 1.0),
        ),
        onRefresh: getData,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Forecast forecast = getPrice(index);
    return new ForecastItemWidget(forecast: forecast);
  }

  Widget showProgressIndicator() {
    return new Center(
      child: Platform.isAndroid ? new CircularProgressIndicator() : new CupertinoActivityIndicator(),
    );
  }

  Forecast getPrice(int index) {
    return new Forecast(
      data['forecast'][index]['timestamp'],
      data['forecast'][index]['usd'],
      data['forecast'][index]['when'],
    );
  }

}

class LineGraph extends CustomPainter {

  static const barWidth = 10.0;

  LineGraph(List data, double max, double min, double width, double height);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    List offsetList = [new Offset(2.0, 5.0), new Offset(100.0, 100.0), new Offset(200.0, 100.0),];
//    canvas.drawPoints(PointMode.lines, offsetList, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}

class ForecastItemWidget extends StatefulWidget {

  ForecastItemWidget({Key key, this.forecast}) : super(key: key);

  final Forecast forecast;

  @override
  _ForecastItemWidgetState createState() => new _ForecastItemWidgetState();

}

class _ForecastItemWidgetState extends State<ForecastItemWidget> {

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Text(widget.forecast.usd.toString()),
      ],
    );
  }

}