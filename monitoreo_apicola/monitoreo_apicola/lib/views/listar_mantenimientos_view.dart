import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListarMantenimientosView extends StatelessWidget {
  const ListarMantenimientosView({super.key});

  void _eliminar(String id, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('mantenimientos')
        .doc(id)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Eliminado correctamente")),
    );
  }

  void _cambiarEstado(String id, String estadoActual) async {
    final nuevo = estadoActual == 'pendiente' ? 'realizado' : 'pendiente';
    await FirebaseFirestore.instance
        .collection('mantenimientos')
        .doc(id)
        .update({'estado': nuevo});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛠️ Mantenimientos Registrados"),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('mantenimientos')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay mantenimientos aún."));
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              final descripcion = data['descripcion'] ?? '';
              final colmena = data['colmena'] ?? 'Sin colmena';
              final estado = data['estado'] ?? '';
              final fecha = (data['timestamp'] as Timestamp).toDate();

              final colorEstado =
                  estado == 'pendiente'
                      ? Colors.orange[100]
                      : Colors.green[100];

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    color: colorEstado,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        descripcion,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "📍 $colmena • Estado: ${estado.toUpperCase()}\n"
                        "📅 ${fecha.day}/${fecha.month}/${fecha.year} "
                        "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}",
                      ),
                      trailing: Wrap(
                        spacing: 10,
                        children: [
                          IconButton(
                            icon: Icon(
                              estado == 'pendiente'
                                  ? Icons.check_circle_outline
                                  : Icons.undo,
                              color:
                                  estado == 'pendiente'
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                            tooltip: "Cambiar estado",
                            onPressed: () => _cambiarEstado(id, estado),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Eliminar",
                            onPressed: () => _eliminar(id, context),
                          ),
                        ],
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
