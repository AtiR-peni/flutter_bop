import 'package:flutter/material.dart';

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
  final List<Map<String, dynamic>> _entries = [];
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _selectedTag = 'パチンコ';
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  void _addEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _entries.add({
          'date': _selectedDate,
          'tag': _selectedTag,
          'amount': double.parse(_amountController.text),
          'memo': _memoController.text,
        });
      });
      _amountController.clear();
      _memoController.clear();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2024, 12, 31),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('収支表アプリ'),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: '金額'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '金額を入力してください';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedTag,
                    items: ['パチンコ', 'スロット', '競馬', '競艇', '麻雀']
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
                    decoration: InputDecoration(labelText: 'タグ'),
                  ),
                  TextFormField(
                    controller: _memoController,
                    decoration: InputDecoration(labelText: 'メモ'),
                  ),
                  Row(
                    children: [
                      Text(
                        "${_selectedDate.toLocal()}".split(' ')[0],
                      ),
                      IconButton(
                        onPressed: () => _selectDate(context),
                        icon: Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _addEntry,
                    child: Text('追加'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return ListTile(
                  title:
                      Text("${entry['date'].toLocal()} - ${entry['amount']}円"),
                  subtitle: Text("${entry['tag']} - ${entry['memo']}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
