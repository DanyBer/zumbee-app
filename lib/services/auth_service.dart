import 'package:firebase_auth/firebase_auth.dart';
import 'package:zumbee_app/services/database_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String apiaryName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await DatabaseService().createUserProfile(
        userId: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        apiaryName: apiaryName,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      return translateError(error.code);
    } catch (error) {
      debugPrint("FALLO REGISTRO: $error");
      return "Ocurrió un error inesperado";
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      return translateError(error.code);
    } catch (error) {
      return "Ocurrió un error inesperado";
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (error) {
      return translateError(error.code);
    } catch (error) {
      return "No se pudo enviar el correo";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String translateError(String code) {
    switch (code) {
      case 'invalid-email':
        return "El correo no tiene un formato válido";
      case 'email-already-in-use':
        return "Ese correo ya está registrado";
      case 'weak-password':
        return "La contraseña debe tener al menos 6 caracteres";
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return "Correo o contraseña incorrectos";
      case 'network-request-failed':
        return "Sin conexión a internet";
      case 'too-many-requests':
        return "Demasiados intentos, espera un momento";
      default:
        return "No se pudo completar la operación";
    }
  }
}
