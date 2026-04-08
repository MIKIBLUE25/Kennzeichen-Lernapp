import 'package:flutter/material.dart';
import 'dart:math';
import '../data/kennzeichen_data.dart';
import '../logic/quiz_session.dart';
import '../logic/quiz_logic.dart';

class QuizMultipleChoice extends StatefulWidget {
  final String bundesland;

  const QuizMultipleChoice({super.key, required this.bundesland});

  @override
  State<QuizMultipleChoice> createState() => _QuizMultipleChoiceState();
}

class _QuizMultipleChoiceState extends State<QuizMultipleChoice> {
String aktuellesKennzeichen = "";
List<String> antworten = [];
String richtigeAntwort = "";
late QuizSession session;
  String feedback = "";

  @override
@override
void initState() {
  super.initState();

  session = QuizSession(bundesland: widget.bundesland);
  session.start();
}

  void neueFrage() {
    final random = Random();

    List<String> keys = [];

    // 🔥 FILTER nach Bundesland
    for (var entry in kennzeichenDaten.entries) {
      for (var eintrag in entry.value) {
        if (widget.bundesland == "Deutschland" ||
            eintrag["bundesland"] == widget.bundesland ||
            (widget.bundesland == "Bundesweit" &&
                eintrag["bundesland"] == "Bundesweit")) {
          keys.add(entry.key);
          break;
        }
      }
    }

    // Sicherheit (falls leer)
    if (keys.isEmpty) return;

    aktuellesKennzeichen = keys[random.nextInt(keys.length)];

    var eintraege = kennzeichenDaten[aktuellesKennzeichen]!;

    richtigeAntwort = eintraege[0]["stadt"] ?? "";

    Set<String> antwortSet = {richtigeAntwort};

    List<String> alleStaedte = [];

for (var liste in kennzeichenDaten.values) {
  for (var eintrag in liste) {
    alleStaedte.add(eintrag["stadt"]);
  }
}

// gleiche Anfangsbuchstaben bevorzugen
List<String> aehnliche = alleStaedte.where((stadt) {
  return stadt[0].toLowerCase() ==
      richtigeAntwort[0].toLowerCase();
}).toList();

aehnliche.shuffle();

for (var stadt in aehnliche) {
  if (antwortSet.length >= 4) break;
  antwortSet.add(stadt);
}

// fallback falls nicht genug
while (antwortSet.length < 4) {
  String randomStadt =
      alleStaedte[random.nextInt(alleStaedte.length)];
  antwortSet.add(randomStadt);
}

    antworten = antwortSet.toList()..shuffle();

    feedback = "";
  }

void checkAntwort(String antwort) {
  bool richtig = checkAntwortLogic(
    session.aktuellesKennzeichen,
    antwort,
  );

  setState(() {
    feedback = richtig
        ? "✅ Richtig!"
        : "❌ Falsch! → ${session.richtigeAntwort}";
  });

  Future.delayed(const Duration(seconds: 1), () {
    setState(() {
      bool weiter = session.naechsteFrage();

      if (!weiter) {
        feedback = "🎉 Quiz beendet!";
      }
    });
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bundesland)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "${session.aktuelleFrageNummer} / ${session.gesamtFragen}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              session.aktuellesKennzeichen,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
  child: GridView.builder(
    itemCount: 4,
    gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
    ),
                itemBuilder: (context, index) {
                  final antwort = session.antworten[index];

                 return ElevatedButton(
  onPressed: () => checkAntwort(antwort),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(10),
  ),
                    child: Text(
                      antwort,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Text(
              feedback,
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}