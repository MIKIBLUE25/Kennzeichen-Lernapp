import '../data/kennzeichen_data.dart';

// Levenshtein-Distanz für Tippfehler
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

  // Vereinheitlicht Schreibweisen.
  String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll("ä", "ae")
        .replaceAll("ö", "oe")
        .replaceAll("ü", "ue")
        .replaceAll("ß", "ss")
        .replaceAll("-", " ")
        .replaceAll("/", " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .replaceAll(RegExp(r"\(.*?\)"), "")
        .trim();
  }

  String eingabeNorm = normalize(eingabe);

  for (var eintrag in eintraege) {
    String richtigeStadt = eintrag["stadt"].toString();
    String loesungNorm = normalize(richtigeStadt);

    bool passt = false;

    // ---------------------------------------------------------
    // 1. Normale exakte Eingabe
    // ---------------------------------------------------------

    if (eingabeNorm == loesungNorm) {
      passt = true;
    }

    // ---------------------------------------------------------
    // 2. "Polizei + Ort"
    //
    // Beispiele:
    // Polizei Schleswig Holstein
    // Polizei München
    // Polizei Nordrhein Westfalen
    //
    // Dadurch werden Verwaltungs-/Polizei-Bezeichnungen
    // flexibler akzeptiert.
    // ---------------------------------------------------------

    if (!passt && eingabeNorm.startsWith("polizei ")) {
      String ortEingabe =
          eingabeNorm.substring("polizei ".length).trim();

      if (ortEingabe.isNotEmpty) {
        // "polizei", "landesregierung" und ähnliche
        // Bestandteile aus der offiziellen Lösung entfernen.
        String loesungOhneVerwaltung = loesungNorm
            .replaceAll("polizei", "")
            .replaceAll("landesregierung", "")
            .replaceAll(RegExp(r"\s+"), " ")
            .trim();

        // Beispiel:
        // Eingabe:
        // "polizei schleswig holstein"
        //
        // Lösung:
        // "polizei landesregierung schleswig holstein"
        //
        // Beide werden zu:
        // "schleswig holstein"

        if (ortEingabe == loesungOhneVerwaltung) {
          passt = true;
        }

        // Falls die Lösung einfach nur "München" ist:
        //
        // Eingabe:
        // "polizei münchen"
        //
        // wird ebenfalls akzeptiert.
        if (ortEingabe == loesungNorm) {
          passt = true;
        }

        // Tippfehler bei "Polizei + Ort"
        if (!passt) {
          int dist =
              levenshtein(ortEingabe, loesungOhneVerwaltung);

          if (dist <= 2 && ortEingabe.length >= 4) {
            passt = true;
          }
        }
      }
    }

    // ---------------------------------------------------------
    // 3. Einzelne Bestandteile der normalen Lösung
    //
    // Beispiel:
    // Oldenburg-Holstein
    // -> Oldenburg wird akzeptiert
    //
    // Bei mehrteiligen Namen wird nicht einfach jeder
    // beliebige Teil akzeptiert.
    // ---------------------------------------------------------

    if (!passt) {
      List<String> teile =
          loesungNorm.split(RegExp(r"[\/\s-]+"));

      // Nur bei einem einzelnen Wort darf dieses
      // direkt als Alternative gelten.
      if (teile.length == 1) {
        if (eingabeNorm == teile[0]) {
          passt = true;
        }

        int dist = levenshtein(eingabeNorm, teile[0]);

        if (dist <= 2 && eingabeNorm.length >= 4) {
          passt = true;
        }
      }

      // Bei zusammengesetzten Namen erlauben wir
      // bekannte vollständige Bestandteile wie
      // "Oldenburg" aus "Oldenburg Holstein",
      // aber nicht einfach jeden beliebigen Teil.
      if (teile.length > 1) {
        for (var teil in teile) {
          if (teil.isEmpty) continue;

          // Sehr kurze Wörter nicht alleine akzeptieren.
          if (teil.length < 5) continue;

          if (eingabeNorm == teil) {
            // Nur bei langen, eindeutigen Bestandteilen.
            passt = true;
          }

          int dist = levenshtein(eingabeNorm, teil);

          if (dist <= 2 && eingabeNorm.length >= 5) {
            passt = true;
          }
        }
      }
    }

    // ---------------------------------------------------------
    // Treffer gefunden
    // ---------------------------------------------------------

    if (passt) {
      eintrag["richtigCount"] =
          (eintrag["richtigCount"] ?? 0) + 1;

      if (eintrag["richtigCount"] >= 2) {
        eintrag["gelernt"] = true;
      }

      return true;
    }
  }

  // ---------------------------------------------------------
  // Falsch beantwortet
  // ---------------------------------------------------------

  for (var eintrag in eintraege) {
    eintrag["falschCount"] =
        (eintrag["falschCount"] ?? 0) + 1;
  }

  return false;
}