
import 'package:flutter/material.dart';
import '../logic/quiz_session.dart';
import '../logic/quiz_logic.dart';
import 'quiz_ende.dart';

class QuizMultipleChoice extends StatefulWidget {
  final String bundesland;

  const QuizMultipleChoice({
    super.key,
    required this.bundesland,
  });

  @override
  State<QuizMultipleChoice> createState() =>
      _QuizMultipleChoiceState();
}

class _QuizMultipleChoiceState extends State<QuizMultipleChoice> {
  late QuizSession session;

  bool beantwortet = false;
  bool richtig = false;
  String feedback = '';

  @override
  void initState() {
    super.initState();
    session = QuizSession(bundesland: widget.bundesland);
    session.start();
  }

  Future<void> checkAntwort(String antwort) async {
    if (beantwortet) return;

    final ergebnis = await checkAntwortLogic(
      session.aktuellesKennzeichen,
      antwort,
    );

    if (!mounted) return;

    setState(() {
      beantwortet = true;
      richtig = ergebnis;
      feedback = ergebnis
          ? 'Richtig!'
          : 'Falsch! Richtig wäre: ${session.richtigeAntwort}';

      if (ergebnis) {
        session.richtigBeantwortet++;
      }
    });
  }

  void weiter() {
    if (!beantwortet) return;

    final hatWeitereFrage = session.naechsteFrage();

    if (!hatWeitereFrage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizEndeSeite(
            richtig: session.richtigBeantwortet,
            gesamt: session.gesamtFragen,
            bundesland: widget.bundesland,
          ),
        ),
      );
      return;
    }

    setState(() {
      beantwortet = false;
      richtig = false;
      feedback = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Choice'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Text(
                widget.bundesland,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                '${session.aktuelleFrageNummer} / ${session.gesamtFragen}',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      color: const Color(0xFF2498E8),
                      child: const Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      session.aktuellesKennzeichen,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                          border: Border.all(
                            color: beantwortet && antwort == session.richtigeAntwort
                                ? const Color(0xFF4CAF50)
                                : Colors.transparent,
                            width: 2,
                          ),
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

              if (beantwortet) ...[
                const SizedBox(height: 12),
                Text(
                  richtig ? '✓ $feedback' : '✕ $feedback',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: richtig
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: weiter,
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Weiter',
                      style: TextStyle(fontSize: 21),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
