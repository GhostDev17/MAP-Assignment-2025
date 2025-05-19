import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageTeamsPage extends StatefulWidget {
  const ManageTeamsPage({super.key});

  @override
  State<ManageTeamsPage> createState() => _ManageTeamsPageState();
}

class _ManageTeamsPageState extends State<ManageTeamsPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? currentUser;
  String role = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    currentUser = _auth.currentUser;

    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          role = userDoc['role'];
          loading = false;
        });
      }
    }
  }

  Stream<QuerySnapshot> _getTeamsStream() {
    if (role == 'admin') {
      return _firestore.collection('teams').orderBy('timestamp', descending: true).snapshots();
    } else {
      return _firestore
          .collection('teams')
          .where('managerId', isEqualTo: currentUser?.uid)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  void _showTeamDialog({DocumentSnapshot? doc}) {
    final TextEditingController nameController = TextEditingController(text: doc?['name']);
    final TextEditingController locationController = TextEditingController(text: doc?['location']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? 'Add Team' : 'Edit Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Team Name')),
            TextField(controller: locationController, decoration: InputDecoration(labelText: 'Location')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final location = locationController.text.trim();
              if (name.isEmpty || location.isEmpty) return;

              if (doc == null) {
                await _firestore.collection('teams').add({
                  'name': name,
                  'location': location,
                  'managerId': currentUser?.uid,
                  'timestamp': FieldValue.serverTimestamp(),
                });
              } else {
                await _firestore.collection('teams').doc(doc.id).update({
                  'name': name,
                  'location': location,
                });
              }

              Navigator.pop(context);
            },
            child: Text(doc == null ? 'Add' : 'Update'),
          )
        ],
      ),
    );
  }

  void _deleteTeam(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this team?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          )
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('teams').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Teams'),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTeamsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error loading teams'));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final teams = snapshot.data!.docs;

          if (teams.isEmpty) return Center(child: Text('No teams found'));

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final isOwner = team['managerId'] == currentUser?.uid;
              final isAdmin = role == 'admin';

              return Card(
                child: ListTile(
                  title: Text(team['name']),
                  subtitle: Text('Location: ${team['location']}'),
                  trailing: (isOwner || isAdmin)
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTeamDialog(doc: team),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTeam(team.id),
                      ),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: (role == 'admin' || role == 'manager')
          ? FloatingActionButton(
        onPressed: () => _showTeamDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      )
          : null,
    );
  }
}
