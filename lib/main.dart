import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(FitnessTrackerApp());
}

class FitnessTrackerApp extends StatefulWidget {
  @override
  _FitnessTrackerAppState createState() => _FitnessTrackerAppState();
}

class _FitnessTrackerAppState extends State<FitnessTrackerApp> {
  List<Map<String, dynamic>> activities = [];
  int totalSteps = 0;
  int totalCalories = 0;
  int totalMinutes = 0;

  final stepsController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('activities', jsonEncode(activities));
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('activities');
    if (data != null) {
      setState(() {
        activities = List<Map<String, dynamic>>.from(jsonDecode(data));
        calculateTotals();
      });
    }
  }

  void addActivity() {
    if (stepsController.text.isNotEmpty &&
        caloriesController.text.isNotEmpty &&
        timeController.text.isNotEmpty) {
      setState(() {
        activities.add({
          "steps": int.parse(stepsController.text),
          "calories": int.parse(caloriesController.text),
          "time": int.parse(timeController.text),
          "date": DateTime.now().toString().split(" ")[0]
        });
        stepsController.clear();
        caloriesController.clear();
        timeController.clear();
        calculateTotals();
        saveData();
      });
    }
  }

  void calculateTotals() {
    totalSteps = 0;
    totalCalories = 0;
    totalMinutes = 0;
    for (var a in activities) {
      totalSteps += a["steps"];
      totalCalories += a["calories"];
      totalMinutes += a["time"];
    }
  }

  void clearData() {
    setState(() {
      activities.clear();
      totalSteps = totalCalories = totalMinutes = 0;
      saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fitness Tracker App'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: clearData,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Summary Dashboard
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text('Dashboard Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Total Steps: $totalSteps'),
                      Text('Total Calories: $totalCalories'),
                      Text('Total Workout Time: $totalMinutes mins'),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Add Activity
                Text('Add Daily Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                TextField(
                  controller: stepsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Steps Walked'),
                ),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Calories Burned'),
                ),
                TextField(
                  controller: timeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Workout Time (minutes)'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addActivity,
                  child: Text('Add Activity'),
                ),

                SizedBox(height: 20),

                // Activity List
                Text('Activity Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    var activity = activities[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.fitness_center),
                        title: Text("Steps: ${activity['steps']} | Cal: ${activity['calories']}"),
                        subtitle: Text("Time: ${activity['time']} mins | Date: ${activity['date']}"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
