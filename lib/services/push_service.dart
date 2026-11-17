import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:material_ui/material_ui.dart';

/// Notificaciones push (Firebase Cloud Messaging).
/// La Raspberry manda cada aviso al "tema" zumbee_NODO (ej. zumbee_ZB_01).
/// Si el usuario tiene "Recibir alertas" prendido, la app se suscribe a ese
/// tema y Android muestra la notificación aunque la app esté cerrada.
class PushService {
  PushService._();

  static final FirebaseMessaging _fm = FirebaseMessaging.instance;

  /// Para mostrar el aviso como barrita abajo cuando la app está abierta.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static String? _currentTopic;
  static bool _listening = false;

  static String topicFor(String nodeId) => 'zumbee_$nodeId';

  static DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  /// ¿El usuario quiere recibir alertas? (por defecto sí)
  static Future<bool> isEnabled() async {
    try {
      final data = (await _userDoc?.get())?.data();
      return data?['recibirAlertas'] != false;
    } catch (error) {
      return true;
    }
  }

  /// Deja la suscripción como debe estar según el nodo y la preferencia.
  static Future<void> sync(String? nodeId) async {
    try {
      final enabled = await isEnabled();
      final wanted = (enabled && nodeId != null) ? topicFor(nodeId) : null;
      if (wanted == _currentTopic) return;
      if (_currentTopic != null) await _fm.unsubscribeFromTopic(_currentTopic!);
      if (wanted != null) {
        await _fm.requestPermission();
        await _fm.subscribeToTopic(wanted);
      }
      _currentTopic = wanted;
    } catch (error) {
      return;
    }
  }

  /// Prende o apaga las alertas. Devuelve false si Android no dio permiso.
  static Future<bool> setEnabled(bool enabled, String? nodeId) async {
    if (enabled) {
      final settings = await _fm.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return false;
      }
    }
    await _userDoc?.set({'recibirAlertas': enabled}, SetOptions(merge: true));
    await sync(nodeId);
    return true;
  }

  /// Con la app abierta, Android no muestra la notificación: la mostramos aquí.
  static void listenForeground() {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.onMessage.listen((message) {
      final text = message.notification?.body;
      if (text == null) return;
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 6)),
      );
    });
  }
}
