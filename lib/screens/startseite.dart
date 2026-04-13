import 'package:flutter/material.dart';
import '../data/kennzeichen_data.dart';

class StartSeite extends StatelessWidget {
  const StartSeite({super.key});

  @override
  Widget build(BuildContext context) {
    int gelernt = 0;
    int gesamt = 0;

    for (var liste in kennzeichenDaten.values) {
      for (var eintrag in liste) {
        gesamt++;
        if ((eintrag["richtigCount"] ?? 0) >= 2) {
          gelernt++;
        }
      }
    }

    int offen = gesamt - gelernt;
    int prozent = gesamt == 0 ? 0 : ((gelernt / gesamt) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kennzeichen Trainer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 10),

            // 🔥 DEUTSCHLAND CARD
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/bundeslaender");
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

                    // Prozent links
                    Text(
                      "$prozent%",
                      style: const TextStyle(fontSize: 18),
                    ),

                    const SizedBox(width: 20),

                    // Text rechts
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deutschland",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$gelernt von $gesamt gelernt • $offen offen",
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