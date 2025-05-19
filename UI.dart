// Main App Structure
class NHUApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namibia Hockey Union',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      routes: {
        '/teams': (context) => TeamRegistrationScreen(),
        '/events': (context) => EventScreen(),
        '/players': (context) => PlayerManagementScreen(),
        '/news': (context) => NewsFeedScreen(),
      },
    );
  }
}

// Example Screen - Team Registration
class TeamRegistrationScreen extends StatefulWidget {
  @override
  _TeamRegistrationScreenState createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  // Other controllers...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Team Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: InputDecoration(labelText: 'Team Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter team name';
                  }
                  return null;
                },
              ),
              // Other form fields...
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Register Team'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newTeam = HockeyTeam(
        teamName: _teamNameController.text,
        // Other fields...
      );
      
      final db = await NHUDatabase.instance.database;
      await db.insert('teams', newTeam.toMap());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team registered successfully!')),
      );
    }
  }
}