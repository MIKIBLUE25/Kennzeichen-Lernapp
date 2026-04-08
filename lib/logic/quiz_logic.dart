import '../data/kennzeichen_data.dart';

// 🔥 Levenshtein (für Tippfehler)
int levenshtein(String s, String t) {
  List<List<int>> d = List.generate(
    s.length + 1,
    (_) => List.filled(t.length + 1, 0),
  );

  for (int i = 0; i <= s.length; i++) {
  d[i][0] = i;
}
  for (int j = 0; j <= t.length; j++) {
  d[0][j] = j;
}

  for (int i = 1; i <= s.length; i++) {
    for (int j = 1; j <= t.length; j++) {
      int cost = s[i - 1] == t[j - 1] ? 0 : 1;

      d[i][j] = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  return d[s.length][t.length];
}

bool checkAntwortLogic(String kennzeichen, String eingabe) {
  var eintraege = kennzeichenDaten[kennzeichen]!;

  String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll("ä", "ae")
        .replaceAll("ö", "oe")
        .replaceAll("ü", "ue")
        .replaceAll("ß", "ss")
        .replaceAll(RegExp(r"\(.*?\)"), "") // entfernt (veraltet)
        .trim();
  }

  String eingabeNorm = normalize(eingabe);

  for (var eintrag in eintraege) {
    String richtigeStadt = eintrag["stadt"];

    String loesungNorm = normalize(richtigeStadt);

    // 🔥 split bei / und leerzeichen
    List<String> teile =
        loesungNorm.split(RegExp(r"[\/\s-]+"));

    bool passt = false;

    // ✅ exakte Lösung
    if (eingabeNorm == loesungNorm) {
      passt = true;
    }

    // 🔥 Teil + Tippfehler
    for (var teil in teile) {
      if (teil.isEmpty) continue;

      // exakter Teil
      if (eingabeNorm == teil) {
        passt = true;
      }

      // 🔥 max 2 Tippfehler erlaubt
      int dist = levenshtein(eingabeNorm, teil);

      if (dist <= 2) {
        passt = true;
      }
    }

    if (passt) {
      eintrag["richtigCount"] =
          (eintrag["richtigCount"] ?? 0) + 1;

      if (eintrag["richtigCount"] >= 2) {
        eintrag["gelernt"] = true;
      }

      return true;
    }
  }

  // ❌ falsch
  for (var eintrag in eintraege) {
    eintrag["falschCount"] =
        (eintrag["falschCount"] ?? 0) + 1;
  }

  return false;
}