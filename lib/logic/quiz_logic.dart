import '../data/kennzeichen_data.dart';

bool checkAntwortLogic(String kennzeichen, String eingabe) {
  var eintraege = kennzeichenDaten[kennzeichen]!;

  String normalize(String text) {
return text
    .toLowerCase()
    .replaceAll("ä", "ae")
    .replaceAll("ö", "oe")
    .replaceAll("ü", "ue")
    .replaceAll("ß", "ss")
    .replaceAll(RegExp(r"\(.*?\)"), "") // 🔥 entfernt (veraltet)
    .trim();
  }

  for (var eintrag in eintraege) {
    String richtigeStadt = eintrag["stadt"];

    if (normalize(eingabe) == normalize(richtigeStadt)) {

      eintrag["richtigCount"] = (eintrag["richtigCount"] ?? 0) + 1;

      if (eintrag["richtigCount"] >= 2) {
        eintrag["gelernt"] = true;
      }

      return true;
    }
  }

  for (var eintrag in eintraege) {
    eintrag["falschCount"] = (eintrag["falschCount"] ?? 0) + 1;
  }

  return false;
}