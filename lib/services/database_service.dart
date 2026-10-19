import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String apiaryName,
  }) async {
    await _db.collection('users').doc(userId).set({
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'apiaryName': apiaryName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String apiaryName,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'apiaryName': apiaryName.trim(),
    });
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> hivesStream() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('hives')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getHives() async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('hives')
        .orderBy('createdAt')
        .get();

    final List<Map<String, dynamic>> hives = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      hives.add(data);
    }
    return hives;
  }

  Future<String> addHive({
    required String name,
    required String location,
    required String hiveType,
    required String nodeIdentifier,
    required String channelId,
  }) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('hives')
        .add({
          'name': name.trim(),
          'location': location.trim(),
          'hiveType': hiveType.trim(),
          'nodeIdentifier': nodeIdentifier.trim(),
          'channelId': channelId.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
    return doc.id;
  }

  Future<void> updateHive({
    required String hiveId,
    required String name,
    required String location,
    required String hiveType,
    required String nodeIdentifier,
    required String channelId,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('hives')
        .doc(hiveId)
        .update({
          'name': name.trim(),
          'location': location.trim(),
          'hiveType': hiveType.trim(),
          'nodeIdentifier': nodeIdentifier.trim(),
          'channelId': channelId.trim(),
        });
  }

  Future<void> deleteHive(String hiveId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('hives')
        .doc(hiveId)
        .delete();
  }
}