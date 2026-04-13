import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/kennzeichen_data.dart';

Map<String, dynamic> berechneStatistik() {
  int gelernt = 0;     // 2x richtig
  int inArbeit = 0;    // 1x richtig
  int falsch = 0;
  int offen = 0;

  int gesamt = 0;

  for (var liste in kennzeichenDaten.values) {
    for (var eintrag in liste) {
      gesamt++;

      int richtig = eintrag["richtigCount"] ?? 0;
      int falschCount = eintrag["falschCount"] ?? 0;

      if (richtig >= 2) {
        gelernt++;
      } else if (richtig == 1) {
        inArbeit++;
      } else if (falschCount > 0) {
        falsch++;
      } else {
        offen++;
      }
    }
  }

  // 🔥 NEUE PROZENT LOGIK
  double fortschritt =
      gesamt == 0 ? 0 : ((gelernt * 1.0 + inArbeit * 0.5) / gesamt) * 100;

  return {
    "gelernt": gelernt,
    "inArbeit": inArbeit,
    "falsch": falsch,
    "offen": offen,
    "gesamt": gesamt,
    "fortschritt": fortschritt.round(),
  };
}