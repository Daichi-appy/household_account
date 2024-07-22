import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models/expense.dart';
import 'expense_form_screen.dart';
import 'calendar_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      home: ExpenseListScreen(),
    );
  }
}

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> _expenses = [];
  final DBHelper _dbHelper = DBHelper();
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    final allRows = await _dbHelper.queryAllExpenses();
    setState(() {
      _expenses = allRows.map((row) => Expense.fromMap(row)).toList();
      _totalAmount = _expenses.fold(0.0, (sum, item) => sum + item.amount);
    });
  }

  void _addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense.toMap());
    _fetchExpenses();
  }

  void _updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense.toMap());
    _fetchExpenses();
  }

  void _deleteExpense(int id) async {
    await _dbHelper.deleteExpense(id);
    _fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('家計簿'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '合計金額: \$$_totalAmount',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? Center(child: Text('データがありません'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return ListTile(
                        title: Text(expense.title),
                        subtitle: Text('\$${expense.amount} - ${expense.date}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ExpenseFormScreen(expense: expense),
                                  ),
                                );
                                if (result != null) {
                                  _updateExpense(result);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteExpense(expense.id!),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseFormScreen(),
            ),
          );
          if (result != null) {
            _addExpense(result);
          }
        },
      ),
    );
  }
}
