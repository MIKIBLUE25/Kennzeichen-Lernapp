import 'package:flutter/material.dart';
import '../data/kennzeichen_data.dart';
import '../logic/quiz_logic.dart';
import '../logic/storage.dart';

class QuizInputStadt extends StatefulWidget {
  final String bundesland;

  const QuizInputStadt({
    super.key,
    required this.bundesland,
  });

  @override
  State<QuizInputStadt> createState() => _QuizInputStadtState();
}

class _QuizInputStadtState extends State<QuizInputStadt> {
  final TextEditingController controller = TextEditingController();

  String aktuellesKennzeichen = "";
  String aktuelleStadt = "";

  bool beantwortet = false;
  bool richtig = false;

  List<String> quizKeys = [];
  int aktuelleFrage = 0;

  @override
  void initState() {
    super.initState();
    _quizStarten();
  }

  void _quizStarten() {
    List<String> keys = [];

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

    keys.shuffle();

    quizKeys = keys.take(20).toList();

    if (quizKeys.isNotEmpty) {
      _frageLaden();
    }
  }

  void _frageLaden() {
    if (aktuelleFrage >= quizKeys.length) {
      return;
    }

    aktuellesKennzeichen = quizKeys[aktuelleFrage];

    var eintraege = kennzeichenDaten[aktuellesKennzeichen]!;

    aktuelleStadt =
        (eintraege[0]["stadt"] as String?) ?? "";

    controller.clear();

    beantwortet = false;
    richtig = false;

    setState(() {});
  }

  void _antwortPruefen() async {
    if (beantwortet) return;

    final eingabe = controller.text.trim();

    if (eingabe.isEmpty) return;

    bool passt = _pruefeKennzeichen(eingabe);

    setState(() {
      beantwortet = true;
      richtig = passt;
    });

    var eintraege = kennzeichenDaten[aktuellesKennzeichen]!;

    if (passt) {
      eintraege[0]["richtigCount"] =
          (eintraege[0]["richtigCount"] ?? 0) + 1;

      if (eintraege[0]["richtigCount"] >= 2) {
        eintraege[0]["gelernt"] = true;
      }
    } else {
      eintraege[0]["falschCount"] =
          (eintraege[0]["falschCount"] ?? 0) + 1;
    }

    await speichereFortschritt();
  }

  bool _pruefeKennzeichen(String eingabe) {
    String normalize(String text) {
      return text
          .toUpperCase()
          .replaceAll(" ", "")
          .replaceAll("-", "")
          .trim();
    }

    String eingabeNorm = normalize(eingabe);
    String loesungNorm = normalize(aktuellesKennzeichen);

    if (eingabeNorm == loesungNorm) {
      return true;
    }

    // Bis zu 2 Tippfehler erlauben
    int dist = levenshtein(
      eingabeNorm,
      loesungNorm,
    );

    return dist <= 2;
  }

  void _weiter() {
    if (!beantwortet) return;

    if (aktuelleFrage + 1 >= quizKeys.length) {
      Navigator.pop(context);
      return;
    }

    aktuelleFrage++;

    _frageLaden();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ort → Kürzel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              "${aktuelleFrage + 1} / ${quizKeys.length}",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 40),

            Text(
              aktuelleStadt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: controller,
              enabled: !beantwortet,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) {
                _antwortPruefen();
              },
              decoration: const InputDecoration(
                hintText: "Kennzeichen eingeben",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (beantwortet)
              Text(
                richtig
                    ? "Richtig!"
                    : "Falsch! Richtig wäre: $aktuellesKennzeichen",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: richtig ? Colors.green : Colors.red,
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    beantwortet ? _weiter : _antwortPruefen,
                child: Text(
                  beantwortet ? "Weiter" : "Prüfen",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}