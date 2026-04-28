// lib/services/data_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class DataService {
  static const _groupsKey = 'groups_v1';
  static const _settingsKey = 'settings_v1';

  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();
  DataService._();

  List<Group> _groups = [];
  AppSettings _settings = AppSettings();

  List<Group> get groups => _groups;
  AppSettings get settings => _settings;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = prefs.getString(_groupsKey);
    if (groupsJson != null) {
      final list = jsonDecode(groupsJson) as List;
      _groups = list.map((g) => Group.fromJson(g)).toList();
    }
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      _settings = AppSettings.fromJson(jsonDecode(settingsJson));
    }
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_groups.map((g) => g.toJson()).toList());
    await prefs.setString(_groupsKey, json);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
  }

  Future<void> addGroup(Group g) async {
    _groups.insert(0, g);
    await _saveGroups();
  }

  Future<void> updateGroup(Group g) async {
    final idx = _groups.indexWhere((x) => x.id == g.id);
    if (idx != -1) { _groups[idx] = g; await _saveGroups(); }
  }

  Future<void> deleteGroup(String id) async {
    _groups.removeWhere((g) => g.id == id);
    await _saveGroups();
  }

  Future<void> addExpense(String groupId, Expense expense) async {
    final g = _groups.firstWhere((x) => x.id == groupId);
    g.expenses.insert(0, expense);
    await _saveGroups();
  }

  Future<void> deleteExpense(String groupId, String expenseId) async {
    final g = _groups.firstWhere((x) => x.id == groupId);
    g.expenses.removeWhere((e) => e.id == expenseId);
    await _saveGroups();
  }

  Future<void> updateSettings(AppSettings s) async {
    _settings = s;
    await _saveSettings();
  }

  Future<void> resetAll() async {
    _groups = [];
    _settings = AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Group? getGroup(String id) {
    try { return _groups.firstWhere((g) => g.id == id); } catch (_) { return null; }
  }
}
