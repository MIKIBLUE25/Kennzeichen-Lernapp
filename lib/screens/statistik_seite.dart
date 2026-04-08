import 'package:flutter/material.dart';
import '../logic/statistik.dart';

class StatistikSeite extends StatelessWidget {
  const StatistikSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = berechneStatistik();

    int zwei = stats["2x"]!;
    int eins = stats["1x"]!;
    int falsch = stats["falsch"]!;
    int offen = stats["offen"]!;

    int gesamt = zwei + eins + falsch + offen;

    double pruefungsreife = gesamt == 0 ? 0 : zwei / gesamt;

    return Scaffold(
      appBar: AppBar(title: const Text("Statistik")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔥 Prozent oben
            Text(
              "${(pruefungsreife * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text("Prüfungsreife"),

            const SizedBox(height: 30),

            // 🔥 Balken
            LinearProgressIndicator(
              value: pruefungsreife,
              minHeight: 10,
            ),

            const SizedBox(height: 40),

            // 🔥 Details
            _buildRow("2x richtig", zwei, Colors.green),
            _buildRow("1x richtig", eins, Colors.yellow),
            _buildRow("falsch", falsch, Colors.red),
            _buildRow("offen", offen, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String text, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          const SizedBox(width: 10),
          Text(text),
          const Spacer(),
          Text(value.toString()),
        ],
      ),
    );
  }
}
