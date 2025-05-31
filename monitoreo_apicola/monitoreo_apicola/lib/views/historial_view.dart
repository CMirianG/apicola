import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialView extends StatelessWidget {
  const HistorialView({super.key});

  IconData _getIconoSensor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'co2':
        return Icons.cloud;
      case 'sonido':
        return Icons.graphic_eq;
      default:
        return Icons.device_unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historialRef = FirebaseFirestore.instance
        .collection('historial')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Historial Sensorial"),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historialRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No hay registros en el historial."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final tipo = (data['tipo'] ?? 'desconocido').toString();
              final valor = data['valor'] ?? 0;
              final fecha = (data['timestamp'] as Timestamp).toDate();

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(_getIconoSensor(tipo), color: Colors.teal),
                      title: Text(
                        tipo.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Valor: $valor\n"
                        "${fecha.day}/${fecha.month}/${fecha.year} "
                        "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}",
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
