import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/kennzeichen_data.dart';

Future<void> speichereFortschritt() async {
  final prefs = await SharedPreferences.getInstance();

  Map<String, dynamic> daten = {};

  kennzeichenDaten.forEach((key, liste) {
    daten[key] = liste.map((e) => {
          "richtigCount": e["richtigCount"] ?? 0,
          "falschCount": e["falschCount"] ?? 0,
          "gelernt": e["gelernt"] ?? false,
        }).toList();
  });

  await prefs.setString("fortschritt", jsonEncode(daten));
}

Future<void> ladeFortschritt() async {
  final prefs = await SharedPreferences.getInstance();

  String? jsonString = prefs.getString("fortschritt");
  if (jsonString == null) return;

  Map<String, dynamic> daten = jsonDecode(jsonString);

  daten.forEach((key, liste) {
    if (kennzeichenDaten.containsKey(key)) {
      for (int i = 0; i < liste.length; i++) {
        kennzeichenDaten[key]![i]["richtigCount"] =
            liste[i]["richtigCount"] ?? 0;
        kennzeichenDaten[key]![i]["falschCount"] =
            liste[i]["falschCount"] ?? 0;
        kennzeichenDaten[key]![i]["gelernt"] =
            liste[i]["gelernt"] ?? false;
      }
    }
  });
}
Future<void> resetFortschritt() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("fortschritt");
}

void resetDaten() {
  for (var liste in kennzeichenDaten.values) {
    for (var eintrag in liste) {
      eintrag["richtigCount"] = 0;
      eintrag["falschCount"] = 0;
      eintrag["gelernt"] = false;
    }
  }
}