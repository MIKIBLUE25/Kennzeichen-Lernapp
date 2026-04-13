import 'package:flutter/material.dart';
import '../data/kennzeichen_data.dart';

class SucheSeite extends StatefulWidget {
  const SucheSeite({super.key});

  @override
  State<SucheSeite> createState() => _SucheSeiteState();
}

class _SucheSeiteState extends State<SucheSeite> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> results = [];

    kennzeichenDaten.forEach((kuerzel, liste) {
      if (kuerzel.toLowerCase().contains(query.toLowerCase())) {
        for (var eintrag in liste) {
          results.add({
            "kuerzel": kuerzel,
            "stadt": eintrag["stadt"],
            "gelernt": eintrag["gelernt"] ?? false,
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Suche")),
      body: Column(
        children: [

          // 🔍 Suchfeld
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              decoration: const InputDecoration(
                hintText: "Kennzeichen eingeben...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 🔥 Ergebnisse
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];

                return ListTile(
                  title: Text(
                    "${item["kuerzel"]} → ${item["stadt"]}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: Icon(
                    item["gelernt"]
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: item["gelernt"]
                        ? Colors.green
                        : Colors.red,
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