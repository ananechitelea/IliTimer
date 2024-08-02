import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Box App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ComicSans',  // Default font
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              alignment: Alignment.center,
              child: Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              color: Colors.blue[100],  // Background color for the header
              width: double.infinity
            ),
            SizedBox(height: 16.0),  // Space between header and calendar
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,  // 7 columns for days of the week
                  childAspectRatio: 1.0,  // Square shape
                ),
                itemCount: daysInMonth,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isToday = day == _currentDay;
                  final isPast = day < _currentDay;
                  final isFuture = day > _currentDay;

                  // Determine image asset based on the button state
                  String imagePath;
                  if (isToday) {
                    imagePath = 'assets/images/today.jpeg';  // Image for the current day
                  } else if (isPast) {
                    imagePath = 'assets/images/outdated.png';  // Image for past days
                  } else {
                    imagePath = 'assets/images/locked.jpg';  // Image for future days
                  }

                  return Container(
                    margin: EdgeInsets.all(4.0),  // Add margin between squares
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,  // Invisible background
                            ),
                            child: Text(
                              '$day',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'ComicSans',  // Comic Sans font
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,  // Background color of the button
                              shadowColor: Colors.transparent,  // Remove shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,  // Square corners
                              ),
                            ),
                            child: null,  // No text or child on the button
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
