import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/kennzeichen_data.dart';

Map<String, dynamic> berechneStatistik() {
  int zweiRichtig = 0;
  int einmalRichtig = 0;
  int falsch = 0;
  int offen = 0;

  int gesamt = 0;

  for (var liste in kennzeichenDaten.values) {
    for (var eintrag in liste) {
      gesamt++;

      int richtig = eintrag["richtigCount"] ?? 0;
      int falschCount = eintrag["falschCount"] ?? 0;

      if (richtig >= 2) {
        zweiRichtig++;
      } else if (richtig == 1) {
        einmalRichtig++;
      } else if (falschCount > 0) {
        falsch++;
      } else {
        offen++;
      }
    }
  }

  double fortschritt =
      gesamt == 0 ? 0 : (zweiRichtig / gesamt) * 100;

  return {
    "2x": zweiRichtig,
    "1x": einmalRichtig,
    "falsch": falsch,
    "offen": offen,
    "gesamt": gesamt,
    "fortschritt": fortschritt.round(),
  };
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