import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'db_helper.dart';
import 'models/expense.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Expense> _expenses = [];
  final DBHelper _dbHelper = DBHelper();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Expense> _selectedExpenses = [];
  double _monthlyTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    final allRows = await _dbHelper.queryAllExpenses();
    setState(() {
      _expenses = allRows.map((row) => Expense.fromMap(row)).toList();
      _selectedExpenses = _getExpensesForDay(_selectedDay);
      _monthlyTotal = _getMonthlyTotal(_focusedDay);
    });
  }

  List<Expense> _getExpensesForDay(DateTime day) {
    return _expenses.where((expense) => isSameDay(DateTime.parse(expense.date), day)).toList();
  }

  double _getMonthlyTotal(DateTime month) {
    return _expenses
        .where((expense) =>
            DateTime.parse(expense.date).year == month.year &&
            DateTime.parse(expense.date).month == month.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total for ${_focusedDay.year}-${_focusedDay.month}: \$$_monthlyTotal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2099, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedExpenses = _getExpensesForDay(selectedDay);
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _monthlyTotal = _getMonthlyTotal(focusedDay);
              });
            },
          ),
          Expanded(
            child: _selectedExpenses.isEmpty
                ? Center(child: Text('No expenses for selected day.'))
                : ListView.builder(
                    itemCount: _selectedExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _selectedExpenses[index];
                      return ListTile(
                        title: Text(expense.title),
                        subtitle: Text('\$${expense.amount} - ${expense.date}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
