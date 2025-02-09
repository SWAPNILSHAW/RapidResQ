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

  final User? _user = FirebaseAuth.instance.currentUser; // Get logged-in user

  CollectionReference<Map<String, dynamic>> get _guardianCollection {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_user?.uid) // Store inside the user's document
        .collection('guardians');
  }

  Future<void> _addGuardian() async {
    if (_nameController.text.isNotEmpty && _numberController.text.isNotEmpty) {
      await _guardianCollection.add({
        'name': _nameController.text,
        'number': _numberController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _numberController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showAddGuardianDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Guardian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: "Enter your Guardian Name",
              hintText: "Name",
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextField(
                controller: _numberController,
                labelText: "Enter your Phone Number",
                hintText: "Phone Number",
                keyboardType: TextInputType.number,
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),

          const SizedBox(width: 10 ,),
          TextButton(onPressed: _addGuardian, child: const Text('Add')),
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
        title: "Add Guardian Details",
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        showLeading: false,
      ),
      body: StreamBuilder(
        stream: _guardianCollection
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No guardians added yet.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data =
              doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.person, color: Colors.red),
                title: Text(data['name']),
                subtitle: Text(data['number']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeGuardian(doc.id),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGuardianDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
