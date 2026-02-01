import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/detection/data/models/detection_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'avoscan.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        photoUrl TEXT,
        currentWorkspaceId TEXT,
        createdAt TEXT NOT NULL,
        lastLogin TEXT
      )
    ''');

    // Tabla de espacios de trabajo
    await db.execute('''
      CREATE TABLE workspaces(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    // Tabla de detecciones
    await db.execute('''
      CREATE TABLE detections(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        workspaceId TEXT,
        imagePath TEXT NOT NULL,
        disease TEXT NOT NULL,
        confidence REAL NOT NULL,
        recommendation TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (workspaceId) REFERENCES workspaces(id)
      )
    ''');

    // Tabla de estadísticas por usuario
    await db.execute('''
      CREATE TABLE user_stats(
        userId TEXT PRIMARY KEY,
        totalAnalyses INTEGER DEFAULT 0,
        healthyCount INTEGER DEFAULT 0,
        manchaNegraCount INTEGER DEFAULT 0,
        ronaCount INTEGER DEFAULT 0,
        lastUpdated TEXT NOT NULL
      )
    ''');
  }

  // Detection operations
  Future<int> insertDetection(Map<String, dynamic> detection) async {
    final db = await database;
    return await db.insert('detections', detection);
  }

  Future<List<Map<String, dynamic>>> getDetections(String userId, {int? limit}) async {
    final db = await database;
    return await db.query(
      'detections',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<int> deleteDetection(String id) async {
    final db = await database;
    return await db.delete('detections', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedDetections(String userId) async {
    final db = await database;
    return await db.query(
      'detections',
      where: 'userId = ? AND synced = 0',
      whereArgs: [userId],
    );
  }

  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'detections',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User stats operations
  Future<void> updateUserStats(String userId, String disease) async {
    final db = await database;
    
    final stats = await db.query(
      'user_stats',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (stats.isEmpty) {
      await db.insert('user_stats', {
        'userId': userId,
        'totalAnalyses': 1,
        'healthyCount': disease == 'healthy' ? 1 : 0,
        'manchaNegraCount': disease == 'manchaNegra' ? 1 : 0,
        'ronaCount': disease == 'rona' ? 1 : 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } else {
      final current = stats.first;
      await db.update(
        'user_stats',
        {
          'totalAnalyses': (current['totalAnalyses'] as int) + 1,
          'healthyCount': (current['healthyCount'] as int) + (disease == 'healthy' ? 1 : 0),
          'manchaNegraCount': (current['manchaNegraCount'] as int) + (disease == 'manchaNegra' ? 1 : 0),
          'ronaCount': (current['ronaCount'] as int) + (disease == 'rona' ? 1 : 0),
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'userId = ?',
        whereArgs: [userId],
      );
    }
  }

  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    final db = await database;
    final stats = await db.query(
      'user_stats',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return stats.isNotEmpty ? stats.first : null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('detections');
    await db.delete('user_stats');
    await db.delete('workspaces');
    await db.delete('users');
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final db = await database;
    final users = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return users.isNotEmpty ? users.first : null;
  }

  Future<int> updateUser(String userId, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update('users', updates, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> deleteUser(String userId) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  // Workspace operations
  Future<int> insertWorkspace(Map<String, dynamic> workspace) async {
    final db = await database;
    return await db.insert('workspaces', workspace);
  }

  Future<List<Map<String, dynamic>>> getWorkspaces(String userId) async {
    final db = await database;
    return await db.query(
      'workspaces',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getWorkspace(String workspaceId) async {
    final db = await database;
    final workspaces = await db.query(
      'workspaces',
      where: 'id = ?',
      whereArgs: [workspaceId],
    );
    return workspaces.isNotEmpty ? workspaces.first : null;
  }

  Future<int> updateWorkspace(String workspaceId, Map<String, dynamic> updates) async {
    final db = await database;
    return await db.update('workspaces', updates, where: 'id = ?', whereArgs: [workspaceId]);
  }

  Future<int> deleteWorkspace(String workspaceId) async {
    final db = await database;
    return await db.delete('workspaces', where: 'id = ?', whereArgs: [workspaceId]);
  }
}
