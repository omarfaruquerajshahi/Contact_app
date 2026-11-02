import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';

class DBHelper {
  static Database? _db;

  // Open the database (create it the first time)
  static Future<Database> get database async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'contacts.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE contacts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            address TEXT,
            isFavorite INTEGER DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  // CREATE
  static Future<int> insertContact(Contact contact) async {
    final db = await database;
    return db.insert('contacts', contact.toMap());
  }

  // READ (all, or filtered by name search / favorites)
  static Future<List<Contact>> getContacts({
    String search = '',
    bool onlyFavorites = false,
  }) async {
    final db = await database;
    String where = 'name LIKE ?';
    List<Object> args = ['%$search%'];
    if (onlyFavorites) {
      where += ' AND isFavorite = 1';
    }
    final maps = await db.query(
      'contacts',
      where: where,
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  // UPDATE
  static Future<int> updateContact(Contact contact) async {
    final db = await database;
    return db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // DELETE
  static Future<int> deleteContact(int id) async {
    final db = await database;
    return db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}
