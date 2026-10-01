
import 'package:flutter/material.dart';
import '../data/kennzeichen_data.dart';
import '../logic/storage.dart';
import '../logic/quiz_session.dart';
import 'quiz_ende.dart';

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

  late QuizSession session;

  String aktuellesKennzeichen = '';
  String aktuelleStadt = '';

  bool beantwortet = false;
  bool richtig = false;

  @override
  void initState() {
    super.initState();
    session = QuizSession(bundesland: widget.bundesland);
    session.start();
    _frageLaden();
  }

  void _frageLaden() {
    aktuellesKennzeichen = session.aktuellesKennzeichen;

    final eintraege = kennzeichenDaten[aktuellesKennzeichen]!;
    aktuelleStadt = (eintraege[0]['stadt'] as String?) ?? '';

    controller.clear();
    beantwortet = false;
    richtig = false;
  }

  Future<void> _antwortPruefen() async {
    if (beantwortet || controller.text.trim().isEmpty) return;

    // Leerzeichen und Bindestriche werden ignoriert.
    // Alle Buchstaben und Zahlen müssen exakt übereinstimmen.
    final eingabe = controller.text
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[\s-]+'), '');

    final loesung = aktuellesKennzeichen
        .toUpperCase()
        .replaceAll(RegExp(r'[\s-]+'), '');

    // Keine Fehlertoleranz: Das vollständige Kürzel muss stimmen.
    final passt = eingabe == loesung;

    final eintraege = kennzeichenDaten[aktuellesKennzeichen]!;

    if (passt) {
      eintraege[0]['richtigCount'] =
          (eintraege[0]['richtigCount'] ?? 0) + 1;

      if (eintraege[0]['richtigCount'] >= 2) {
        eintraege[0]['gelernt'] = true;
      }

      session.richtigBeantwortet++;
    } else {
      eintraege[0]['falschCount'] =
          (eintraege[0]['falschCount'] ?? 0) + 1;
    }

    await speichereFortschritt();

    if (!mounted) return;

    setState(() {
      beantwortet = true;
      richtig = passt;
    });
  }

  void _weiter() {
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

    setState(_frageLaden);
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
        title: const Text('Ort → Kürzel'),
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
              const SizedBox(height: 48),

              Text(
                aktuelleStadt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 48),

              TextField(
                controller: controller,
                enabled: !beantwortet,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _antwortPruefen(),
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'Kennzeichen eingeben',
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
                  onPressed: _antwortPruefen,
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
                  richtig
                      ? '✓ Richtig!'
                      : '✕ Falsch! Richtig wäre: $aktuellesKennzeichen',
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
                    onPressed: _weiter,
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
