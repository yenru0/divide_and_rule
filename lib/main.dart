import 'dart:async';
import 'dart:convert';

import 'package:divide_and_rule/Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(App());
}

const test_subject = "test-src";

const main_BG_Color = Color.fromRGBO(120, 120, 120, 120);
const main_bar_Color = Color.fromRGBO(30, 30, 30, 180);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(title: 'Flutter Demo Home Page'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class StartSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StartSettingState();
}

class Executing extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ExecutingState();
  }
}

class Option extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OptionState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      //appBar: AppBar(),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Divide & Rule", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
          Wrap(
            spacing: 20,
            children: [
              TextButton(
                  onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (context) => Executing() /* StartSetting() */)),
                  child: Text(
                    "시작하기",
                  ),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    primary: Colors.deepPurpleAccent,
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.push(ctx, MaterialPageRoute(builder: (context) => Option()));
                  },
                  child: Text(
                    "설정하기",
                  ),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    primary: Colors.deepPurpleAccent,
                  )),
            ],
          ),
        ],
      )),
      backgroundColor: OptionData.main_BG_color,
    );
  }
}

class _StartSettingState extends State<StartSetting> {
  var selected = "";

  @override
  Widget build(BuildContext ctx) {
    return FutureBuilder(
        future: rootBundle.loadString("assets/s1.json"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            var data = json.decode(snapshot.data);

            return Scaffold(
              appBar: AppBar(
                title: Text("시작 설정"),
                backgroundColor: OptionData.main_bar_color,
              ),
              body: Center(
                  child: ListView(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                children: [
                  Align(
                      child: DropdownButton(
                          onChanged: (value) {},
                          items: data.keys.map<DropdownMenuItem>((value) {
                            return DropdownMenuItem(value: value, child: Text(value));
                          }).toList())),
                  Align(
                    child: Text("장조"),
                  ),
                  Align(
                      child: TextButton(
                    onPressed: () {
                      Navigator.push(ctx, MaterialPageRoute(builder: (context) => Executing()));
                    },
                    child: Text("실행"),
                    style: TextButton.styleFrom(
                      primary: Colors.red,
                    ),
                  ))
                ],
              )),
              backgroundColor: OptionData.main_BG_color,
            );
          }
          return Center(child: Text("미안..."));
        });
  }
}

class _ExecutingState extends State<Executing> {
  Context _aContext;
  List<bool> _matched = List.generate(1, (index) => true);

  List<Widget> hint;

  QuestionManager qm;

  DateTime start;
  DateTime now;

  Timer _timer;

