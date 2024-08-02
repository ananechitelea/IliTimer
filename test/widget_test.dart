import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Box App',
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Define the primarySwatch for theming
      ),
      home: TimerScreen(),
    );
  }
}

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _currentDay = DateTime.now().day;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _loadStartDate();
  }

  Future<void> _loadStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateStr = prefs.getString('start_date');
    if (startDateStr == null) {
      _startDate = DateTime.now().subtract(Duration(days: DateTime.now().day - 1)); // Set start date to the beginning of the month
      prefs.setString('start_date', _startDate.toIso8601String());
    } else {
      _startDate = DateTime.parse(startDateStr);
    }
    setState(() {});  // Trigger a rebuild to reflect the start date
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_startDate.year, _startDate.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(title: Text('Calendar Box App')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
        ),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final dayDate = DateTime(_startDate.year, _startDate.month, day);

          return ElevatedButton(
            onPressed: () {
              if (day <= _currentDay) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Box $day'),
                    content: Text('Hello!'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text(
              day <= _currentDay
                  ? (day == _currentDay ? 'Today' : 'X')  // Mark as X for past days
                  : 'Locked',  // Indicate locked for future days
              style: TextStyle(
                color: day <= _currentDay
                    ? Colors.black
                    : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: day == _currentDay
                  ? Colors.green
                  : day < _currentDay
                      ? Colors.red
                      : Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
