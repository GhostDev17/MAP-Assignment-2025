// Database helper class
class NHUDatabase {
  static final NHUDatabase instance = NHUDatabase._init();
  static Database? _database;

  NHUDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nhu_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        coach_name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        registration_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        team_id INTEGER,
        name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        position TEXT NOT NULL,
        contact_number TEXT,
        FOREIGN KEY (team_id) REFERENCES teams (id)
      )
    ''');

    // Additional tables for events, registrations, etc.
  }
}