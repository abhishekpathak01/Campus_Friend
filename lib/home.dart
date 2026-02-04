import 'package:flutter/material.dart';
import 'home_tilebutton.dart';
import 'attendance.dart';
import 'class.dart';
import 'exam.dart';

class homepageee extends StatelessWidget {
  const homepageee({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 161, 134, 2)),
              child: Text(
                "Menu",
                style: TextStyle(color: Color.fromARGB(255, 232, 228, 231), fontSize: 20),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.school),
              title: Text("Class"),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Class_schedule(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.event),
              title: Text("Exam"),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExamHomeScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.assignment),
              title: Text("Attendance"),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHomeScreen(),
                  ),
                );
              },

            ),

            ListTile(
              leading: Icon(Icons.book),
              title: Text("Note"),
              onTap: () {},
            ),

          ],
        ),
      ),

      
      appBar: AppBar(
        title: const Text("Welcome Back !!!",
         style: TextStyle(
          fontSize: 29, 
          fontWeight: FontWeight.w900,
         ),
         ),
        centerTitle: true,
      ),

      
      body: Padding(
        padding: const EdgeInsets.all(16),
        
        child: Column(

          
          children: [
            SizedBox(height: 10,),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TopButton(text:"Class", icon:Icons.school, onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Class_schedule(),
                        ),
                      );
                  }
            ),
                  SizedBox(width: 10),

                  TopButton(
                    text: "Exam",
                    icon: Icons.assignment,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExamHomeScreen(),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(width: 10),

                  TopButton(
                    text: "Attendance",
                    icon: Icons.event_available,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AttendanceHomeScreen(),
                        ),
                      );
                    },
                  ),

                  SizedBox(width: 10),
                  TopButton(text:"Note",icon: Icons.book, onPressed: (){}),
                ],
              ),
            ),

            const SizedBox(height: 30),

           
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 231, 126, 64),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // PHOTO
                  Container(
                    height: 180,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 188, 116, 21),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 85,
                      color: Color.fromARGB(255, 134, 49, 49),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Abhishek Pathak",
                          
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text("Roll No: 24cd3003"),
                        SizedBox(height: 4),
                        Text("Rajiv Gandhi Institute of Petroleum Technology",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                          ),),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}


