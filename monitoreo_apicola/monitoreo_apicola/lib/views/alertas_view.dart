import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertasView extends StatefulWidget {
  const AlertasView({super.key});

  @override
  State<AlertasView> createState() => _AlertasViewState();
}

class _AlertasViewState extends State<AlertasView> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<String> sensores = ['sonido', 'co2'];
  List<Map<String, dynamic>> alertas = [];

  @override
  void initState() {
    super.initState();
    verificarAlertas();
  }

  Future<void> verificarAlertas() async {
    List<Map<String, dynamic>> resultado = [];

    for (String tipo in sensores) {
      final sensorDoc = await _db.collection('sensores').doc(tipo).get();
      final umbralDoc = await _db.collection('umbrales').doc(tipo).get();

      if (sensorDoc.exists && umbralDoc.exists) {
        final sensor = sensorDoc.data()!;
        final umbral = umbralDoc.data()!;

        final valor = (sensor['valor'] ?? 0).toDouble();
        final min = (umbral['minimo'] ?? 0).toDouble();
        final max = (umbral['maximo'] ?? 0).toDouble();

        if (valor < min || valor > max) {
          resultado.add({
            'tipo': tipo,
            'valor': valor,
            'min': min,
            'max': max,
            'timestamp': (sensor['timestamp'] as Timestamp).toDate(),
          });
        }
      }
    }

    setState(() => alertas = resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚠️ Alertas Automáticas"),
        backgroundColor: Colors.red[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            alertas.isEmpty
                ? const Center(
                  child: Text(
                    "✅ Todo está dentro de los umbrales.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                : ListView.builder(
                  itemCount: alertas.length,
                  itemBuilder: (context, index) {
                    final a = alertas[index];
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Card(
                          color: Colors.red[100],
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: const Icon(
                              Icons.warning,
                              color: Colors.red,
                            ),
                            title: Text(
                              "ALERTA: ${a['tipo'].toUpperCase()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            subtitle: Text(
                              "Valor actual: ${a['valor']}\n"
                              "Límite permitido: ${a['min']} - ${a['max']}\n"
                              "Hora: ${a['timestamp'].hour}:${a['timestamp'].minute.toString().padLeft(2, '0')}",
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
