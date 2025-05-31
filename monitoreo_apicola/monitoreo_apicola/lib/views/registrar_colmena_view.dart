import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarColmenaView extends StatefulWidget {
  const RegistrarColmenaView({super.key});

  @override
  State<RegistrarColmenaView> createState() => _RegistrarColmenaViewState();
}

class _RegistrarColmenaViewState extends State<RegistrarColmenaView> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _ubicacionCtrl = TextEditingController();
  String _estadoSeleccionado = "Activa";
  bool _guardando = false;

  void _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    final ubicacion = _ubicacionCtrl.text.trim();

    if (nombre.isEmpty || ubicacion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _guardando = true);

    await FirebaseFirestore.instance.collection('colmenas').add({
      'nombre': nombre,
      'ubicacion': ubicacion,
      'estado': _estadoSeleccionado,
      'fecha_registro': Timestamp.now(),
    });

    setState(() {
      _nombreCtrl.clear();
      _ubicacionCtrl.clear();
      _estadoSeleccionado = "Activa";
      _guardando = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Colmena registrada")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🐝 Registrar Colmena"),
        backgroundColor: Colors.brown[700],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hive, size: 60, color: Colors.brown),
                const SizedBox(height: 16),
                TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre de la colmena",
                    prefixIcon: Icon(Icons.label),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ubicacionCtrl,
                  decoration: const InputDecoration(
                    labelText: "Ubicación",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Estado general",
                  ),
                  items:
                      ['Activa', 'Débil', 'En mantenimiento', 'Inactiva']
                          .map(
                            (estado) => DropdownMenuItem(
                              value: estado,
                              child: Text(estado),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (val) => setState(() => _estadoSeleccionado = val!),
                ),
                const SizedBox(height: 20),
                _guardando
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Guardar Colmena"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
