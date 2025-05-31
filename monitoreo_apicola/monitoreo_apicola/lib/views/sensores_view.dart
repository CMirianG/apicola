import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SensoresView extends StatelessWidget {
  const SensoresView({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _obtenerDatosSensor(
    String tipo,
  ) {
    return FirebaseFirestore.instance
        .collection('sensores')
        .doc(tipo)
        .snapshots();
  }

  Future<Map<String, dynamic>?> _obtenerUmbrales(String tipo) async {
    final doc =
        await FirebaseFirestore.instance.collection('umbrales').doc(tipo).get();
    return doc.data();
  }

  Widget _tarjetaSensor(
    String titulo,
    String tipo,
    IconData icono,
    Color color,
  ) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _obtenerDatosSensor(tipo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data();
        if (data == null) return const SizedBox();

        final rawValor = data['valor'];
        final valor = (rawValor is num) ? rawValor.toDouble() : 0.0;

        DateTime? fecha;
        try {
          final ts = data['timestamp'];
          if (ts is Timestamp) fecha = ts.toDate();
        } catch (_) {}

        final hora =
            (fecha != null)
                ? "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}"
                : "Sin hora";

        return FutureBuilder<Map<String, dynamic>?>(
          future: _obtenerUmbrales(tipo),
          builder: (context, umbralSnapshot) {
            if (!umbralSnapshot.hasData) return const SizedBox();

            final umbral = umbralSnapshot.data ?? {};
            final min = (umbral['min'] ?? 0).toDouble();
            final max = (umbral['max'] ?? 99999).toDouble();

            final esAnomalo = valor < min || valor > max;
            final colorFondo =
                esAnomalo ? Colors.red[100] : color.withOpacity(0.08);

            return Card(
              color: colorFondo,
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(icono, size: 32, color: color),
                title: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Valor: ${valor.toStringAsFixed(2)}\nÚltima actualización: $hora",
                ),
                trailing:
                    esAnomalo
                        ? const Icon(Icons.warning, color: Colors.red)
                        : const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📡 Sensores en Tiempo Real"),
        backgroundColor: Colors.teal[700],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _tarjetaSensor(
                  "Sonido",
                  "sonido",
                  Icons.graphic_eq,
                  Colors.blue,
                ),
                _tarjetaSensor("CO₂", "co2", Icons.cloud, Colors.green),
                // _tarjetaSensor("Peso", "peso", Icons.monitor_weight, Colors.orange),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
