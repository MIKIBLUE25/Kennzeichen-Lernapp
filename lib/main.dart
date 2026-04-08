import 'package:flutter/material.dart';

// 👉 eigene Dateien
import 'screens/statistik_seite.dart';
import 'data/kennzeichen_data.dart';
import 'screens/quiz_multiple_choice.dart';
import 'screens/quiz_input.dart';


void main() {
  runApp(const MeineApp());
}

class MeineApp extends StatelessWidget {
  const MeineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kennzeichen Trainer',
      theme: ThemeData.dark(),
      home: const StartSeite(),
    );
  }
}

//
// 🔹 STARTSEITE
//
class StartSeite extends StatelessWidget {
  const StartSeite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kennzeichen Trainer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BundeslandSeite()),
                );
              },
              child: const Text("Deutschland"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StatistikSeite()),
                );
              },
              child: const Text("Statistik"),
            ),
          ],
        ),
      ),
    );
  }
}

//
// 🔹 BUNDESLÄNDER LISTE
//
class BundeslandSeite extends StatelessWidget {
  const BundeslandSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final bundeslaender = [
      "Deutschland",
      "Bundesweit",
      "Baden-Württemberg",
      "Bayern",
      "Berlin",
      "Brandenburg",
      "Bremen",
      "Hamburg",
      "Hessen",
      "Mecklenburg-Vorpommern",
      "Niedersachsen",
      "Nordrhein-Westfalen",
      "Rheinland-Pfalz",
      "Saarland",
      "Sachsen",
      "Sachsen-Anhalt",
      "Schleswig-Holstein",
      "Thüringen",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Bundesländer")),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: bundeslaender.length,
        itemBuilder: (context, index) {
          final name = bundeslaender[index];

          int gesamt = 0;
          int gelernt = 0;

          for (var liste in kennzeichenDaten.values) {
            for (var eintrag in liste) {
              if (name == "Deutschland" ||
                  eintrag["bundesland"] == name ||
                  (name == "Bundesweit" &&
                      eintrag["bundesland"] == "Bundesweit")) {
                gesamt++;

                if (eintrag["gelernt"] == true) {
                  gelernt++;
                }
              }
            }
          }

          int offen = gesamt - gelernt;
          double progress = gesamt == 0 ? 0 : gelernt / gesamt;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailSeite(name: name),
                ),
              );
            },
            child: Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                          ),
                        ),
                        Text("${(progress * 100).toInt()}%"),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$gelernt von $gesamt gelernt • $offen offen",
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//
// 🔹 DETAIL SEITE (Platzhalter)
//
class DetailSeite extends StatelessWidget {
  final String name;

  const DetailSeite({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizMultipleChoice(bundesland: name),
                  ),
                );
              },
              child: const Text("Multiple Choice"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizInput(bundesland: name),
                  ),
                );
              },
              child: const Text("Eingabe-Modus"),
            ),
          ],
        ),
      ),
    );
  }
}