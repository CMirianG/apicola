import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final UserController _controller = UserController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String _rolSeleccionado = "admin";
  List<UserModel> usuarios = [];
  String currentUserUid = "";

  @override
  void initState() {
    super.initState();
    _verificarAcceso();
  }

  void _verificarAcceso() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data?['role'] != 'superadmin') {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Acceso restringido solo para SUPERADMIN"),
          ),
        );
      }
    } else {
      setState(() => currentUserUid = uid);
      _loadUsers();
    }
  }

  void _loadUsers() async {
    usuarios = await _controller.getAllUsers();
    setState(() {});
  }

  void _crearUsuario() async {
    await _controller.createUser(
      _emailCtrl.text,
      _passCtrl.text,
      _rolSeleccionado,
    );
    _emailCtrl.clear();
    _passCtrl.clear();
    setState(() => _rolSeleccionado = "admin");
    _loadUsers();
  }

  void _borrarUsuario(String uid) async {
    if (uid == currentUserUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No puedes eliminar tu propio usuario superadmin"),
        ),
      );
      return;
    }

    await _controller.deleteUser(uid);
    _loadUsers();
  }

  void _actualizarRol(String uid, String nuevoRol) async {
    await _controller.updateUserRole(uid, nuevoRol);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👤 Gestión de Usuarios"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Crear Nuevo Usuario",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value: _rolSeleccionado,
                  decoration: const InputDecoration(labelText: "Rol"),
                  items:
                      ['admin', 'operador', 'superadmin'].map((rol) {
                        return DropdownMenuItem(
                          value: rol,
                          child: Text(rol.toUpperCase()),
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => _rolSeleccionado = val!),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _crearUsuario,
                  icon: const Icon(Icons.person_add),
                  label: const Text("Crear Usuario"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                  ),
                ),
                const Divider(height: 40),
                const Text(
                  "Usuarios Registrados",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usuarios.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2,
                  ),
                  itemBuilder: (context, index) {
                    final u = usuarios[index];
                    final roles = ['admin', 'operador'];
                    if (!roles.contains(u.role)) roles.add(u.role);

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              u.email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Rol: "),
                                DropdownButton<String>(
                                  value: u.role,
                                  items:
                                      roles.map((rol) {
                                        return DropdownMenuItem(
                                          value: rol,
                                          child: Text(rol.toUpperCase()),
                                        );
                                      }).toList(),
                                  onChanged:
                                      (nuevoRol) =>
                                          _actualizarRol(u.uid, nuevoRol!),
                                ),
                              ],
                            ),
                            if (u.uid != currentUserUid)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                onPressed: () => _borrarUsuario(u.uid),
                              )
                            else
                              const Text(
                                "No puedes eliminarte",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
