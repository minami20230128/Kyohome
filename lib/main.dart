import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TextEditingController _praiseController = TextEditingController();
  TextEditingController _personController = TextEditingController();

  // 褒められたこと、誰から、そして自覚のある選択肢
  String? _selectedPerson;
  String? _selectedAwareness;
  List<String> _persons = []; // 誰からのリスト（ユーザーが追加可能）
  Map<DateTime, List<Map<String, String>>> _praises = {}; // 褒められたことを保存

  // 自覚があるかないかの選択肢
  final List<String> _awarenessOptions = ['ある', 'ない'];

  // 褒められたことの登録処理
  void _addPraise() {
    if (_praiseController.text.isNotEmpty && _selectedPerson != null && _selectedAwareness != null) {
      setState(() {
        // 選択された日付に褒められたことを保存
        if (_praises[_selectedDay] == null) {
          _praises[_selectedDay] = [];
        }

        _praises[_selectedDay]!.add({
          'praise': _praiseController.text,
          'person': _selectedPerson!,
          'awareness': _selectedAwareness!,
        });

        // 入力欄をクリア
        _praiseController.clear();
        _personController.clear();
        _selectedPerson = null;
        _selectedAwareness = null;
      });

      Navigator.pop(context); // ダイアログを閉じる
    }
  }

  // 褒められたことのリストを表示
  Widget _buildPraiseList() {
    List<Map<String, String>> praises = _praises[_selectedDay] ?? [];
    return ListView.builder(
      itemCount: praises.length,
      itemBuilder: (context, index) {
        var praise = praises[index];
        return ListTile(
          title: Text(praise['praise']!),
          subtitle: Text('誰から: ${praise['person']} - 自覚がある？: ${praise['awareness']}'),
        );
      },
    );
  }

  // 褒められたことを入力するダイアログ
  void _showPraiseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('今日褒められたことを登録'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 褒められたこと
              TextField(
                controller: _praiseController,
                decoration: InputDecoration(
                  hintText: '褒められたことを入力',
                ),
              ),
              // 誰から？
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedPerson,
                hint: Text('誰から褒められましたか？'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPerson = newValue;
                  });
                },
                items: _persons.map<DropdownMenuItem<String>>((String person) {
                  return DropdownMenuItem<String>(
                    value: person,
                    child: Text(person),
                  );
                }).toList()
              ),
              // 新しい名前を追加するボタン
              TextButton(
                onPressed: () {
                  _showAddPersonDialog(context);
                },
                child: Text('名前を追加'),
              ),
              // 自覚があるか？
              Row(
                children: _awarenessOptions.map((option) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedAwareness,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedAwareness = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('保存'),
              onPressed: _addPraise,
            ),
          ],
        );
      },
    );
  }

  // 新しい「誰から？」の名前を追加するダイアログ
  void _showAddPersonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新しい名前を追加'),
          content: TextField(
            controller: _personController,
            decoration: InputDecoration(
              hintText: '名前を入力',
            ),
          ),
          actions: [
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('追加'),
              onPressed: () {
                if (_personController.text.isNotEmpty) {
                  setState(() {
                    _persons.add(_personController.text);
                    _selectedPerson = _personController.text;
                    _personController.clear();
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('褒められたことカレンダー'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // カレンダー
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showPraiseDialog(context); // 褒められたことの入力ダイアログを表示
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            SizedBox(height: 10),
            // 褒められたことリスト
            Expanded(child: _buildPraiseList()),
          ],
        ),
      ),
    );
  }
}
