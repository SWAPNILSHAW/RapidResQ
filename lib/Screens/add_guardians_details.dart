import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:woman_safety/drawer/custom_app_bar.dart';
import 'package:woman_safety/widget/custom_text_field.dart';

class AddGuardiansDetails extends StatefulWidget {
  const AddGuardiansDetails({super.key});

  @override
  _AddGuardiansDetailsState createState() => _AddGuardiansDetailsState();
}

class _AddGuardiansDetailsState extends State<AddGuardiansDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  final User? _user = FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> get _guardianCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid)
        .collection('guardians');
  }

  Future<void> _addOrUpdateGuardian(String? docId) async {
    if (_nameController.text.isNotEmpty && _numberController.text.isNotEmpty) {
      if (docId == null) { // Adding a new guardian
        await _guardianCollection.add({
          'name': _nameController.text,
          'number': _numberController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else { // Updating an existing guardian
        await _guardianCollection.doc(docId).update({
          'name': _nameController.text,
          'number': _numberController.text,
          'timestamp': FieldValue.serverTimestamp(), // Update timestamp on edit
        });
      }

      _nameController.clear();
      _numberController.clear();
      Navigator.of(context).pop();
    }
  }


  void _showAddGuardianDialog({Map<String, dynamic>? guardianData, String? docId}) {
    if (guardianData != null) {
      _nameController.text = guardianData['name'];
      _numberController.text = guardianData['number'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(guardianData == null ? 'Add Guardian' : 'Edit Guardian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: "Enter your Guardian Name",
              hintText: "Name",
              keyboardType: TextInputType.text,
              obscureText: false,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _numberController,
              labelText: "Enter your Phone Number",
              hintText: "Phone Number",
              keyboardType: TextInputType.number,
              obscureText: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () => _addOrUpdateGuardian(docId),
            child: Text(guardianData == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeGuardian(String docId) async {
    await _guardianCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Add Details",
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        showLeading: false,
      ),
      body: StreamBuilder(
        stream: _guardianCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No guardians added yet.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    data['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Phone: ${data['number']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddGuardianDialog(
                          guardianData: data,
                          docId: doc.id,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeGuardian(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGuardianDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}