import 'package:flutter/material.dart';
import '../logic/quiz_session.dart';
import '../logic/quiz_logic.dart';

class QuizInput extends StatefulWidget {
  final String bundesland;

  const QuizInput({super.key, required this.bundesland});

  @override
  State<QuizInput> createState() => _QuizInputState();
}

class _QuizInputState extends State<QuizInput> {
  late QuizSession session;
  final TextEditingController controller = TextEditingController();

  String feedback = "";
  bool beantwortet = false;

  @override
  void initState() {
    super.initState();

    session = QuizSession(bundesland: widget.bundesland);
    session.start();
  }

  void checkAntwort() {
    if (beantwortet) return;

    String eingabe = controller.text;

    bool richtig = checkAntwortLogic(
      session.aktuellesKennzeichen,
      eingabe,
    );

    setState(() {
      beantwortet = true;
      feedback = richtig
          ? "✅ Richtig!"
          : "❌ Falsch! → ${session.richtigeAntwort}";
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
            // 🔥 Fortschritt
            Text(
              "${session.aktuelleFrageNummer} / ${session.gesamtFragen}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            // 🔥 Kennzeichen Design
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: const Text(
                      "D",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    session.aktuellesKennzeichen,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔥 Eingabe
            TextField(
              controller: controller,
              enabled: !beantwortet, // 🔥 sperrt nach prüfen
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Stadt eingeben",
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 Prüfen Button
            ElevatedButton(
              onPressed: checkAntwort,
              child: const Text("Prüfen"),
            ),

            const SizedBox(height: 30),

            // 🔥 Feedback
            Text(
              feedback,
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 10),

            // 🔥 Weiter Button
            if (beantwortet)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    beantwortet = false;
                    feedback = "";
                    controller.clear();

                    bool weiter = session.naechsteFrage();

                    if (!weiter) {
                      feedback = "🎉 Quiz beendet!";
                    }
                  });
                },
                child: const Text("Weiter"),
              ),
          ],
        ),
      ),
    );
  }
}