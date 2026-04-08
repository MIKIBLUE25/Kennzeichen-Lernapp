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

  @override
  void initState() {
    super.initState();

    session = QuizSession(bundesland: widget.bundesland);
    session.start();
  }

  void checkAntwort() {
    String eingabe = controller.text;

    bool richtig = checkAntwortLogic(
      session.aktuellesKennzeichen,
      eingabe,
    );

    setState(() {
      feedback = richtig
          ? "✅ Richtig!"
          : "❌ Falsch! → ${session.richtigeAntwort}";
    });

    controller.clear();

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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Stadt eingeben",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: checkAntwort,
              child: const Text("Prüfen"),
            ),

            const SizedBox(height: 30),

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