// lib/models/models.dart
import 'dart:convert';

class AppMember {
  final String id;
  final String name;

  AppMember({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory AppMember.fromJson(Map<String, dynamic> j) =>
      AppMember(id: j['id'], name: j['name']);
}

class ExpenseParticipant {
  final String memberId;
  double share;

  ExpenseParticipant({required this.memberId, required this.share});

  Map<String, dynamic> toJson() => {'memberId': memberId, 'share': share};
  factory ExpenseParticipant.fromJson(Map<String, dynamic> j) =>
      ExpenseParticipant(memberId: j['memberId'], share: (j['share'] as num).toDouble());
}

class Expense {
  final String id;
  String description;
  double amount;
  String payerId;
  List<ExpenseParticipant> participants;
  DateTime date;
  String? category;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.participants,
    required this.date,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'payerId': payerId,
        'participants': participants.map((p) => p.toJson()).toList(),
        'date': date.toIso8601String(),
        'category': category,
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'],
        description: j['description'],
        amount: (j['amount'] as num).toDouble(),
        payerId: j['payerId'],
        participants: (j['participants'] as List)
            .map((p) => ExpenseParticipant.fromJson(p))
            .toList(),
        date: DateTime.parse(j['date']),
        category: j['category'],
      );
}

class Group {
  final String id;
  String name;
  List<AppMember> members;
  List<Expense> expenses;
  DateTime createdAt;
  String emoji;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.expenses,
    required this.createdAt,
    this.emoji = '👥',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members.map((m) => m.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'emoji': emoji,
      };

  factory Group.fromJson(Map<String, dynamic> j) => Group(
        id: j['id'],
        name: j['name'],
        members: (j['members'] as List).map((m) => AppMember.fromJson(m)).toList(),
        expenses: (j['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
        createdAt: DateTime.parse(j['createdAt']),
        emoji: j['emoji'] ?? '👥',
      );

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);

  /// Returns net balance per member (positive = owed money, negative = owes money)
  Map<String, double> get balances {
    final Map<String, double> bal = {for (var m in members) m.id: 0.0};
    for (final exp in expenses) {
      // Payer gets credited
      bal[exp.payerId] = (bal[exp.payerId] ?? 0) + exp.amount;
      // Each participant is debited their share
      for (final p in exp.participants) {
        bal[p.memberId] = (bal[p.memberId] ?? 0) - p.share;
      }
    }
    return bal;
  }

  /// Returns list of settlement instructions: {from, to, amount}
  List<Map<String, dynamic>> get settlements {
    final bal = Map<String, double>.from(balances);
    final List<Map<String, dynamic>> result = [];

    final creditors = bal.entries.where((e) => e.value > 0.01).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debtors = bal.entries.where((e) => e.value < -0.01).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    int i = 0, j = 0;
    final cList = creditors.map((e) => [e.key, e.value]).toList();
    final dList = debtors.map((e) => [e.key, e.value.abs()]).toList();

    while (i < cList.length && j < dList.length) {
      final amount = (cList[i][1] as double) < (dList[j][1] as double)
          ? cList[i][1] as double
          : dList[j][1] as double;
      result.add({'from': dList[j][0], 'to': cList[i][0], 'amount': amount});
      cList[i] = [cList[i][0], (cList[i][1] as double) - amount];
      dList[j] = [dList[j][0], (dList[j][1] as double) - amount];
      if ((cList[i][1] as double) < 0.01) i++;
      if ((dList[j][1] as double) < 0.01) j++;
    }
    return result;
  }

  AppMember? getMember(String id) {
    try { return members.firstWhere((m) => m.id == id); } catch (_) { return null; }
  }
}

class AppSettings {
  bool isDarkMode;
  String currency;

  AppSettings({this.isDarkMode = true, this.currency = 'USD \$'});

  Map<String, dynamic> toJson() => {'isDarkMode': isDarkMode, 'currency': currency};
  factory AppSettings.fromJson(Map<String, dynamic> j) =>
      AppSettings(isDarkMode: j['isDarkMode'] ?? true, currency: j['currency'] ?? 'USD \$');
}