  TextEditingController _translationController = TextEditingController();
  TextEditingController _wordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    rootBundle.loadString("assets/s1.json").then((value) {
      qm = QuestionManager(json.decode(value), forced: OptionData.additional_parameter_forced);
      start = DateTime.now();
      _timer = Timer.periodic(Duration(milliseconds: 250), (t) => setState(() => now = DateTime.now()));

      setState(nextContext);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void reFrame(BuildContext ctx) {
    setState(() {
      _matched = judgeContext(_wordsController.text, _aContext);

      if (_matched.every((e) => e)) {
        nextContext(ctx: ctx);
      } else {}
    });
  }

  void nextContext({BuildContext ctx}) {
    _aContext = qm.next();
    if (_aContext == null) {
      (ctx != null) ? finish(ctx) : null;
    } else {
      _translationController.text = _aContext.translation ?? '';
      _wordsController.text = '';
      var temp = List.generate((_aContext.words.length * OptionData.hint_rate).toInt(), (index) => Random().nextInt(_aContext.words.length)).toSet().toList();
      temp.sort();
      hint = temp
          .map(
            (int e) => InkWell(
                onTap: () {
                  if (_wordsController.text.endsWith(" ")) {
                    _wordsController.text += _aContext.words[e];
                    _wordsController.selection = TextSelection.collapsed(offset: _wordsController.text.length);
                  } else {
                    _wordsController.text += " " + _aContext.words[e];
                    _wordsController.selection = TextSelection.collapsed(offset: _wordsController.text.length);
                  }
                },
                child: Card(
                  child: Container(
                    child: Text(
                      "${_aContext.words[e]}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    padding: EdgeInsets.fromLTRB(9, 2, 9, 2),
                  ),
                  margin: EdgeInsets.fromLTRB(9, 6, 6, 9),
                  color: Colors.amber,
                )),
          )
          .toList();
    }
  }

  void finish(BuildContext ctx) {
    _translationController.text = "fin";
    _wordsController.text = "fin";
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    if (qm == null) {
      return Scaffold();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("실행 중 (${qm.chosen})"),
        backgroundColor: OptionData.main_bar_color,
        actions: [
          if (now != null)
            Container(
                padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(
                  "${now.difference(start).inSeconds}",
                  style: TextStyle(inherit: true, fontSize: 32),
                  textAlign: TextAlign.right,
                ),
              alignment: Alignment.center,

            ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        Container(
          child: TextFormField(
            decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(color: _matched.every((e) => e) ? Colors.blueAccent : Colors.redAccent)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _matched.every((e) => e) ? Colors.blueAccent : Colors.redAccent)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _matched.every((e) => e) ? Colors.blueAccent : Colors.redAccent)),
                hintText: "translation"),
            style: TextStyle(fontSize: 20, color: Colors.white),
            keyboardType: TextInputType.multiline,
            controller: _translationController,
            maxLines: null,
            expands: false,
            readOnly: true,
            textAlign: TextAlign.center,
          ),
          padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
        ),
        Container(
          child: TextFormField(
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) => reFrame(context),
            decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(color: _matched.every((e) => e) ? Colors.blueAccent : Colors.redAccent)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _matched.every((e) => e) ? Colors.blueAccent : Colors.redAccent)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _matched.every((e) => e) ? Colors.blueAccent : Colors.redAccent)),
                hintText: "write correct context"),
            style: TextStyle(fontSize: 20, color: Colors.white),
            keyboardType: TextInputType.text,
            controller: _wordsController,
            maxLines: null,
            expands: false,
            textAlign: TextAlign.center,
          ),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        ),
        Container(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
            child: _matched.every((e) => e)
                ? null
                : SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) => Container(
                          width: 21,
                          color: _matched[index] ? Colors.green : Colors.red,
                          child: Text(
                            "$index",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 1)),
                      itemCount: _aContext.words.length,
                    ))

            //Text("${_matched.every((e)=>e) ? '' : '틀렸다'}", style: TextStyle(fontSize: 40, color: Colors.redAccent))
            ),
        Wrap(
          children: hint ?? Text(""),
          alignment: WrapAlignment.center,
        )
      ])),
      backgroundColor: OptionData.main_BG_color,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_right, size: 50),
        onPressed: () {
          reFrame(context);
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

class _OptionState extends State<Option> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Option"),
        backgroundColor: OptionData.main_bar_color,
      ),
      body: ListView(
        children: [
          ListTile(
              title: Row(
            children: [
              Expanded(
                  child: Text(
                "추가적인 선택 변수(forced)",
                style: TextStyle(color: OptionData.main_text_color, fontWeight: FontWeight.bold),
              )),
              Expanded(
                  child: TextField(
                style: TextStyle(color: OptionData.main_text_color),
                onSubmitted: (value) {
                  OptionData.additional_parameter_forced = value.trim();
                },
                decoration: InputDecoration(hintText: OptionData.additional_parameter_forced ?? ""),
              ))
            ],
          )),
          ListTile(
              title: Row(
            children: [
              Expanded(
                  child: Text(
                "힌트 비율",
                style: TextStyle(color: OptionData.main_text_color, fontWeight: FontWeight.bold),
              )),
              Expanded(
                  child: TextField(
                style: TextStyle(color: OptionData.main_text_color),
                onSubmitted: (value) => OptionData.hint_rate = double.tryParse(value) ?? OptionData.hint_rate,
                decoration: InputDecoration(hintText: OptionData.hint_rate.toString() ?? ""),
              ))
            ],
          )),
          ListTile(),
          ListTile(),
          ListTile(
              title: Text(
            "made by yenru0604@gmail.com",
            textAlign: TextAlign.right,
            style: TextStyle(color: OptionData.main_text_color),
          )),
          ListTile(
            title: Text(
              "goto github",
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.blueAccent),
            ),
            onTap: () => launch("https://github.com/yenru0/divide_and_rule"),
          ),
          ListTile(
            title: Text("fine", textAlign: TextAlign.right),
          ),
        ],
      ),
      backgroundColor: OptionData.main_BG_color,
    );
  }
}
