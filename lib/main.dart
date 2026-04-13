import 'package:flutter/material.dart';

// 👉 eigene Dateien
import 'screens/statistik_seite.dart';
import 'screens/suche_seite.dart';
import 'data/kennzeichen_data.dart';
import 'screens/quiz_multiple_choice.dart';
import 'screens/quiz_input.dart';
import 'logic/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ladeFortschritt();

  runApp(const MeineApp());
}

class MeineApp extends StatelessWidget {
  const MeineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kennzeichen Trainer',
      theme: ThemeData.dark(),
      home: const MainNavigation(), // 🔥 NEU
    );
  }
}

//
// 🔥 MAIN NAVIGATION (NEU)
//
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 2; // 🔥 Start = Mitte

  final pages = [
    const StatistikSeite(),
    const ComingSoonSeite(), // ✅
    const StartSeite(),
    const SucheSeite(),
    const ComingSoonSeite(), // ✅
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: "Extra",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Start",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Suche",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    );
  }
}

//
// 🔹 STARTSEITE (CARD)
//
class StartSeite extends StatelessWidget {
  const StartSeite({super.key});

  @override
  Widget build(BuildContext context) {
    int gelernt = 0;
    int gesamt = 0;
    int inArbeit = 0;
    


 for (var liste in kennzeichenDaten.values) {
  for (var eintrag in liste) {
    gesamt++;

    int richtig = eintrag["richtigCount"] ?? 0;

    if (richtig >= 2) {
      gelernt++;
    } else if (richtig == 1) {
      inArbeit++;
    }
  }
}

// 🔥 JETZT erst außerhalb der Schleifen
int offen = gesamt - gelernt - inArbeit;

int prozent =
    gesamt == 0 ? 0 : ((gelernt / gesamt) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text("Kennzeichen Trainer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BundeslandSeite()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            value: gesamt == 0 ? 0 : gelernt / gesamt,
                            strokeWidth: 5,
                          ),
                        ),
                        Text("$prozent%"),
                      ],
                    ),

                    const SizedBox(width: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deutschland",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$gelernt gelernt • $inArbeit in Arbeit • $offen offen",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

//
// 🔹 BUNDESLÄNDER
//
class BundeslandSeite extends StatefulWidget {
  const BundeslandSeite({super.key});

  @override
  State<BundeslandSeite> createState() => _BundeslandSeiteState();
}

class _BundeslandSeiteState extends State<BundeslandSeite> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // 🔥 erzwingt refresh
  }

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
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailSeite(name: name),
                ),
              );

              // 🔥 NACH QUIZ → UI REFRESH
              setState(() {});
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
// 🔹 DETAIL
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
class ComingSoonSeite extends StatelessWidget {
  const ComingSoonSeite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              "Coming Soon",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}