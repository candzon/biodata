import 'package:flutter/material.dart';
import '../models/biodata_model.dart'; // Sesuaikan dengan path file biodata_model.dart
import '../controllers/biodata_controller.dart'; // Sesuaikan dengan path file biodata_controller.dart

class BiodataView extends StatefulWidget {
  const BiodataView({Key? key}) : super(key: key);

  @override
  State<BiodataView> createState() => _BiodataViewState();
}

class _BiodataViewState extends State<BiodataView> {
  final BiodataController _controller = BiodataController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final address = _addressController.text;

    if (name.isNotEmpty && age > 0 && address.isNotEmpty) {
      try {
        final biodata = BiodataModel(
          id: '', // ID akan diisi oleh Firestore
          name: name,
          age: age,
          address: address,
        );
        await _controller.addBiodata(biodata);
        _nameController.clear();
        _ageController.clear();
        _addressController.clear();
        setState(() {}); // Refresh UI
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add biodata: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly!')),
      );
    }
  }

  Future<void> _deleteData(String docId) async {
    try {
      await _controller.deleteBiodata(docId);
      setState(() {}); // Refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete biodata: $e')),
      );
    }
  }

  Future<void> _updateData(BiodataModel biodata) async {
    _nameController.text = biodata.name;
    _ageController.text = biodata.age.toString();
    _addressController.text = biodata.address;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Biodata'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = _nameController.text;
                final age = int.tryParse(_ageController.text) ?? 0;
                final address = _addressController.text;

                if (name.isNotEmpty && age > 0 && address.isNotEmpty) {
                  try {
                    final updatedBiodata = BiodataModel(
                      id: biodata.id, // ID tetap sebagai String
                      name: name,
                      age: age,
                      address: address,
                    );
                    await _controller.updateBiodata(biodata.id, updatedBiodata);
                    _nameController.clear();
                    _ageController.clear();
                    _addressController.clear();
                    setState(() {});
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update biodata: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields correctly!')),
                  );
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Form
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Tabel Data
            Expanded(
              child: StreamBuilder<List<BiodataModel>>(
                stream: _controller.getBiodataList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available.'));
                  }

                  final biodataList = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Age')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: biodataList.map((biodata) {
                        return DataRow(
                          cells: [
                            DataCell(Text(biodata.id)), // ID sebagai String
                            DataCell(Text(biodata.name)),
                            DataCell(Text(biodata.age.toString())),
                            DataCell(Text(biodata.address)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _updateData(biodata);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await _deleteData(biodata.id); // ID sebagai String
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}