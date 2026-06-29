import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/detection_result.dart';
import '../models/workspace.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('avoscan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Create Workspaces table
    await db.execute('''
      CREATE TABLE workspaces (
        id $textType,
        name $textType,
        description $textTypeNullable,
        createdAt $textType,
        updatedAt $textType,
        isActive $intType,
        PRIMARY KEY (id)
      )
    ''');

    // Create DetectionResults table
    await db.execute('''
      CREATE TABLE detection_results (
        id $idType,
        diseaseType $textType,
        confidence $realType,
        imagePath $textType,
        timestamp $textType,
        workspaceId $textTypeNullable,
        notes $textTypeNullable,
        FOREIGN KEY (workspaceId) REFERENCES workspaces (id)
      )
    ''');

    // Create default workspace
    await db.insert('workspaces', {
      'id': 'default',
      'name': 'Mi Huerto',
      'description': 'Espacio de trabajo predeterminado',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': 1,
    });

    // Create conversation tables (added in version 2)
    await _createConversationTables(db);
  }

  Future<void> _createConversationTables(Database db) async {
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        detectionKey TEXT,
        contextJson TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE conversation_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversationId INTEGER NOT NULL,
        role TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (conversationId) REFERENCES conversations (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await _createConversationTables(db);
    }
  }

  // === WORKSPACE OPERATIONS ===
  
  Future<Workspace> createWorkspace(Workspace workspace) async {
    final db = await instance.database;
    await db.insert('workspaces', workspace.toMap());
    return workspace;
  }

  Future<List<Workspace>> getAllWorkspaces() async {
    final db = await instance.database;
    final result = await db.query(
      'workspaces',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Workspace.fromMap(map)).toList();
  }

  Future<Workspace?> getWorkspace(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'workspaces',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Workspace.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateWorkspace(Workspace workspace) async {
    final db = await instance.database;
    return db.update(
      'workspaces',
      workspace.toMap(),
      where: 'id = ?',
      whereArgs: [workspace.id],
    );
  }

  Future<int> deleteWorkspace(String id) async {
    final db = await instance.database;
    
    // Delete all detection results for this workspace
    await db.delete(
      'detection_results',
      where: 'workspaceId = ?',
      whereArgs: [id],
    );
    
    // Delete the workspace
    return await db.delete(
      'workspaces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // === DETECTION RESULT OPERATIONS ===

  Future<DetectionResult> createDetectionResult(DetectionResult result) async {
    final db = await instance.database;
    final id = await db.insert('detection_results', result.toMap());
    return result.copyWith(id: id);
  }

  Future<List<DetectionResult>> getAllDetectionResults({String? workspaceId}) async {
    final db = await instance.database;
    
    List<Map<String, dynamic>> maps;
    
    if (workspaceId != null) {
      maps = await db.query(
        'detection_results',
        where: 'workspaceId = ?',
        whereArgs: [workspaceId],
        orderBy: 'timestamp DESC',
      );
    } else {
      maps = await db.query(
        'detection_results',
        orderBy: 'timestamp DESC',
      );
    }
    
    return maps.map((map) => DetectionResult.fromMap(map)).toList();
  }

  Future<DetectionResult?> getDetectionResult(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'detection_results',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DetectionResult.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDetectionResult(DetectionResult result) async {
    final db = await instance.database;
    return db.update(
      'detection_results',
      result.toMap(),
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  Future<int> deleteDetectionResult(int id) async {
    final db = await instance.database;
    return await db.delete(
      'detection_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllDetectionResults() async {
    final db = await instance.database;
    return await db.delete('detection_results');
  }

  // === STATISTICS ===

  Future<Map<String, int>> getStatistics({String? workspaceId}) async {
    final db = await instance.database;
    
    String whereClause = workspaceId != null ? 'WHERE workspaceId = ?' : '';
    List<dynamic> whereArgs = workspaceId != null ? [workspaceId] : [];
    
    final result = await db.rawQuery('''
      SELECT 
        diseaseType,
        COUNT(*) as count
      FROM detection_results
      $whereClause
      GROUP BY diseaseType
    ''', whereArgs);

    Map<String, int> statistics = {
      'healthy': 0,
      'mancha_negra': 0,
      'rona': 0,
    };

    for (var row in result) {
      statistics[row['diseaseType'] as String] = row['count'] as int;
    }

    return statistics;
  }

  Future<List<Map<String, dynamic>>> getDetectionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? workspaceId,
  }) async {
    final db = await instance.database;
    
    String whereClause = 'timestamp BETWEEN ? AND ?';
    List<dynamic> whereArgs = [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ];
    
    if (workspaceId != null) {
      whereClause += ' AND workspaceId = ?';
      whereArgs.add(workspaceId);
    }
    
    final maps = await db.query(
      'detection_results',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    
    return maps;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
