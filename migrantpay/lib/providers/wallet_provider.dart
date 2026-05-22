import 'package:flutter/material.dart';
import 'dart:math';

enum TransactionType { sent, received, addedMoney, withdrawn }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String name;
  final String phoneOrUpi;
  final DateTime timestamp;
  final String status; // success, pending, failed
  final String blockchainHash;
  final String note;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.name,
    required this.phoneOrUpi,
    required this.timestamp,
    required this.status,
    required this.blockchainHash,
    this.note = '',
  });
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  double savedAmount;
  final DateTime deadline;
  final String emoji;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.deadline,
    required this.emoji,
  });

  double get progress => savedAmount / targetAmount;
}

class WalletProvider extends ChangeNotifier {
  double _balance = 12500.00;
  final List<Transaction> _transactions = [];
  final List<SavingsGoal> _goals = [];

  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<SavingsGoal> get goals => List.unmodifiable(_goals);

  WalletProvider() {
    _initSampleData();
  }

  void _initSampleData() {
    final rng = Random();
    final now = DateTime.now();

    // Sample transactions
    _transactions.addAll([
      Transaction(
        id: 'TXN${now.millisecondsSinceEpoch}01',
        type: TransactionType.received,
        amount: 5000,
        name: 'Employer - Site Office',
        phoneOrUpi: '9876543210',
        timestamp: now.subtract(const Duration(hours: 2)),
        status: 'success',
        blockchainHash: _generateHash(),
        note: 'Monthly salary',
      ),
      Transaction(
        id: 'TXN${now.millisecondsSinceEpoch}02',
        type: TransactionType.sent,
        amount: 3000,
        name: 'Sita Devi',
        phoneOrUpi: '9123456789',
        timestamp: now.subtract(const Duration(hours: 5)),
        status: 'success',
        blockchainHash: _generateHash(),
        note: 'Monthly family support',
      ),
      Transaction(
        id: 'TXN${now.millisecondsSinceEpoch}03',
        type: TransactionType.addedMoney,
        amount: 2000,
        name: 'Added via UPI',
        phoneOrUpi: 'ramesh@upi',
        timestamp: now.subtract(const Duration(days: 1)),
        status: 'success',
        blockchainHash: _generateHash(),
      ),
      Transaction(
        id: 'TXN${now.millisecondsSinceEpoch}04',
        type: TransactionType.sent,
        amount: 500,
        name: 'Mohan Kumar',
        phoneOrUpi: '9988776655',
        timestamp: now.subtract(const Duration(days: 2)),
        status: 'success',
        blockchainHash: _generateHash(),
      ),
      Transaction(
        id: 'TXN${now.millisecondsSinceEpoch}05',
        type: TransactionType.sent,
        amount: 1200,
        name: 'Sunita Sharma',
        phoneOrUpi: '9876123456',
        timestamp: now.subtract(const Duration(days: 3)),
        status: 'failed',
        blockchainHash: _generateHash(),
        note: 'Refunded automatically',
      ),
    ]);

    // Sample goals
    _goals.addAll([
      SavingsGoal(
        id: 'GOAL001',
        name: 'Emergency Fund',
        targetAmount: 10000,
        savedAmount: 3500,
        deadline: now.add(const Duration(days: 90)),
        emoji: '🛡️',
      ),
      SavingsGoal(
        id: 'GOAL002',
        name: 'Children\'s Education',
        targetAmount: 50000,
        savedAmount: 12000,
        deadline: now.add(const Duration(days: 365)),
        emoji: '📚',
      ),
      SavingsGoal(
        id: 'GOAL003',
        name: 'New Home',
        targetAmount: 200000,
        savedAmount: 35000,
        deadline: now.add(const Duration(days: 730)),
        emoji: '🏠',
      ),
    ]);
  }

  String _generateHash() {
    final rng = Random();
    const chars = '0123456789abcdef';
    return '0x${List.generate(64, (_) => chars[rng.nextInt(chars.length)]).join()}';
  }

  String _generateTxnId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<Transaction?> sendMoney({
    required String receiverName,
    required String receiverPhone,
    required double amount,
  }) async {
    if (amount > _balance) return null;
    await Future.delayed(const Duration(seconds: 2));

    final txn = Transaction(
      id: _generateTxnId(),
      type: TransactionType.sent,
      amount: amount,
      name: receiverName.isNotEmpty ? receiverName : 'Family Member',
      phoneOrUpi: receiverPhone,
      timestamp: DateTime.now(),
      status: 'success',
      blockchainHash: _generateHash(),
    );

    _balance -= amount;
    _transactions.insert(0, txn);
    notifyListeners();
    return txn;
  }

  Future<void> addMoney(double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    _balance += amount;
    _transactions.insert(
      0,
      Transaction(
        id: _generateTxnId(),
        type: TransactionType.addedMoney,
        amount: amount,
        name: 'Added via UPI',
        phoneOrUpi: 'wallet@upi',
        timestamp: DateTime.now(),
        status: 'success',
        blockchainHash: _generateHash(),
      ),
    );
    notifyListeners();
  }

  void addToGoal(String goalId, double amount) {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx != -1 && _balance >= amount) {
      _goals[idx].savedAmount += amount;
      _balance -= amount;
      notifyListeners();
    }
  }
}
