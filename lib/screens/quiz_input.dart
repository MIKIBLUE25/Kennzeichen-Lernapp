
import 'package:flutter/material.dart';
import '../logic/quiz_session.dart';
import '../logic/quiz_logic.dart';
import 'quiz_ende.dart';

class QuizInput extends StatefulWidget {
  final String bundesland;

  const QuizInput({
    super.key,
    required this.bundesland,
  });

  @override
  State<QuizInput> createState() => _QuizInputState();
}

class _QuizInputState extends State<QuizInput> {
  late QuizSession session;
  final TextEditingController controller = TextEditingController();

  bool beantwortet = false;
  bool richtig = false;
  String feedback = '';

  @override
  void initState() {
    super.initState();
    session = QuizSession(bundesland: widget.bundesland);
    session.start();
  }

  Future<void> checkAntwort() async {
    if (beantwortet || controller.text.trim().isEmpty) return;

    final bool ergebnis = await checkAntwortLogic(
      session.aktuellesKennzeichen,
      controller.text.trim(),
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

    final bool hatWeitereFrage = session.naechsteFrage();

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
      controller.clear();
    });
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
        automaticallyImplyLeading: true,
        title: const Text(
          'Kürzel → Ort',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              Text(
                widget.bundesland,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                '${session.aktuelleFrageNummer} / ${session.gesamtFragen}',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 34),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      color: const Color(0xFF2498E8),
                      child: const Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      session.aktuellesKennzeichen,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 42),

              TextField(
                controller: controller,
                enabled: !beantwortet,
                textAlign: TextAlign.start,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => checkAntwort(),
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Stadt eingeben',
                  hintText: 'Name der Stadt',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              if (!beantwortet)
                ElevatedButton(
                  onPressed: checkAntwort,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(210, 64),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Prüfen',
                    style: TextStyle(fontSize: 21),
                  ),
                ),

              if (beantwortet) ...[
                const SizedBox(height: 8),
                Text(
                  richtig ? '✓ $feedback' : '✕ $feedback',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: richtig
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFEF5350),
                  ),
                ),
              ],

              const Spacer(),

              if (beantwortet)
                SizedBox(
                  width: double.infinity,
                  height: 64,
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
          ),
        ),
      ),
    );
  }
}
