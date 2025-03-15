import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/biodata_model.dart';

class BiodataController extends ChangeNotifier {
  final CollectionReference _biodataCollection =
  FirebaseFirestore.instance.collection('biodata');

  Future<void> addBiodata(BiodataModel biodata) async {
    try {
      // Menambahkan dokumen baru ke Firestore dan mendapatkan ID dokumen
      final docRef = await _biodataCollection.add({
        'name': biodata.name,
        'age': biodata.age,
        'address': biodata.address,
      });

      // Mengupdate dokumen dengan ID yang sesuai
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error adding biodata: $e');
      rethrow; // Melemparkan error untuk ditangani di UI
    }
  }

  Future<void> updateBiodata(String docId, BiodataModel biodata) async {
    try {
      await _biodataCollection.doc(docId).update({
        'name': biodata.name,
        'age': biodata.age,
        'address': biodata.address,
      });
    } catch (e) {
      print('Error updating biodata: $e');
      rethrow; // Melemparkan error untuk ditangani di UI
    }
  }

  Future<void> deleteBiodata(String docId) async {
    try {
      await _biodataCollection.doc(docId).delete();
    } catch (e) {
      print('Error deleting biodata: $e');
      rethrow; // Melemparkan error untuk ditangani di UI
    }
  }

  Stream<List<BiodataModel>> getBiodataList() {
    return _biodataCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BiodataModel(
          id: doc.id, // Menggunakan ID dokumen Firestore (bertipe String)
          name: doc['name'],
          age: doc['age'],
          address: doc['address'],
        );
      }).toList();
    });
  }
}