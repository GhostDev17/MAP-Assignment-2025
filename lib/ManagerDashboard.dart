import 'package:flutter/material.dart';
import 'pages/manage_teams_page.dart';
import 'pages/manage_players_page.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Dashboard'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('Welcome Manager!', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Manage Teams'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageTeamsPage()),
              );
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Manage Players'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManagePlayersPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
