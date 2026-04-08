import 'dart:math';
import '../data/kennzeichen_data.dart';

class QuizSession {
  final String bundesland;
  final int anzahlFragen;

  List<String> _quizKeys = [];
  int _currentIndex = 0;

  String aktuellesKennzeichen = "";
  String richtigeAntwort = "";
  List<String> antworten = [];

  QuizSession({
    required this.bundesland,
    this.anzahlFragen = 20,
  });

  void start() {
    final random = Random();

    List<String> keys = [];

    // 🔥 Filter nach Bundesland
    for (var entry in kennzeichenDaten.entries) {
      for (var eintrag in entry.value) {
        if (bundesland == "Deutschland" ||
            eintrag["bundesland"] == bundesland ||
            (bundesland == "Bundesweit" &&
                eintrag["bundesland"] == "Bundesweit")) {
          keys.add(entry.key);
          break;
        }
      }
    }

    keys.shuffle();

    _quizKeys = keys.take(anzahlFragen).toList();
    _currentIndex = 0;

    _ladeFrage();
  }

  void _ladeFrage() {
    if (_currentIndex >= _quizKeys.length) return;

    aktuellesKennzeichen = _quizKeys[_currentIndex];

    var eintraege = kennzeichenDaten[aktuellesKennzeichen]!;

    richtigeAntwort = (eintraege[0]["stadt"] as String?) ?? "";

    _generiereAntworten();
  }

  void _generiereAntworten() {
    final random = Random();

    Set<String> antwortSet = {richtigeAntwort};

    List<String> alleStaedte = [];

    for (var liste in kennzeichenDaten.values) {
      for (var eintrag in liste) {
        alleStaedte.add((eintrag["stadt"] as String?) ?? "");
      }
    }

    // aehnliche (gleicher Anfangsbuchstabe)
    List<String> aehnliche = alleStaedte.where((stadt) {
      if (stadt.isEmpty || richtigeAntwort.isEmpty) return false;
      return stadt[0].toLowerCase() ==
          richtigeAntwort[0].toLowerCase();
    }).toList();

    aehnliche.shuffle();

    for (var stadt in aehnliche) {
      if (antwortSet.length >= 4) break;
      antwortSet.add(stadt);
    }

    // fallback
    while (antwortSet.length < 4) {
      String randomStadt =
          alleStaedte[random.nextInt(alleStaedte.length)];
      antwortSet.add(randomStadt);
    }

    antworten = antwortSet.toList()..shuffle();
  }

  bool checkAntwort(String antwort) {
    return antwort == richtigeAntwort;
  }

  bool naechsteFrage() {
    _currentIndex++;

    if (_currentIndex >= _quizKeys.length) {
      return false; // fertig
    }

    _ladeFrage();
    return true;
  }

  int get aktuelleFrageNummer => _currentIndex + 1;
  int get gesamtFragen => _quizKeys.length;
}