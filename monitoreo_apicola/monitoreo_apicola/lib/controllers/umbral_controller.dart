import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/umbral_model.dart';

class UmbralController {
  final _ref = FirebaseFirestore.instance.collection('umbrales');

  Future<void> guardarUmbral(UmbralModel umbral) async {
    await _ref.doc(umbral.tipo).set(umbral.toMap());
  }

  Future<UmbralModel?> obtenerUmbral(String tipo) async {
    final doc = await _ref.doc(tipo).get();
    if (doc.exists) return UmbralModel.fromMap(doc.data()!);
    return null;
  }

  Future<List<UmbralModel>> listarTodos() async {
    final snapshot = await _ref.get();
    return snapshot.docs.map((d) => UmbralModel.fromMap(d.data())).toList();
  }
}
