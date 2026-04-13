import 'package:flutter/material.dart';
import '../logic/statistik.dart';

class StatistikSeite extends StatelessWidget {
  const StatistikSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = berechneStatistik();

    int zwei = stats["2x"];
    int eins = stats["1x"];
    int falsch = stats["falsch"];
    int offen = stats["offen"];
    int gesamt = stats["gesamt"];
    int prozent = stats["fortschritt"];

    return Scaffold(
      appBar: AppBar(title: const Text("Statistik")),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // 🔥 PRÜFUNGSREIFE
            const SizedBox(height: 20),

            const Text(
              "Vorbereitet in %",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "$prozent %",
              style: const TextStyle(fontSize: 32),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: prozent / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            // 🔥 TRAININGS LEVEL
            const SizedBox(height: 20),

            const Text(
              "Trainings-Level",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "$gesamt | $gesamt Fragen",
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 15),

            // 🔥 FARBBALKEN (Stacked)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildBar(zwei, gesamt, Colors.green[900]!),
                  _buildBar(eins, gesamt, Colors.greenAccent),
                  _buildBar(falsch, gesamt, Colors.red),
                  _buildBar(offen, gesamt, Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 LEGENDEN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _legend(Colors.green[900]!, zwei, "2x richtig"),
                  _legend(Colors.greenAccent, eins, "1x richtig"),
                  _legend(Colors.red, falsch, "falsch"),
                  _legend(Colors.white, offen, "unbeantwortet"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔥 TRAININGSDAUER (OPTIONAL – erstmal statisch)
            const Text(
              "Trainingsdauer",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _timeBox("0 min", "Heute"),
                  const SizedBox(width: 10),
                  _timeBox("0 min", "Diese Woche"),
                  const SizedBox(width: 10),
                  _timeBox("0 min", "Gesamt"),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🔥 Balken Stück
  Widget _buildBar(int value, int total, Color color) {
    double width = total == 0 ? 0 : value / total;

    return Expanded(
      flex: (width * 1000).toInt(),
      child: Container(
        height: 20,
        color: color,
      ),
    );
  }

  // 🔥 Legende
  Widget _legend(Color color, int value, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 8),
        Text("$value"),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  // 🔥 Zeit Box
  Widget _timeBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}