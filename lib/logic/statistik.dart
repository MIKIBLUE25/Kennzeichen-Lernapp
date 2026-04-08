import '../data/kennzeichen_data.dart';

Map<String, int> berechneStatistik() {
  int zweiRichtig = 0;
  int einmalRichtig = 0;
  int falsch = 0;
  int offen = 0;

  for (var liste in kennzeichenDaten.values) {
    for (var eintrag in liste) {
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

  return {
    "2x": zweiRichtig,
    "1x": einmalRichtig,
    "falsch": falsch,
    "offen": offen,
  };
}