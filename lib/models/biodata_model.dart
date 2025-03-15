import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

@immutable
class BiodataModel {
  final String id; // Ubah tipe data menjadi String
  final String name;
  final int age;
  final String address;

  const BiodataModel({
    required this.id,
    required this.name,
    required this.age,
    required this.address,
  });
}