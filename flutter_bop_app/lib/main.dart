import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '収支表アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IncomeExpenseHomePage(),
    );
  }
}

class IncomeExpenseHomePage extends StatefulWidget {
  @override
  _IncomeExpenseHomePageState createState() => _IncomeExpenseHomePageState();
}

class _IncomeExpenseHomePageState extends State<IncomeExpenseHomePage> {
  final Map<DateTime, List<Map<String, dynamic>>> _entries = {};
  DateTime _selectedDate = DateTime.now();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  String _selectedTag = 'パチンコ';
  final _formKey = GlobalKey<FormState>();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<String> _tags = ['パチンコ', 'スロット', '競馬', '競艇', '麻雀'];

  void _addEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (_entries[_selectedDate] == null) {
          _entries[_selectedDate] = [];
        }
        _entries[_selectedDate]!.add({
          'amount': double.parse(_amountController.text),
          'tag': _selectedTag,
          'memo': _memoController.text,
        });
      });
      _amountController.clear();
      _memoController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('収支を追加'),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "選択された日付: ${_selectedDate.month}月${_selectedDate.day}日",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: '金額',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '金額を入力してください';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedTag,
                  items: _tags
                      .map((tag) => DropdownMenuItem(
                            value: tag,
                            child: Text(tag),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTag = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'タグ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _memoController,
                  decoration: InputDecoration(
                    labelText: 'メモ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: _addEntry,
            child: Text('追加'),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _entries[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('収支表アプリ'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2024, 12, 31),
            focusedDay: _selectedDate,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              _showAddEntryDialog();
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_selectedDate).length,
              itemBuilder: (context, index) {
                final entry = _getEventsForDay(_selectedDate)[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text("${entry['amount']}円"),
                    subtitle: Text("${entry['tag']} - ${entry['memo']}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
