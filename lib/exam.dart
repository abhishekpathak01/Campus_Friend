import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';



const Color kPrimaryGold = Color.fromARGB(255, 161, 134, 2);
const Color kCardOrange = Color.fromARGB(255, 231, 126, 64);






class Exam extends HiveObject {
  String examName;
  List<Subject> subjects;

  Exam({
    required this.examName,
    required this.subjects,
  });
}

class Subject {
  String subjectName;
  String date;
  String time;
  String syllabus;

  Subject({
    required this.subjectName,
    required this.date,
    required this.time,
    required this.syllabus,
  });
}



class ExamAdapter extends TypeAdapter<Exam> {
  @override
  final int typeId = 0;

  @override
  Exam read(BinaryReader reader) {
    final examName = reader.readString();
    final subjects = reader.readList().cast<Subject>();

    return Exam(
      examName: examName,
      subjects: subjects,
    );
  }

  @override
  void write(BinaryWriter writer, Exam obj) {
    writer.writeString(obj.examName);
    writer.writeList(obj.subjects);
  }
}

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 1;

  @override
  Subject read(BinaryReader reader) {
    return Subject(
      subjectName: reader.readString(),
      date: reader.readString(),
      time: reader.readString(),
      syllabus: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer.writeString(obj.subjectName);
    writer.writeString(obj.date);
    writer.writeString(obj.time);
    writer.writeString(obj.syllabus);
  }
}





class ExamHomeScreen extends StatelessWidget {
  const ExamHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<Exam> box = Hive.box<Exam>('examBox');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryGold,
        title: const Text(
          'Exams',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Exam> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No exams created'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final exam = box.getAt(index)!;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCardOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.assignment, size: 32, color: Colors.black),
                  title: Text(
                    exam.examName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExamDetailScreen(exam: exam),
                      ),
                    );
                  },
              )
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryGold,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExamScreen()),
          );
        },
      ),
    );
  }
}




class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final examNameController = TextEditingController();
  final subjectController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final syllabusController = TextEditingController();

  List<Subject> subjects = [];

  void addSubject() {
    if (subjectController.text.isEmpty) return;

    subjects.add(
      Subject(
        subjectName: subjectController.text,
        date: dateController.text,
        time: timeController.text,
        syllabus: syllabusController.text,
      ),
    );

    subjectController.clear();
    dateController.clear();
    timeController.clear();
    syllabusController.clear();

    setState(() {});
  }

  void saveExam() {
    final box = Hive.box<Exam>('examBox');

    box.add(
      Exam(
        examName: examNameController.text,
        subjects: subjects,
      ),
    );

    Navigator.pop(context);
  }

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
            title: const Text(
              'Create Exam',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
          ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: examNameController,
              decoration: const InputDecoration(labelText: 'Exam Name'),
            ),
            const Divider(height: 30),

            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (From–To)'),
            ),
            TextField(
              controller: syllabusController,
              decoration: const InputDecoration(labelText: 'Syllabus'),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addSubject,
              child: const Text('Add Subject'),
            ),

            const SizedBox(height: 20),
            ...subjects.map((s) => ListTile(title: Text(s.subjectName))),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveExam,
              child: const Text('Save Exam'),
            ),
          ],
        ),
      ),
    );
  }
}




class ExamDetailScreen extends StatelessWidget {
  final Exam exam;
  const ExamDetailScreen({super.key, required this.exam});

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
          exam.examName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: exam.subjects.length,
        itemBuilder: (context, index) {
          final s = exam.subjects[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kCardOrange,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.black),

              title: Text(s.subjectName),
              subtitle: Text(
                '${s.date}\n${s.time}\nSyllabus: ${s.syllabus}',
              ),
            ),
          );
        },
      ),
    );
  }
}

