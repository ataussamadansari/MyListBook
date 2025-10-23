import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/item_model.dart';
import '../models/list_model.dart';

class ListsProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<GroceryList> _lists = [];
  List<ItemModel> _currentListItems = [];
  GroceryList? _currentList;

  List<GroceryList> get lists => _lists;
  List<ItemModel> get currentListItems => _currentListItems;
  GroceryList? get currentList => _currentList;

  // ✅ Get total cost for a specific list
  Future<double> getListTotalCost(int listId) async {
    final items = await _databaseHelper.getItemsByListId(listId);
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // ✅ Get total cost for multiple lists
  Future<double> getTotalCostForLists(List<GroceryList> lists) async {
    double totalCost = 0.0;
    for (final list in lists) {
      if (list.id != null) {
        totalCost += await getListTotalCost(list.id!);
      }
    }
    return totalCost;
  }

  // ✅ Get total cost for filtered lists (optimized)
  Future<double> getTotalCostForFilteredLists(
    List<GroceryList> filteredLists,
  ) async {
    return await getTotalCostForLists(filteredLists);
  }

  // ... आपका existing code बाकी रहने दें ...
  Future<void> loadLists() async {
    _lists = await _databaseHelper.getLists();
    notifyListeners();
  }

  Future<void> createList(GroceryList list) async {
    await _databaseHelper.insertList(list);
    await loadLists();
  }

  Future<void> updateList(GroceryList list) async {
    await _databaseHelper.updateList(list);
    await loadLists();
  }

  Future<void> deleteList(int id) async {
    await _databaseHelper.deleteList(id);
    await loadLists();
    if (_currentList?.id == id) {
      _currentList = null;
      _currentListItems = [];
    }
  }

  Future<void> setCurrentList(GroceryList? list) async {
    _currentList = list;
    if (list != null) {
      _currentListItems = await _databaseHelper.getItemsByListId(list.id!);
    } else {
      _currentListItems = [];
    }
    notifyListeners();
  }

  Future<void> loadCurrentListItems() async {
    if (_currentList != null) {
      _currentListItems = await _databaseHelper.getItemsByListId(
        _currentList!.id!,
      );
      notifyListeners();
    }
  }

  Future<void> addItemToCurrentList(ItemModel item) async {
    if (_currentList != null) {
      await _databaseHelper.insertItem(item);
      await loadCurrentListItems();
      // Update list's updatedAt timestamp
      if (_currentList != null) {
        final updatedList = _currentList!.copyWith();
        await _databaseHelper.updateList(updatedList);
        await loadLists();
      }
    }
  }

  Future<void> updateItem(ItemModel item) async {
    await _databaseHelper.updateItem(item);
    await loadCurrentListItems();
    // Update list's updatedAt timestamp
    if (_currentList != null) {
      final updatedList = _currentList!.copyWith();
      await _databaseHelper.updateList(updatedList);
      await loadLists();
    }
  }

  Future<void> deleteItem(int itemId) async {
    await _databaseHelper.deleteItem(itemId);
    await loadCurrentListItems();
  }

  Future<Map<String, dynamic>> getCurrentListStats() async {
    if (_currentList != null) {
      return await _databaseHelper.getListStats(_currentList!.id!);
    }
    return {
      'totalItems': 0,
      'completedItems': 0,
      'totalCost': 0.0,
      'completedCost': 0.0,
    };
  }
}

/*
import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/item_model.dart';
import '../models/list_model.dart';

class ListsProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<GroceryList> _lists = [];
  List<ItemModel> _currentListItems = [];
  GroceryList? _currentList;

  List<GroceryList> get lists => _lists;
  List<ItemModel> get currentListItems => _currentListItems;
  GroceryList? get currentList => _currentList;

  Future<void> loadLists() async {
    _lists = await _databaseHelper.getLists();
    notifyListeners();
  }

  Future<void> createList(GroceryList list) async {
    await _databaseHelper.insertList(list);
    await loadLists();
  }

  Future<void> updateList(GroceryList list) async {
    await _databaseHelper.updateList(list);
    await loadLists();
  }

  Future<void> deleteList(int id) async {
    await _databaseHelper.deleteList(id);
    await loadLists();
    if (_currentList?.id == id) {
      _currentList = null;
      _currentListItems = [];
    }
  }

  Future<void> setCurrentList(GroceryList? list) async {
    _currentList = list;
    if (list != null) {
      _currentListItems = await _databaseHelper.getItemsByListId(list.id!);
    } else {
      _currentListItems = [];
    }
    notifyListeners();
  }

  Future<void> loadCurrentListItems() async {
    if (_currentList != null) {
      _currentListItems = await _databaseHelper.getItemsByListId(
        _currentList!.id!,
      );
      notifyListeners();
    }
  }

  Future<void> addItemToCurrentList(ItemModel item) async {
    if (_currentList != null) {
      await _databaseHelper.insertItem(item);
      await loadCurrentListItems();
      // Update list's updatedAt timestamp
      if (_currentList != null) {
        final updatedList = _currentList!.copyWith();
        await _databaseHelper.updateList(updatedList);
        await loadLists();
      }
    }
  }

  Future<void> updateItem(ItemModel item) async {
    await _databaseHelper.updateItem(item);
    await loadCurrentListItems();
    // Update list's updatedAt timestamp
    if (_currentList != null) {
      final updatedList = _currentList!.copyWith();
      await _databaseHelper.updateList(updatedList);
      await loadLists();
    }
  }

  Future<void> deleteItem(int itemId) async {
    await _databaseHelper.deleteItem(itemId);
    await loadCurrentListItems();
  }

  Future<Map<String, dynamic>> getCurrentListStats() async {
    if (_currentList != null) {
      return await _databaseHelper.getListStats(_currentList!.id!);
    }
    return {
      'totalItems': 0,
      'completedItems': 0,
      'totalCost': 0.0,
      'completedCost': 0.0,
    };
  }
}
*/
