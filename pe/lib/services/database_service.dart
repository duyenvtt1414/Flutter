import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/expense_claim.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  static const _databaseName = 'expense_claims.db';
  static const _tableName = 'expense_claims';

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _databaseName);
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            claimTitle TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            userId TEXT NOT NULL,
            approve INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<ExpenseClaim>> claimsForStaff(String userId) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map(ExpenseClaim.fromMap).toList();
  }

  Future<List<ExpenseClaim>> allClaims() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'approve ASC, id DESC');
    return rows.map(ExpenseClaim.fromMap).toList();
  }

  Future<List<ExpenseClaim>> approvedClaims() async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'approve = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );
    return rows.map(ExpenseClaim.fromMap).toList();
  }

  Future<int> insertClaim(ExpenseClaim claim) async {
    final db = await database;
    return db.insert(_tableName, claim.toMap()..remove('id'));
  }

  Future<void> updateClaim(ExpenseClaim claim) async {
    final db = await database;
    await db.update(
      _tableName,
      claim.toMap()..remove('id'),
      where: 'id = ? AND userId = ? AND approve = 0',
      whereArgs: [claim.id, claim.userId],
    );
  }

  Future<void> deleteClaim(ExpenseClaim claim) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ? AND userId = ? AND approve = 0',
      whereArgs: [claim.id, claim.userId],
    );
  }

  Future<void> approveClaim(int id) async {
    final db = await database;
    await db.update(
      _tableName,
      {'approve': 1},
      where: 'id = ? AND approve = 0',
      whereArgs: [id],
    );
  }
}
