import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Habla con el documento nodes/{nodeId} de Firestore.
/// La Raspberry escribe ahí: ultimo, analitica, estado, conexion y la
/// subcolección alertas. La app escribe: comando (calentar / enfriar).
class NodeService {
  final String nodeId;

  NodeService(this.nodeId);

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('nodes').doc(nodeId);

  /// Todo el documento del nodo, en vivo (se actualiza solo).
  Stream<Map<String, dynamic>?> stream() {
    return _doc.snapshots().map((snapshot) => snapshot.data());
  }

  /// Avisos que mandó la Raspberry en los últimos [days] días, del más nuevo
  /// al más viejo. Cada aviso trae su 'id' para poder borrarlo.
  Stream<List<Map<String, dynamic>>> alertsStream({int days = 7, int limit = 50}) {
    final desde = DateTime.now().subtract(Duration(days: days));
    return _doc
        .collection('alertas')
        .where('creada', isGreaterThan: Timestamp.fromDate(desde))
        .orderBy('creada', descending: true)
        .limit(limit)
        .snapshots()
        .map((query) => query.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Borra un aviso (cuando el usuario lo desliza).
  Future<void> deleteAlert(String id) async {
    await _doc.collection('alertas').doc(id).delete();
  }

  /// Manda una orden: 'calentar', 'enfriar' o 'parar'.
  /// La Raspberry la lee y se la pasa al ESP32 por MQTT.
  Future<void> sendCommand(String action, {int seconds = 1200}) async {
    await _doc.set({
      'comando': {
        'accion': action,
        'duracion_s': seconds,
        'id': DateTime.now().millisecondsSinceEpoch,
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'pedido_en': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }
}
