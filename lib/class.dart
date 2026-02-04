import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const Color kPrimaryGold = Color.fromARGB(255, 161, 134, 2);
const Color kCardOrange = Color.fromARGB(255, 231, 126, 64);


void main() {
  runApp(const Class_schedule());
}

class Class_schedule extends StatelessWidget {
  const Class_schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InputScreen(),
    );
  }
}

class ClassEntry {
  final TimeOfDay start;
  final TimeOfDay end;
  final String subject;
  final String professor;

  ClassEntry({
    required this.start,
    required this.end,
    required this.subject,
    required this.professor,
  });

  // 🔹 SAVE ke liye
  Map<String, dynamic> toJson() => {
        'startH': start.hour,
        'startM': start.minute,
        'endH': end.hour,
        'endM': end.minute,
        'subject': subject,
        'professor': professor,
      };

  // 🔹 LOAD ke liye
  factory ClassEntry.fromJson(Map<String, dynamic> json) {
    return ClassEntry(
      start: TimeOfDay(
        hour: json['startH'],
        minute: json['startM'],
      ),
      end: TimeOfDay(
        hour: json['endH'],
        minute: json['endM'],
      ),
      subject: json['subject'],
      professor: json['professor'],
    );
  }
}


class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final Map<String, List<ClassEntry>> timetable = {};
  bool isLoading = true;


  String selectedDay = 'Monday';
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final subjectController = TextEditingController();
  final professorController = TextEditingController();

  final days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  Future<void> loadTimetable() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('timetable');

  if (raw != null) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;

    timetable.clear(); 

    decoded.forEach((day, list) {
      timetable[day] = (list as List)
          .map((e) => ClassEntry.fromJson(e))
          .toList();
    });
  }

  setState(() {
    isLoading = false; 
  });
}



  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void addClass() {
  if (startTime == null ||
      endTime == null ||
      subjectController.text.isEmpty ||
      professorController.text.isEmpty) return;

  timetable.putIfAbsent(selectedDay, () => []);

  timetable[selectedDay]!.add(
    ClassEntry(
      start: startTime!,
      end: endTime!,
      subject: subjectController.text,
      professor: professorController.text,
    ),
  );

  saveTimetable(); 

  subjectController.clear();
  professorController.clear();
  startTime = null;
  endTime = null;

  setState(() {});
  }



  @override
  void initState() {
  super.initState();
  loadTimetable(); 
  }



  @override
  Widget build(BuildContext context) {
  if (isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryGold,
        automaticallyImplyLeading: false,
        title: const Text(
          'Enter Timetable',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),


      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedDay,
              items: days
                  .map((d) =>
                      DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => selectedDay = v!),
            ),

            Row(
              children: [
                TextButton(
                  onPressed: () => pickTime(true),
                  child: Text(startTime == null
                      ? 'Start Time'
                      : startTime!.format(context)),
                ),
                TextButton(
                  onPressed: () => pickTime(false),
                  child: Text(endTime == null
                      ? 'End Time'
                      : endTime!.format(context)),
                ),
              ],
            ),

            TextField(
              controller: subjectController,
              decoration:
                  const InputDecoration(labelText: 'Subject + Credit'),
            ),
            TextField(
              controller: professorController,
              decoration:
                  const InputDecoration(labelText: 'Professor'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addClass,
              child: const Text('Add Class'),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DaySelectScreen(timetable),
                  ),
                );
              },
              child: const Text('DONE → ASK DAY'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveTimetable() async {
  final prefs = await SharedPreferences.getInstance();

  final data = timetable.map(
    (day, list) => MapEntry(
      day,
      list.map((c) => c.toJson()).toList(),
    ),
  );

  await prefs.setString('timetable', jsonEncode(data));
  Future<void> loadTimetable() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('timetable');

  if (raw == null) return;

  final decoded = jsonDecode(raw) as Map<String, dynamic>;

  decoded.forEach((day, list) {
    timetable[day] = (list as List)
        .map((e) => ClassEntry.fromJson(e))
        .toList();
  });

  setState(() {});
}

}

}

