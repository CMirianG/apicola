import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstadoView extends StatefulWidget {
  const EstadoView({super.key});

  @override
  State<EstadoView> createState() => _EstadoViewState();
}

class _EstadoViewState extends State<EstadoView> {
  Future<List<Map<String, dynamic>>> _getColmenas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('colmenas').get();

    final colmenas =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'nombre': data['nombre']?.toString().trim() ?? 'Sin nombre',
            'ubicacion': data['ubicacion'] ?? 'Sin ubicación',
            'estado': data['estado'] ?? 'Desconocido',
          };
        }).toList();

    print("🟢 Colmenas encontradas: ${colmenas.map((c) => c['nombre'])}");
    return colmenas;
  }

  Future<List<Map<String, dynamic>>> _getRelacionados(
    String colmena,
    String coleccion,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection(coleccion)
            .where('colmena', isEqualTo: colmena.trim())
            .orderBy('timestamp', descending: true)
            .limit(3)
            .get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

  Widget _seccionColmena(Map<String, dynamic> colmena) {
    final nombre = colmena['nombre'];
    final ubicacion = colmena['ubicacion'];
    final estado = colmena['estado'];

    return FutureBuilder(
      future: Future.wait([
        _getRelacionados(nombre, 'mantenimientos'),
        _getRelacionados(nombre, 'observaciones'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final mantenimientos = snapshot.data![0];
        final observaciones = snapshot.data![1];

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("📍 $ubicacion • Estado: $estado"),
                    const Divider(),

                    const Text(
                      "🛠️ Mantenimientos",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (mantenimientos.isEmpty)
                      const Text("No hay mantenimientos registrados.")
                    else
                      ...mantenimientos.map((m) {
                        final fecha = (m['timestamp'] as Timestamp).toDate();
                        return ListTile(
                          leading: const Icon(Icons.build),
                          title: Text(m['descripcion'] ?? ''),
                          subtitle: Text("${m['estado']} – $fecha"),
                        );
                      }),

                    const SizedBox(height: 10),

                    const Text(
                      "📝 Observaciones",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (observaciones.isEmpty)
                      const Text("No hay observaciones registradas.")
                    else
                      ...observaciones.map((o) {
                        final fecha = (o['timestamp'] as Timestamp).toDate();
                        return ListTile(
                          leading: const Icon(Icons.note_alt),
                          title: Text(o['nota'] ?? ''),
                          subtitle: Text("Fecha: $fecha"),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Estado General por Colmena"),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getColmenas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay colmenas registradas."));
          }

          final colmenas = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: colmenas.map(_seccionColmena).toList(),
          );
        },
      ),
    );
  }
}
