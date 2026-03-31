// lib/providers/app_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';

class AppProvider extends ChangeNotifier {
  final DataService _ds = DataService.instance;

  List<Group> get groups => _ds.groups;
  AppSettings get settings => _ds.settings;
  bool get isDark => _ds.settings.isDarkMode;
  String get currency => _ds.settings.currency;

  Future<void> init() async {
    await _ds.init();
    notifyListeners();
  }

  Future<void> addGroup(Group g) async {
    await _ds.addGroup(g);
    notifyListeners();
  }

  Future<void> updateGroup(Group g) async {
    await _ds.updateGroup(g);
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    await _ds.deleteGroup(id);
    notifyListeners();
  }

  Future<void> addExpense(String groupId, Expense expense) async {
    await _ds.addExpense(groupId, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String groupId, String expenseId) async {
    await _ds.deleteExpense(groupId, expenseId);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final s = AppSettings(isDarkMode: !settings.isDarkMode, currency: settings.currency);
    await _ds.updateSettings(s);
    notifyListeners();
  }

  Future<void> setCurrency(String c) async {
    final s = AppSettings(isDarkMode: settings.isDarkMode, currency: c);
    await _ds.updateSettings(s);
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _ds.resetAll();
    notifyListeners();
  }

  Group? getGroup(String id) => _ds.getGroup(id);
}
