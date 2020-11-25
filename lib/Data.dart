import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuestionManager {
  dynamic data;
  List<String> names;
  Map<String, ContextManager> manager = Map();

  String chosen;

  // ignore: non_constant_identifier_names
  QuestionManager(dynamic data, {String forced}) {
    this.data = data;
    this.names = data.keys.toList();

    for (var name in this.names) {
      manager[name] = ContextManager.fromJson(this.data[name]);
    }
    if (forced != null && names.contains(forced)) {
      chosen = forced;
    } else {
      chosen = names[Random().nextInt(names.length)];
    }
  }

  Context next() {
    // null or valid
    return manager[chosen].next();
  }

  Context now() {
    return manager[chosen].now();
  }
}

class ContextManager {
  final List<Context> contexts;

  int index = 0;

  ContextManager(this.contexts);

  ContextManager.fromJson(Map<String, dynamic> json)
      : contexts = json["contexts"].map<Context>((v) {
          return Context.fromJson(v);
        }).toList();

  Context next() {
    if (index >= contexts.length) {
      return null;
    }
    var temp = contexts[index];
    index++;
    return temp;
  }

  Context now() {
    return contexts[index];
  }
}

class Context {
  final String translation;
  final List<String> words;
  final String result;

  Context(this.translation, this.words, this.result);

  Context.fromJson(Map<String, dynamic> json)
      : translation = json["translation"],
        words = json["words"].toString().trim().replaceAll('.', '').replaceAll(',', '').replaceAll('\'', '').replaceAll('\"', '').toLowerCase().split(" "),
        result = json["result"];
}

List<bool> judgeContext(String result, Context context) {
  var temp = result.replaceAll('.', '').replaceAll(',', '').replaceAll('\'', '').replaceAll('\"', '').trim().toLowerCase().split(' ');
  var accuracyList = List.generate(context.words.length, (index) => false);
  for (int i = 0; i < context.words.length; i++) {
    if (i >= temp.length) {
      break;
    } else {
      if (temp[i] == context.words[i]) {
        accuracyList[i] = true;
      }
    }
  }
  return accuracyList;
}

class OptionData {
  OptionData.init() {}

  static Color main_BG_color = Color.fromRGBO(120, 120, 120, 120);
  static Color main_bar_color = Color.fromRGBO(30, 30, 30, 180);

  static Color main_text_color = Colors.white;
  static Color main_btn_color = Colors.deepPurpleAccent;

  static String additional_parameter_forced = "";

  static double hint_rate = 1.0;
}
