import 'package:flutter/material.dart';
import 'quiz_input.dart';

class QuizEndeSeite extends StatelessWidget {
  final int richtig;
  final int gesamt;
  final String bundesland;

  const QuizEndeSeite({
    super.key,
    required this.richtig,
    required this.gesamt,
    required this.bundesland,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ergebnis")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Quiz beendet!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              "$richtig / $gesamt richtig",
              style: const TextStyle(fontSize: 40),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hauptmenü"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuizInput(bundesland: bundesland),
                  ),
                );
              },
              child: const Text("Neues Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}