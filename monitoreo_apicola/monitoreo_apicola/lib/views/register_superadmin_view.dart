import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'dashboard_view.dart';

class RegisterSuperAdminView extends StatefulWidget {
  const RegisterSuperAdminView({super.key});

  @override
  State<RegisterSuperAdminView> createState() => _RegisterSuperAdminViewState();
}

class _RegisterSuperAdminViewState extends State<RegisterSuperAdminView> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool loading = false;
  final _auth = AuthController();

  void _crearSuperadmin() async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => loading = true);

    final user = await _auth.register(email, pass, "superadmin");

    setState(() => loading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al crear superadmin")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛡️ Crear SUPERADMIN"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 60, color: Colors.deepPurple),
                const SizedBox(height: 16),
                const Text(
                  "Registro de Superadmin",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _crearSuperadmin,
                        icon: const Icon(Icons.person_add),
                        label: const Text("Crear SUPERADMIN"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
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
