import 'dart:math';
import '../data/kennzeichen_data.dart';

class QuizSession {
  final String bundesland;
  final int anzahlFragen;

  List<String> _quizKeys = [];
  int _currentIndex = 0;
  int richtigBeantwortet = 0;

  String aktuellesKennzeichen = "";
  String richtigeAntwort = "";
  List<String> antworten = [];

  QuizSession({
    required this.bundesland,
    this.anzahlFragen = 20,
  });

  void start() {
    final random = Random();

    List<String> ungelernt = [];
    List<String> inArbeit = [];
    List<String> gelernt = [];

    // Kennzeichen nach Lernstand sortieren
    for (var entry in kennzeichenDaten.entries) {
      for (var eintrag in entry.value) {
        if (bundesland == "Deutschland" ||
            eintrag["bundesland"] == bundesland ||
            (bundesland == "Bundesweit" &&
                eintrag["bundesland"] == "Bundesweit")) {
          
          int richtig = eintrag["richtigCount"] ?? 0;

          if (richtig == 0) {
            // Noch nie richtig beantwortet
            ungelernt.add(entry.key);
          } else if (richtig == 1) {
            // Einmal richtig beantwortet
            inArbeit.add(entry.key);
          } else {
            // Mindestens zweimal richtig
            gelernt.add(entry.key);
          }

          break;
        }
      }
    }

    // Jede Gruppe zufällig mischen.
    // Dadurch wird innerhalb der Priorität weiterhin
    // für Abwechslung gesorgt.
    ungelernt.shuffle(random);
    inArbeit.shuffle(random);
    gelernt.shuffle(random);

    List<String> auswahl = [];

    // 1. Zuerst noch komplett ungelernte Kennzeichen
    auswahl.addAll(ungelernt);

    // 2. Danach Kennzeichen, die einmal richtig waren
    auswahl.addAll(inArbeit);

    // 3. Falls noch Plätze frei sind:
    // Bereits gelernte Kennzeichen als Wiederholung verwenden
    auswahl.addAll(gelernt);

    // Auf die gewünschte Anzahl Fragen begrenzen
    _quizKeys = auswahl.take(anzahlFragen).toList();

    _currentIndex = 0;
    richtigBeantwortet = 0;

    _ladeFrage();
  }

  void _ladeFrage() {
    if (_currentIndex >= _quizKeys.length) return;

    aktuellesKennzeichen = _quizKeys[_currentIndex];

    var eintraege = kennzeichenDaten[aktuellesKennzeichen]!;

    richtigeAntwort =
        (eintraege[0]["stadt"] as String?) ?? "";

    _generiereAntworten();
  }

  void _generiereAntworten() {
    final random = Random();

    Set<String> antwortSet = {richtigeAntwort};

    List<String> alleStaedte = [];

    for (var liste in kennzeichenDaten.values) {
      for (var eintrag in liste) {
        alleStaedte.add(
          (eintrag["stadt"] as String?) ?? "",
        );
      }
    }

    // Ähnliche Städte bevorzugen
    // (gleicher Anfangsbuchstabe)
    List<String> aehnliche = alleStaedte.where((stadt) {
      if (stadt.isEmpty || richtigeAntwort.isEmpty) {
        return false;
      }

      return stadt[0].toLowerCase() ==
          richtigeAntwort[0].toLowerCase();
    }).toList();

    aehnliche.shuffle(random);

    for (var stadt in aehnliche) {
      if (antwortSet.length >= 4) break;

      antwortSet.add(stadt);
    }

    // Falls nicht genügend ähnliche Städte vorhanden sind
    while (antwortSet.length < 4) {
      String randomStadt =
          alleStaedte[random.nextInt(alleStaedte.length)];

      antwortSet.add(randomStadt);
    }

    antworten = antwortSet.toList()..shuffle();
  }

  bool checkAntwort(String antwort) {
    bool richtig = antwort == richtigeAntwort;

    if (richtig) {
      richtigBeantwortet++;
    }

    return richtig;
  }

  bool naechsteFrage() {
    if (_currentIndex + 1 >= _quizKeys.length) {
      return false;
    }

    _currentIndex++;
    _ladeFrage();

    return true;
  }

  int get aktuelleFrageNummer => _currentIndex + 1;

  int get gesamtFragen => _quizKeys.length;
}