import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionarUmbralesView extends StatefulWidget {
  const GestionarUmbralesView({super.key});

  @override
  State<GestionarUmbralesView> createState() => _GestionarUmbralesViewState();
}

class _GestionarUmbralesViewState extends State<GestionarUmbralesView> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  Future<void> _guardarUmbral() async {
    if (_formKey.currentState!.validate()) {
      final tipo = _tipoController.text.trim().toLowerCase();
      final min = double.tryParse(_minController.text.trim()) ?? 0;
      final max = double.tryParse(_maxController.text.trim()) ?? 0;

      await FirebaseFirestore.instance.collection('umbrales').doc(tipo).set({
        'min': min,
        'max': max,
      });

      _tipoController.clear();
      _minController.clear();
      _maxController.clear();
    }
  }

  Future<void> _eliminarUmbral(String tipo) async {
    await FirebaseFirestore.instance.collection('umbrales').doc(tipo).delete();
  }

  void _cargarParaEditar(Map<String, dynamic> data, String tipo) {
    _tipoController.text = tipo;
    _minController.text = data['min'].toString();
    _maxController.text = data['max'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⚙️ Gestión de Umbrales")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      controller: _tipoController,
                      decoration: const InputDecoration(labelText: "Tipo"),
                      validator: (val) => val!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Mínimo"),
                      validator: (val) => val!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _maxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Máximo"),
                      validator: (val) => val!.isEmpty ? "Requerido" : null,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _guardarUmbral,
                    child: const Text("Guardar / Editar"),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            const Text("Umbrales Registrados", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('umbrales')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text("No hay umbrales registrados.");
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(doc.id.toUpperCase()),
                          subtitle: Text(
                            "Min: ${data['min']} - Max: ${data['max']}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed:
                                    () => _cargarParaEditar(data, doc.id),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _eliminarUmbral(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
