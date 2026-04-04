import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? name;
  final int? age;
  final Map<String, dynamic>? address;
  
  UserModel({this.id, this.name, this.age, this.address});

  factory UserModel.fromFireStore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return UserModel(
      id: snapshot.id,
      name: data?['name'] as String?,
      age: data?['age'] as int?,
      address: data?['address'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      if (name != null) "name": name,
      if (age != null) "age": age,
      if (address != null) "address": address,
    };
  }
}
