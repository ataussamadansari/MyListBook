import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item_model.dart';
import '../models/list_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'grocery_book.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Grocery Lists table
    await db.execute('''
      CREATE TABLE grocery_lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Items table
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listId INTEGER NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        quantity REAL NOT NULL,
        unit INTEGER NOT NULL,
        status INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (listId) REFERENCES grocery_lists (id) ON DELETE CASCADE
      )
    ''');
  }

  // GroceryList operations
  Future<int> insertList(GroceryList list) async {
    final db = await database;
    return await db.insert('grocery_lists', list.toMap());
  }

  Future<List<GroceryList>> getLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grocery_lists',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => GroceryList.fromMap(maps[i]));
  }

  Future<GroceryList?> getList(int id) async {
    final db = await database;
    final maps = await db.query(
      'grocery_lists',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return GroceryList.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateList(GroceryList list) async {
    final db = await database;
    return await db.update(
      'grocery_lists',
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  Future<int> deleteList(int id) async {
    final db = await database;
    // Delete associated items first
    await db.delete('items', where: 'listId = ?', whereArgs: [id]);
    return await db.delete('grocery_lists', where: 'id = ?', whereArgs: [id]);
  }

  // ItemModel operations
  Future<int> insertItem(ItemModel item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<ItemModel>> getItemsByListId(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'listId = ?',
      whereArgs: [listId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => ItemModel.fromMap(maps[i]));
  }

  Future<int> updateItem(ItemModel item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteItemsByListId(int listId) async {
    final db = await database;
    return await db.delete('items', where: 'listId = ?', whereArgs: [listId]);
  }

  // Statistics
  Future<Map<String, dynamic>> getListStats(int listId) async {
    final items = await getItemsByListId(listId);

    final totalItems = items.length;
    final completedItems = items
        .where((item) => item.status == ItemStatus.complete)
        .length;
    final totalCost = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final completedCost = items
        .where((item) => item.status == ItemStatus.complete)
        .fold(0.0, (sum, item) => sum + item.totalPrice);

    return {
      'totalItems': totalItems,
      'completedItems': completedItems,
      'totalCost': totalCost,
      'completedCost': completedCost,
    };
  }
}
