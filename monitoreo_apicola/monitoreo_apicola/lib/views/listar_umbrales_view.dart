import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListarUmbralesView extends StatelessWidget {
  const ListarUmbralesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('umbrales');

    return Scaffold(
      appBar: AppBar(title: const Text("📏 Lista de Umbrales")),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay umbrales configurados."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final tipo = docs[i].id;
              final min = data['min'];
              final max = data['max'];

              return ListTile(
                leading: const Icon(Icons.settings),
                title: Text("Sensor: $tipo".toUpperCase()),
                subtitle: Text("Mínimo: $min | Máximo: $max"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(context, '/configurarUmbral');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
