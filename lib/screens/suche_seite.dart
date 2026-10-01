import 'package:flutter/material.dart';
import '../data/kennzeichen_data.dart';

class SucheSeite extends StatefulWidget {
  const SucheSeite({super.key});

  @override
  State<SucheSeite> createState() => _SucheSeiteState();
}

class _SucheSeiteState extends State<SucheSeite> {
  final TextEditingController controller = TextEditingController();

  String query = "";
  bool unscharf = false;

  List<Map<String, dynamic>> results = [];

  void sucheStarten() {
    final eingabe = controller.text.trim().toUpperCase();

    if (eingabe.isEmpty) {
      setState(() {
        query = "";
        results = [];
      });
      return;
    }

    List<Map<String, dynamic>> temp = [];

    kennzeichenDaten.forEach((kuerzel, liste) {
      final kuerzelGross = kuerzel.toUpperCase();

      for (var eintrag in liste) {
        bool match;

        if (unscharf) {
          // Nicht-sicher-Modus:
          // Nur Kennzeichen, die MIT der Eingabe beginnen.
          //
          // Beispiel:
          // F  -> F, FA, FB, FD, FE, FF, FL, ...
          // FR -> FR, FRA, FRG, FRI, ...
          //
          // IF, KF, AF usw. werden NICHT angezeigt.
          match = kuerzelGross.startsWith(eingabe);
        } else {
          // Exakt-Modus:
          // Nur das genau eingegebene Kennzeichen.
          match = kuerzelGross == eingabe;
        }

        if (match) {
          temp.add({
            "kuerzel": kuerzel,
            "stadt": eintrag["stadt"],
            "gelernt": eintrag["gelernt"] ?? false,
          });
        }
      }
    });

    if (unscharf) {
      // Treffer sortieren:
      //
      // 1. Exakte Übereinstimmung zuerst
      // 2. Danach kürzere Kennzeichen
      // 3. Bei gleicher Länge alphabetisch

      temp.sort((a, b) {
        final aKuerzel = a["kuerzel"].toString().toUpperCase();
        final bKuerzel = b["kuerzel"].toString().toUpperCase();

        // Exakte Übereinstimmung zuerst
        if (aKuerzel == eingabe && bKuerzel != eingabe) {
          return -1;
        }

        if (bKuerzel == eingabe && aKuerzel != eingabe) {
          return 1;
        }

        // Kürzere Kennzeichen zuerst
        final laengeVergleich =
            aKuerzel.length.compareTo(bKuerzel.length);

        if (laengeVergleich != 0) {
          return laengeVergleich;
        }

        // Bei gleicher Länge alphabetisch sortieren
        return aKuerzel.compareTo(bKuerzel);
      });
    }

    setState(() {
      query = eingabe;
      results = temp;
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
        title: const Text("Suche"),
      ),

      body: Column(
        children: [
          // Suchfeld
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,

              // Suche erst nach ENTER
              onSubmitted: (_) {
                sucheStarten();
              },

              decoration: InputDecoration(
                hintText: "Kennzeichen eingeben...",
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: sucheStarten,
                ),
              ),
            ),
          ),

          // Suchmodus
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Exakt"),

              Switch(
                value: unscharf,
                onChanged: (value) {
                  setState(() {
                    unscharf = value;
                    results = [];
                  });
                },
              ),

              const Text("Nicht sicher"),
            ],
          ),

          const SizedBox(height: 10),

          // Ergebnisse
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      query.isEmpty
                          ? "Kennzeichen suchen"
                          : "Keine Ergebnisse gefunden",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,

                    itemBuilder: (context, index) {
                      final item = results[index];

                      final String kuerzel =
                          item["kuerzel"].toString();

                      final String stadt =
                          item["stadt"].toString();

                      final bool gelernt =
                          item["gelernt"] == true;

                      return ListTile(
                        // Im Exakt-Modus:
                        // nur Stadt anzeigen.
                        //
                        // Im Nicht-sicher-Modus:
                        // Kürzel + Stadt anzeigen.
                        title: Text(
                          unscharf
                              ? "$kuerzel → $stadt"
                              : stadt,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        // Lernstatus
                        trailing: Icon(
                          gelernt
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: gelernt
                              ? Colors.green
                              : Colors.grey,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}