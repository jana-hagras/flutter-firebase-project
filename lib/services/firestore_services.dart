import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<UserModel> get _userRef =>
      _db.collection('users').withConverter<UserModel>(
            fromFirestore: (snapshot, _) => UserModel.fromFireStore(snapshot),
            toFirestore: (user, _) => user.toFireStore(),
          );

  // add
  Future<DocumentReference> addUser(UserModel data) async {
    return await _userRef.add(data); // auto id
  }

  Future<void> setUser(String id, UserModel data) async {
    await _userRef.doc(id).set(data); // custom id
  }

  Future<void> updatePartial(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> updateUser(String id, UserModel data) async {
    await _userRef.doc(id).update(data.toFireStore());
  }

  Future<void> deleteUser(String id) async {
    await _userRef.doc(id).delete();
  }

  Future<List<QueryDocumentSnapshot>> getUsers() async {
    final snapShot = await _userRef.get();
    return snapShot.docs;
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return await _db.collection('users').doc(id).get();
  }

  Stream<List<UserModel>> streamUsers() {
    return _userRef
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => e.data()).toList());
  }

  // filter
  Future<List<QueryDocumentSnapshot>> queryUsers() async {
    final snapShot =
        await _db.collection('users').where('age', isGreaterThan: 18).get();
    return snapShot.docs;
  }

  Future<void> addUserTimeStamp(UserModel user) async {
    await _db.collection('users').add({
      ...user.toFireStore(),
      "createdAt": FieldValue.serverTimestamp(),
      "address": {"street": "street name", "city": "city name"}
    });
  }

  Future<void> incrementAge(String id) async {
    await _db
        .collection('users')
        .doc(id)
        .update({"age": FieldValue.increment(1)});
  }

  Future<void> deleteField(String id, String field) async {
    await _db.collection('users').doc(id).update({field: FieldValue.delete()});
  }

  Future<void> updateNestedField(String id) async {
    await _db
        .collection('users')
        .doc(id)
        .update({"address.city": "Cairo", "address.street": "123 Main St"});
  }
}




  /*
  {
  "name": "Sara",
  "age": 25,
  "createdAt": Timestamp
  address: {
    "street": "123 Main St",
    "city": "Cairo"

  }


   */

