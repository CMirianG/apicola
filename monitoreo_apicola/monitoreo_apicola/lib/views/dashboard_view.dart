import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import 'manage_users_view.dart';
import 'sensores_view.dart';
import 'alertas_view.dart';
import 'historial_view.dart';
import 'estado_view.dart';
import 'registrar_observacion_view.dart';
import 'registrar_mantenimiento_view.dart';
import 'registrar_colmena_view.dart';
import 'listar_mantenimientos_view.dart';
import 'gestionar_umbrales_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String role = "";
  final auth = AuthController();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  void _loadRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final r = await auth.getRole(uid);
      if (r != null) {
        setState(() => role = r);
      }
    }
  }

  Widget buildDashboardButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return SizedBox(
      width: 160,
      height: 90,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 26),
        label: Text(label, textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.teal[50],
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F4),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tu rol: $role",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // Gestión
                      if (role == "superadmin")
                        buildDashboardButton(
                          "👤 Gestionar Usuarios",
                          Icons.admin_panel_settings,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageUsersView(),
                            ),
                          ),
                          color: Colors.blue[50],
                        ),
                      if (role == "admin" || role == "superadmin")
                        buildDashboardButton(
                          "📏 Gestionar Umbrales",
                          Icons.settings,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GestionarUmbralesView(),
                            ),
                          ),
                          color: Colors.orange[50],
                        ),

                      // Visualización
                      buildDashboardButton(
                        "📡 Sensores en Tiempo Real",
                        Icons.sensors,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SensoresView(),
                          ),
                        ),
                      ),
                      buildDashboardButton(
                        "⚠️ Alertas Automáticas",
                        Icons.warning,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AlertasView(),
                          ),
                        ),
                        color: Colors.red[50],
                      ),
                      buildDashboardButton(
                        "📚 Historial Sensorial",
                        Icons.history,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistorialView(),
                          ),
                        ),
                      ),
                      buildDashboardButton(
                        "📊 Estado General",
                        Icons.bar_chart,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EstadoView()),
                        ),
                        color: Colors.blueGrey[100],
                      ),

                      // Registros
                      buildDashboardButton(
                        "📝 Registrar Observación",
                        Icons.note_add,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrarObservacionView(),
                          ),
                        ),
                        color: Colors.yellow[100],
                      ),
                      buildDashboardButton(
                        "📋 Ver Mantenimientos",
                        Icons.list_alt,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ListarMantenimientosView(),
                          ),
                        ),
                        color: Colors.green[100],
                      ),
                      buildDashboardButton(
                        "🛠️ Registrar Mantenimiento",
                        Icons.construction,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrarMantenimientoView(),
                          ),
                        ),
                        color: Colors.orange[100],
                      ),
                      buildDashboardButton(
                        "🐝 Registrar Colmena",
                        Icons.bug_report,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrarColmenaView(),
                          ),
                        ),
                        color: Colors.purple[100],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
