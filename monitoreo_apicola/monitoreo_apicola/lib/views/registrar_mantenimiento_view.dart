import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarMantenimientoView extends StatefulWidget {
  const RegistrarMantenimientoView({super.key});

  @override
  State<RegistrarMantenimientoView> createState() =>
      _RegistrarMantenimientoViewState();
}

class _RegistrarMantenimientoViewState
    extends State<RegistrarMantenimientoView> {
  final TextEditingController _descripcionController = TextEditingController();
  String _estado = "pendiente";
  String? _colmenaSeleccionada;
  List<String> _colmenas = [];
  bool _cargando = false;

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
    final descripcion = _descripcionController.text.trim();

    if (descripcion.isEmpty || _colmenaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _cargando = true);

    await FirebaseFirestore.instance.collection('mantenimientos').add({
      'descripcion': descripcion,
      'estado': _estado,
      'colmena': _colmenaSeleccionada,
      'timestamp': Timestamp.now(),
    });

    setState(() {
      _cargando = false;
      _descripcionController.clear();
      _estado = 'pendiente';
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Mantenimiento registrado")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛠️ Registrar Mantenimiento"),
        backgroundColor: Colors.orange[700],
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
                          controller: _descripcionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Descripción del mantenimiento",
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _estado,
                          decoration: const InputDecoration(
                            labelText: "Estado",
                            prefixIcon: Icon(Icons.assignment_turned_in),
                          ),
                          items:
                              ['pendiente', 'realizado'].map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toUpperCase()),
                                );
                              }).toList(),
                          onChanged: (val) => setState(() => _estado = val!),
                        ),
                        const SizedBox(height: 20),
                        _cargando
                            ? const CircularProgressIndicator()
                            : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text("Guardar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
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
