import 'dart:async' show Timer;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:intl/intl.dart';

void main() {
  if (Platform.isAndroid) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Clock(),
        backgroundColor: Colors.black,
      ),
    );
  }
}

class Clock extends StatefulWidget {
  Clock({Key? key}) : super(key: key);

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  BinaryTime _now = BinaryTime();

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (v) {
      setState(() {
        _now = BinaryTime();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClockColumn(
              binaryInteger: _now.hourTens,
              title: "H",
              color: Colors.blue,
              rows: 2,
            ),
            ClockColumn(
              binaryInteger: _now.hourOnes,
              title: 'h',
              color: Colors.lightBlue,
            ),
            ClockColumn(
              binaryInteger: _now.minuteTens,
              title: 'M',
              color: Colors.green,
              rows: 3,
            ),
            ClockColumn(
              binaryInteger: _now.minuteOnes,
              title: 'm',
              color: Colors.lightGreen,
            ),
            ClockColumn(
              binaryInteger: _now.secondTens,
              title: 'S',
              color: Colors.pink,
              rows: 3,
            ),
            ClockColumn(
              binaryInteger: _now.secondOnes,
              title: 's',
              color: Colors.pinkAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class BinaryTime {
  List<String>? binaryInt;

  BinaryTime() {
    DateTime now = DateTime.now();
    String hhmmss = DateFormat("Hms").format(now).replaceAll(":", " ");
    List<String> timeParts = hhmmss.split(' ');

    // Ensure timeParts has exactly six elements
    if (timeParts.length == 3) {
      String hours = timeParts[0].padLeft(2, '0');
      String minutes = timeParts[1].padLeft(2, '0');
      String seconds = timeParts[2].padLeft(2, '0');
      binaryInt = [
        hours.substring(0, 1),
        hours.substring(1, 2),
        minutes.substring(0, 1),
        minutes.substring(1, 2),
        seconds.substring(0, 1),
        seconds.substring(1, 2),
      ].map((str) => int.parse(str).toRadixString(2).padLeft(4, '0')).toList();
    }
  }

  get hourTens => binaryInt?[0];

  get hourOnes => binaryInt?[1];

  get minuteTens => binaryInt?[2];

  get minuteOnes => binaryInt?[3];

  get secondTens => binaryInt?[4];

  get secondOnes => binaryInt?[5];
}

class ClockColumn extends StatelessWidget {
  late String binaryInteger;
  late String title;
  late Color color;
  late int rows;
  late List bits;

  ClockColumn(
      {super.key,
      required this.binaryInteger,
      required this.title,
      required this.color,
      this.rows = 4}) {
    bits = binaryInteger.split('');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ...[
        Container(
          child: Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
      ],
      ...bits.asMap().entries.map((entry) {
        int idx = entry.key;
        String bit = entry.value;
        bool isActive = bit == '1';
        num binaryCellValue = pow(2, 3 - idx);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 475),
          curve: Curves.ease,
          height: 40,
          width: 30,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: isActive
                  ? color
                  : idx < 4 - rows
                      ? Colors.white.withOpacity(0)
                      : Colors.black),
          margin: const EdgeInsets.all(4),
          child: Center(
            child: isActive
                ? Text(
                    binaryCellValue.toString(),
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.2),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  )
                : Container(),
          ),
        );
      }),
      ...[
        Text(
          int.parse(binaryInteger, radix: 2).toString(),
          style: TextStyle(fontSize: 30, color: color),
        ),
        Container(
          child: Text(
            binaryInteger,
            style: TextStyle(fontSize: 15, color: color),
          ),
        )
      ]
    ]);
  }
}
