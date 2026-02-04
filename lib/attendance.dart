import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';


class Subject {
  String name;
  Map<String, String> attendance; 

  Subject({
    required this.name,
    required this.attendance,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'attendance': attendance,
    };
  }

  factory Subject.fromMap(Map map) {
    return Subject(
      name: map['name'],
      attendance: Map<String, String>.from(map['attendance']),
    );
  }
}


class AttendanceHomeScreen extends StatefulWidget {
  const AttendanceHomeScreen({super.key});

  @override
  State<AttendanceHomeScreen> createState() =>
      _AttendanceHomeScreenState();
}

late DateTime currentMonth;

class _AttendanceHomeScreenState extends State<AttendanceHomeScreen> {
  final Box box = Hive.box('subjectsBox');



  void addSubject(String name) {
    if (name.trim().isEmpty) return;
    box.add(Subject(name: name, attendance: {}).toMap());
    setState(() {});
  }

  double calculateAttendance(Map<String, String> data) {
    int present = 0;
    int total = 0;

    data.forEach((_, status) {
      if (status == 'P') present++;
      if (status == 'P' || status == 'A' || status == 'L') total++;
    });

    if (total == 0) return 0;
    return (present / total) * 100;
  }


  @override
    void initState() {
      super.initState();
      currentMonth = DateTime.now();
    }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 161, 134, 2),
        centerTitle: true,
        title: Text(
          "Attendance",
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(212, 175, 55, 0.9),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          TextEditingController controller = TextEditingController();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Add Subject"),
              content: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: "Subject name"),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    addSubject(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text("ADD"),
                )
              ],
            ),
          );
        },
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: box.length,
        itemBuilder: (context, index) {
          final subject =
              Subject.fromMap(Map.from(box.getAt(index)));

          int present =
              subject.attendance.values.where((e) => e == 'P').length;

          int totalClasses = subject.attendance.values.where(
              (e) => e == 'P' || e == 'A' || e == 'L').length;

          double percentage =
              calculateAttendance(subject.attendance);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 231, 126, 64),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.book,
                size: 32,
                color: Colors.black,
              ),
              title: Row(
                children: [
                    const Icon(
                    Icons.event, 
                    size: 22,
                    color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                    subject.name,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                    ),
                    ),
                ],
                ),

              subtitle: Text(
                "Attendance: $present / $totalClasses  (${percentage.toStringAsFixed(1)}%)",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () {
                      box.deleteAt(index);
                      setState(() {});
                    },
                  ),

                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceCalendarScreen(
                      subject: subject,
                      index: index,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AttendanceCalendarScreen extends StatefulWidget {
  final Subject subject;
  final int index;

  const AttendanceCalendarScreen({
    super.key,
    required this.subject,
    required this.index,
  });

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState
    extends State<AttendanceCalendarScreen> {
      final Box box = Hive.box('subjectsBox');

      String monthName(DateTime date) {
      return "${_months[date.month - 1]} ${date.year}";
    }

    final List<String> _months = const [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];


  Color getColor(String? status) {
    switch (status) {
      case 'P':
        return Colors.green;
      case 'A':
        return Colors.red;
      case 'L':
        return Colors.amber;
      case 'H':
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  void markAttendance(String date, String status) {
    final updatedAttendance =
        Map<String, String>.from(widget.subject.attendance);

    updatedAttendance[date] = status;

    final updatedSubject = Subject(
      name: widget.subject.name,
      attendance: updatedAttendance,
    );

    box.putAt(widget.index, updatedSubject.toMap());

    setState(() {
      widget.subject.attendance.clear();
      widget.subject.attendance.addAll(updatedAttendance);
    });

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    int daysInMonth =
    DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 161, 134, 2),
        title: Text(
          widget.subject.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
  children: [

    const SizedBox(height: 12),

    
    Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    
    IconButton(
      icon: const Icon(Icons.arrow_left, size: 32),
      onPressed: () {
        setState(() {
          currentMonth =
              DateTime(currentMonth.year, currentMonth.month - 1);
        });
      },
    ),

    
    Text(
      monthName(currentMonth),
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),

    
    IconButton(
      icon: const Icon(Icons.arrow_right, size: 32),
      onPressed: () {
        setState(() {
          currentMonth =
              DateTime(currentMonth.year, currentMonth.month + 1);
        });
      },
    ),
  ],
),


    const SizedBox(height: 12),

    Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {


          String dateKey =
            '${currentMonth.year}-${currentMonth.month}-${index + 1}';


          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetTile("Present", Icons.check_circle,
                        Colors.green, 'P', dateKey),
                    _sheetTile("Absent", Icons.cancel, Colors.red,
                        'A', dateKey),
                    _sheetTile("Leave", Icons.edit, Colors.amber,
                        'L', dateKey),
                    _sheetTile("Holiday", Icons.event_busy,
                        Colors.grey, 'H', dateKey),
                  ],
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color:
                    getColor(widget.subject.attendance[dateKey]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: widget.subject.attendance[dateKey] == null
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    )
    ]));
  }

  ListTile _sheetTile(String text, IconData icon, Color color,
      String status, String dateKey) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text),
      onTap: () => markAttendance(dateKey, status),
    );
  }
}















// bhai yaad se month ka label laga lena 
// data delete karne ka option