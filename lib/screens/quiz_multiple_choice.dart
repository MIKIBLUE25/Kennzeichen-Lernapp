import 'package:flutter/material.dart';
import '../logic/quiz_session.dart';
import '../logic/quiz_logic.dart';

class QuizMultipleChoice extends StatefulWidget {
  final String bundesland;

  const QuizMultipleChoice({super.key, required this.bundesland});

  @override
  State<QuizMultipleChoice> createState() => _QuizMultipleChoiceState();
}

class _QuizMultipleChoiceState extends State<QuizMultipleChoice> {
  late QuizSession session;

  String feedback = "";
  bool beantwortet = false;

  @override
  void initState() {
    super.initState();

    session = QuizSession(bundesland: widget.bundesland);
    session.start();
  }

  void checkAntwort(String antwort) async {
    if (beantwortet) return;

    bool richtig = await checkAntwortLogic(
      session.aktuellesKennzeichen,
      antwort,
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
        padding: const EdgeInsets.all(10),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: const Text(
                      "D",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    session.aktuellesKennzeichen,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 Antworten
            Expanded(
              child: GridView.builder(
                itemCount: session.antworten.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final antwort = session.antworten[index];

                  return GestureDetector(
                    onTap: beantwortet
                        ? null
                        : () => checkAntwort(antwort),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            antwort,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

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