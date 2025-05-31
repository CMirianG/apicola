import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarObservacionView extends StatefulWidget {
  const RegistrarObservacionView({super.key});

  @override
  State<RegistrarObservacionView> createState() =>
      _RegistrarObservacionViewState();
}

class _RegistrarObservacionViewState extends State<RegistrarObservacionView> {
  final TextEditingController _notaController = TextEditingController();
  String? _colmenaSeleccionada;
  List<String> _colmenas = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarColmenas();
  }

  void _cargarColmenas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('colmenas').get();
    final nombres =
        snapshot.docs.map((doc) => doc.data()['nombre'].toString()).toList();

    setState(() {
      _colmenas = nombres;
      if (_colmenas.isNotEmpty) {
        _colmenaSeleccionada = _colmenas.first;
      }
    });
  }

  void _guardar() async {
    final nota = _notaController.text.trim();
    if (nota.isEmpty || _colmenaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _guardando = true);

    await FirebaseFirestore.instance.collection('observaciones').add({
      'nota': nota,
      'colmena': _colmenaSeleccionada,
      'timestamp': Timestamp.now(),
    });

    setState(() {
      _notaController.clear();
      _guardando = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Observación registrada")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📝 Registrar Observación"),
        backgroundColor: Colors.indigo[700],
      ),
      body:
          _colmenas.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _colmenaSeleccionada,
                          decoration: const InputDecoration(
                            labelText: "Colmena",
                            prefixIcon: Icon(Icons.hive),
                          ),
                          items:
                              _colmenas.map((nombre) {
                                return DropdownMenuItem(
                                  value: nombre,
                                  child: Text(nombre),
                                );
                              }).toList(),
                          onChanged:
                              (val) =>
                                  setState(() => _colmenaSeleccionada = val),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notaController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: "Escribe tu observación",
                            prefixIcon: Icon(Icons.note_alt),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _guardando
                            ? const CircularProgressIndicator()
                            : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text("Guardar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: _guardar,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
