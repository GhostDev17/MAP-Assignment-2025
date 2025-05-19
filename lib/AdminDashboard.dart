import 'package:flutter/material.dart';
import 'AdminEventsPage.dart';
import 'AdminNewsPage.dart';
import 'pages/manage_teams_page.dart';
import 'pages/manage_players_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
          Text('Welcome Admin!', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Manage News'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminNewsPage()),
              );
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Manage Events'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminEventsPage()),
              );
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Manage Teams'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManageTeamsPage()),
              );
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Manage Players'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManagePlayersPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