class DaySelectScreen extends StatefulWidget {
  final Map<String, List<ClassEntry>> timetable;

  const DaySelectScreen(this.timetable, {super.key});

  @override
  State<DaySelectScreen> createState() => _DaySelectScreenState();
}

class _DaySelectScreenState extends State<DaySelectScreen> {
  String selectedDay = 'Monday';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: kPrimaryGold,
        title: const Text(
          'Enter Timetable',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),



      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: selectedDay,
            items: [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday'
            ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => selectedDay = v!),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            child: const Text('SHOW TIMETABLE'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OutputScreen(
                    day: selectedDay,
                    classes: widget.timetable[selectedDay] ?? [],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // 🔥 DELETE DAY BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE FULL DAY'),
            onPressed: () => deleteDay(context),
          ),
        ],
      )

    );
  }
  Future<void> deleteDay(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Full Day?'),
        content: Text('Delete complete schedule of $selectedDay ?'),
        actions: [
          TextButton(
            child: const Text('DELETE'),
            onPressed: () async {
              widget.timetable.remove(selectedDay);

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                'timetable',
                jsonEncode(
                  widget.timetable.map(
                    (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
                  ),
                ),
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$selectedDay deleted')),
              );
            },
          ),
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class OutputScreen extends StatelessWidget {
  final String day;
  final List<ClassEntry> classes;

  const OutputScreen({
    super.key,
    required this.day,
    required this.classes,
  });

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryGold,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          '$day Timetable',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            
            buildHeaderRow(),

            const Divider(),

            
            ...buildTimeline(context),
          ],
        ),
      ),
    );
  }


  List<Widget> buildTimeline(BuildContext context) {
    List<Widget> rows = [];

    TimeOfDay current =
        const TimeOfDay(hour: 9, minute: 0);

    while (current.hour < 19) {
      ClassEntry? found;

      for (var c in classes) {
        if (c.start.hour == current.hour &&
            c.start.minute == current.minute) {
          found = c;
          break;
        }
      }

      if (found != null) {
        rows.add(buildRow(
          context,
          '${found.start.format(context)} - ${found.end.format(context)}',
          found.subject,
          found.professor,
          found,
        ));

        current = found.end;
      } else {
        final next =
            TimeOfDay(hour: current.hour + 1, minute: 0);
        rows.add(buildRow(
          context,
          '${current.format(context)} - ${next.format(context)}',
          '—',
          '—',
          null,
        ));
        current = next;
      }
    }

    return rows;
  }

  void showEditDeleteDialog(BuildContext context, ClassEntry entry) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit / Delete'),
          actions: [
            TextButton(
              child: const Text('DELETE'),
              onPressed: () {
                classes.remove(entry);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OutputScreen(day: day, classes: classes),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }


  Widget buildRow(
    BuildContext context,
    String a,
    String b,
    String c,
    ClassEntry? entry,
  ) {
    return GestureDetector(
      onLongPress: entry == null
          ? null
          : () => showDeleteClassDialog(context, entry),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 200, 35, 65),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(child: Text(a)),
            Expanded(child: Text(b)),
            Expanded(child: Text(c)),
          ],
        ),
      ),
    );
  }

  void showDeleteClassDialog(BuildContext context, ClassEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Class?'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            child: const Text('DELETE'),
            onPressed: () async {
              classes.remove(entry);
              await saveUpdatedTimetable();
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OutputScreen(day: day, classes: classes),
                ),
              );
            },
          ),
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> saveUpdatedTimetable() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString('timetable');
    if (raw == null) return;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded[day] = classes.map((e) => e.toJson()).toList();

    await prefs.setString('timetable', jsonEncode(decoded));
  }



  Widget buildHeaderRow() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Subject',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Professor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  


  

}




