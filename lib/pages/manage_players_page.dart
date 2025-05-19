import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagePlayersPage extends StatefulWidget {
  const ManagePlayersPage({super.key});

  @override
  State<ManagePlayersPage> createState() => _ManagePlayersPageState();
}

class _ManagePlayersPageState extends State<ManagePlayersPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? currentUser;
  String role = 'manager';
  List<QueryDocumentSnapshot> teams = [];

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _loadUserRoleAndTeams();
  }

  Future<void> _loadUserRoleAndTeams() async {
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          role = userDoc['role'];
        });
      }

      QuerySnapshot teamSnapshot = role == 'admin'
          ? await _firestore.collection('teams').get()
          : await _firestore
          .collection('teams')
          .where('managerId', isEqualTo: currentUser!.uid)
          .get();

      setState(() {
        teams = teamSnapshot.docs;
      });
    }
  }

  void _showPlayerDialog({DocumentSnapshot? doc}) {
    final nameController = TextEditingController(text: doc?['name']);
    final jerseyController = TextEditingController(text: doc?['jerseyNumber']?.toString());
    final ageController = TextEditingController(text: doc?['age']?.toString());
    final weightController = TextEditingController(text: doc?['weight']?.toString());
    String position = doc?['position'] ?? 'Forward';
    String? selectedTeamId = doc?['teamId'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? 'Add Player' : 'Edit Player'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Position'),
                value: position,
                onChanged: (val) => setState(() => position = val!),
                items: ['Goalkeeper', 'Defender', 'Midfielder', 'Forward']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
              ),
              TextField(controller: jerseyController, decoration: InputDecoration(labelText: 'Jersey Number'), keyboardType: TextInputType.number),
              TextField(controller: ageController, decoration: InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
              TextField(controller: weightController, decoration: InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
              DropdownButtonFormField(
                value: selectedTeamId,
                decoration: InputDecoration(labelText: 'Team'),
                onChanged: (val) => setState(() => selectedTeamId = val),
                items: teams
                    .map((team) => DropdownMenuItem(
                  value: team.id,
                  child: Text(team['name']),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final jersey = int.tryParse(jerseyController.text.trim()) ?? 0;
              final age = int.tryParse(ageController.text.trim()) ?? 0;
              final weight = double.tryParse(weightController.text.trim()) ?? 0;

              if (name.isEmpty || selectedTeamId == null) return;

              final selectedTeam = teams.firstWhere((t) => t.id == selectedTeamId);

              final data = {
                'name': name,
                'position': position,
                'jerseyNumber': jersey,
                'age': age,
                'weight': weight,
                'teamId': selectedTeamId,
                'teamName': selectedTeam['name'],
                'managerId': currentUser!.uid,
                'timestamp': FieldValue.serverTimestamp(),
              };

              if (doc == null) {
                await _firestore.collection('players').add(data);
              } else {
                await _firestore.collection('players').doc(doc.id).update(data);
              }

              Navigator.pop(context);
            },
            child: Text(doc == null ? 'Add' : 'Update'),
          )
        ],
      ),
    );
  }

  void _deletePlayer(String docId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Player'),
        content: Text('Are you sure you want to delete this player?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('players').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = role == 'admin'
        ? _firestore.collection('players').orderBy('timestamp', descending: true).snapshots()
        : _firestore
        .collection('players')
        .where('managerId', isEqualTo: currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Players'),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final players = snapshot.data!.docs;

          if (players.isEmpty) return Center(child: Text('No players yet'));

          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              final isOwner = player['managerId'] == currentUser?.uid;
              final isAdmin = role == 'admin';

              return Card(
                child: ListTile(
                  title: Text('${player['name']} - #${player['jerseyNumber']}'),
                  subtitle: Text(
                    'Team: ${player['teamName']} | Position: ${player['position']}',
                  ),
                  trailing: (isOwner || isAdmin)
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPlayerDialog(doc: player),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePlayer(player.id),
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
        onPressed: () => _showPlayerDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      )
          : null,
    );
  }
}
