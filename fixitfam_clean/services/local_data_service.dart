import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

/// Local data storage service for offline functionality
class LocalDataService {
  static const String _expensesKey = 'expenses';
  static const String _tasksKey = 'tasks';
  static const String _documentsKey = 'documents';
  static const String _tripsKey = 'trips';
  static const String _healthRecordsKey = 'health_records';
  static const String _budgetKey = 'budget_data';
  static const String _familyMembersKey = 'family_members';

  // Singleton pattern
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  static LocalDataService get instance => _instance;

  // Generate unique IDs
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(9999).toString().padLeft(4, '0');
  }

  // EXPENSE MANAGEMENT
  Future<List<Expense>> getExpenses(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString('${_expensesKey}_$userId') ?? '[]';
    final List<dynamic> expensesList = json.decode(expensesJson);
    return expensesList.map((e) => Expense.fromJson(e)).toList();
  }

  Future<void> saveExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses(expense.userId);
    
    // Check if expense already exists (update) or is new (add)
    final existingIndex = expenses.indexWhere((e) => e.id == expense.id);
    if (existingIndex != -1) {
      expenses[existingIndex] = expense;
    } else {
      expenses.add(expense);
    }
    
    final expensesJson = json.encode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString('${_expensesKey}_${expense.userId}', expensesJson);
  }

  Future<Expense> createExpense({
    required String userId,
    required String title,
    required double amount,
    required String category,
    String? description,
    DateTime? date,
  }) async {
    final expense = Expense(
      id: _generateId(),
      userId: userId,
      title: title,
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      description: description,
    );
    
    await saveExpense(expense);
    return expense;
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses(userId);
    expenses.removeWhere((e) => e.id == expenseId);
    
    final expensesJson = json.encode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString('${_expensesKey}_$userId', expensesJson);
  }

  // TASK MANAGEMENT
  Future<List<Task>> getTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('${_tasksKey}_$userId') ?? '[]';
    final List<dynamic> tasksList = json.decode(tasksJson);
    return tasksList.map((t) => Task.fromJson(t)).toList();
  }

  Future<void> saveTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks(task.userId);
    
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);
    if (existingIndex != -1) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }
    
    final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('${_tasksKey}_${task.userId}', tasksJson);
  }

  Future<Task> createTask({
    required String userId,
    required String title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    String priority = 'medium',
    String category = 'general',
  }) async {
    final task = Task(
      id: _generateId(),
      userId: userId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      dueDate: dueDate,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
    );
    
    await saveTask(task);
    return task;
  }

  Future<void> toggleTaskCompletion(String userId, String taskId) async {
    final tasks = await getTasks(userId);
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      final updatedTask = Task(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        assignedTo: task.assignedTo,
        dueDate: task.dueDate,
        isCompleted: !task.isCompleted,
        priority: task.priority,
        category: task.category,
        createdAt: task.createdAt,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      
      await saveTask(updatedTask);
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks(userId);
    tasks.removeWhere((t) => t.id == taskId);
    
    final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('${_tasksKey}_$userId', tasksJson);
  }

  // DOCUMENT MANAGEMENT
  Future<List<Document>> getDocuments(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString('${_documentsKey}_$userId') ?? '[]';
    final List<dynamic> documentsList = json.decode(documentsJson);
    return documentsList.map((d) => Document.fromJson(d)).toList();
  }

  Future<void> saveDocument(Document document) async {
    final prefs = await SharedPreferences.getInstance();
    final documents = await getDocuments(document.userId);
    
    final existingIndex = documents.indexWhere((d) => d.id == document.id);
    if (existingIndex != -1) {
      documents[existingIndex] = document;
    } else {
      documents.add(document);
    }
    
    final documentsJson = json.encode(documents.map((d) => d.toJson()).toList());
    await prefs.setString('${_documentsKey}_${document.userId}', documentsJson);
  }

  Future<Document> createDocument({
    required String userId,
    required String name,
    required String category,
    String? description,
    String? filePath,
    int? fileSize,
    String? mimeType,
  }) async {
    final document = Document(
      id: _generateId(),
      userId: userId,
      name: name,
      category: category,
      description: description,
      filePath: filePath,
      fileSize: fileSize,
      mimeType: mimeType,
      uploadedAt: DateTime.now(),
    );
    
    await saveDocument(document);
    return document;
  }

  Future<void> deleteDocument(String userId, String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final documents = await getDocuments(userId);
    documents.removeWhere((d) => d.id == documentId);
    
    final documentsJson = json.encode(documents.map((d) => d.toJson()).toList());
    await prefs.setString('${_documentsKey}_$userId', documentsJson);
  }

  // TRIP MANAGEMENT
  Future<List<Trip>> getTrips(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getString('${_tripsKey}_$userId') ?? '[]';
    final List<dynamic> tripsList = json.decode(tripsJson);
    return tripsList.map((t) => Trip.fromJson(t)).toList();
  }

  Future<void> saveTrip(Trip trip) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await getTrips(trip.userId);
    
    final existingIndex = trips.indexWhere((t) => t.id == trip.id);
    if (existingIndex != -1) {
      trips[existingIndex] = trip;
    } else {
      trips.add(trip);
    }
    
    final tripsJson = json.encode(trips.map((t) => t.toJson()).toList());
    await prefs.setString('${_tripsKey}_${trip.userId}', tripsJson);
  }

  Future<Trip> createTrip({
    required String userId,
    required String title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
  }) async {
    final trip = Trip(
      id: _generateId(),
      userId: userId,
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      spent: 0.0,
    );
    
    await saveTrip(trip);
    return trip;
  }

  Future<void> deleteTrip(String userId, String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final trips = await getTrips(userId);
    trips.removeWhere((t) => t.id == tripId);
    
    final tripsJson = json.encode(trips.map((t) => t.toJson()).toList());
    await prefs.setString('${_tripsKey}_$userId', tripsJson);
  }

  // HEALTH RECORDS MANAGEMENT
  Future<List<HealthRecord>> getHealthRecords(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString('${_healthRecordsKey}_$userId') ?? '[]';
    final List<dynamic> recordsList = json.decode(recordsJson);
    return recordsList.map((r) => HealthRecord.fromJson(r)).toList();
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getHealthRecords(record.userId);
    
    final existingIndex = records.indexWhere((r) => r.id == record.id);
    if (existingIndex != -1) {
      records[existingIndex] = record;
    } else {
      records.add(record);
    }
    
    final recordsJson = json.encode(records.map((r) => r.toJson()).toList());
    await prefs.setString('${_healthRecordsKey}_${record.userId}', recordsJson);
  }

  Future<HealthRecord> createHealthRecord({
    required String userId,
    String? familyMember,
    required String type,
    required String title,
    String? description,
    DateTime? date,
    Map<String, dynamic>? data,
  }) async {
    final record = HealthRecord(
      id: _generateId(),
      userId: userId,
      familyMember: familyMember,
      type: type,
      title: title,
      description: description,
      date: date ?? DateTime.now(),
      data: data,
    );
    
    await saveHealthRecord(record);
    return record;
  }

  Future<void> deleteHealthRecord(String userId, String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getHealthRecords(userId);
    records.removeWhere((r) => r.id == recordId);
    
    final recordsJson = json.encode(records.map((r) => r.toJson()).toList());
    await prefs.setString('${_healthRecordsKey}_$userId', recordsJson);
  }

  Future<Map<String, dynamic>> getHealthAnalytics(String userId) async {
    final records = await getHealthRecords(userId);
    final now = DateTime.now();
    
    // Count by type
    final typeCount = <String, int>{};
    final monthlyCount = <String, int>{};
    final upcomingCount = records.where((r) => r.date.isAfter(now)).length;
    final thisMonthCount = records.where((r) => 
      r.date.month == now.month && r.date.year == now.year
    ).length;
    
    for (final record in records) {
      typeCount[record.type] = (typeCount[record.type] ?? 0) + 1;
      final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }
    
    return {
      'totalRecords': records.length,
      'typeBreakdown': typeCount,
      'monthlyTrend': monthlyCount,
      'upcomingAppointments': upcomingCount,
      'thisMonthRecords': thisMonthCount,
      'averagePerMonth': records.isEmpty ? 0 : records.length / 12,
    };
  }

  // BUDGET DATA
  Future<Map<String, dynamic>> getBudgetData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetJson = prefs.getString('${_budgetKey}_$userId') ?? '{}';
    return json.decode(budgetJson);
  }

  Future<void> saveBudgetData(String userId, Map<String, dynamic> budgetData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_budgetKey}_$userId', json.encode(budgetData));
  }

  // FAMILY MEMBERS
  Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = prefs.getString(_familyMembersKey) ?? '[]';
    return List<Map<String, dynamic>>.from(json.decode(membersJson));
  }

  Future<void> saveFamilyMembers(List<Map<String, dynamic>> members) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_familyMembersKey, json.encode(members));
  }

  // DATA ANALYTICS
  Future<Map<String, dynamic>> getExpenseAnalytics(String userId) async {
    final expenses = await getExpenses(userId);
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    
    final monthlyExpenses = expenses.where((e) => 
      e.date.isAfter(currentMonth) && e.date.isBefore(now)
    ).toList();
    
    double totalMonthly = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
    
    Map<String, double> categoryTotals = {};
    for (var expense in monthlyExpenses) {
      categoryTotals[expense.category] = 
        (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    
    return {
      'totalMonthly': totalMonthly,
      'categoryTotals': categoryTotals,
      'transactionCount': monthlyExpenses.length,
      'averageTransaction': monthlyExpenses.isEmpty ? 0.0 : totalMonthly / monthlyExpenses.length,
    };
  }

  Future<Map<String, dynamic>> getTaskAnalytics(String userId) async {
    final tasks = await getTasks(userId);
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = tasks.length - completed;
    final overdue = tasks.where((t) => 
      !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(DateTime.now())
    ).length;
    
    return {
      'total': tasks.length,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'completionRate': tasks.isEmpty ? 0.0 : (completed / tasks.length) * 100,
    };
  }

  // CLEAR ALL DATA (for logout/reset)
  Future<void> clearUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_expensesKey}_$userId');
    await prefs.remove('${_tasksKey}_$userId');
    await prefs.remove('${_documentsKey}_$userId');
    await prefs.remove('${_tripsKey}_$userId');
    await prefs.remove('${_healthRecordsKey}_$userId');
    await prefs.remove('${_budgetKey}_$userId');
  }

  // DEMO DATA SEEDING
  Future<void> seedDemoData(String userId) async {
    // Create some demo expenses
    await createExpense(
      userId: userId,
      title: 'Groceries - Walmart',
      amount: 127.50,
      category: 'Food & Groceries',
      description: 'Weekly grocery shopping',
      date: DateTime.now().subtract(const Duration(days: 2)),
    );
    
    await createExpense(
      userId: userId,
      title: 'Gas Station',
      amount: 45.00,
      category: 'Transportation',
      description: 'Fuel for car',
      date: DateTime.now().subtract(const Duration(days: 1)),
    );
    
    await createExpense(
      userId: userId,
      title: 'Netflix Subscription',
      amount: 15.99,
      category: 'Entertainment',
      description: 'Monthly streaming service',
      date: DateTime.now().subtract(const Duration(days: 3)),
    );

    // Create some demo tasks
    await createTask(
      userId: userId,
      title: 'Take out trash',
      description: 'Remember to put bins on curb by 7 AM',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: 'high',
      category: 'household',
    );
    
    await createTask(
      userId: userId,
      title: 'Buy birthday gift for Sarah',
      description: 'Her birthday is next week',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: 'medium',
      category: 'family',
    );
    
    await createTask(
      userId: userId,
      title: 'Schedule dentist appointment',
      description: 'For annual checkup',
      priority: 'low',
      category: 'health',
    );

    // Create a demo trip
    await createTrip(
      userId: userId,
      title: 'Summer Family Vacation',
      destination: 'Orlando, FL',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 37)),
      budget: 2500.0,
    );

    // Create a demo health record
    await createHealthRecord(
      userId: userId,
      type: 'checkup',
      title: 'Annual Physical',
      description: 'Regular health checkup',
      date: DateTime.now().subtract(const Duration(days: 30)),
      data: {
        'doctor': 'Dr. Smith',
        'notes': 'All vitals normal',
        'nextAppointment': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      },
    );

    // Set budget data
    await saveBudgetData(userId, {
      'monthlyIncome': 85000.0,
      'monthlyBudget': 70000.0,
      'categories': {
        'Food & Groceries': 15000.0,
        'Transportation': 8000.0,
        'Entertainment': 5000.0,
        'Utilities': 4000.0,
        'Healthcare': 3000.0,
        'Miscellaneous': 35000.0,
      },
      'savingsGoal': 15000.0,
    });
  }
}
