import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'form_page.dart';
import 'professors_list_page.dart';
import 'bulk_import_page.dart';
import 'firestore_test_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.grey[900]!,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 4,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cold Email App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Progress Statistics Card
            Container(
              margin: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('professors')
                    .snapshots(),
                builder: (context, professorSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cold_email_data')
                        .snapshots(),
                    builder: (context, emailSnapshot) {
                      int totalProfessors = 0;
                      int filledProfessors = 0;

                      if (professorSnapshot.hasData) {
                        totalProfessors = professorSnapshot.data!.docs.length;

                        if (emailSnapshot.hasData) {
                          // Create set of professors with email data
                          final professorsWithData = <String>{};
                          for (var doc in emailSnapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name'] as String?;
                            if (name != null) {
                              professorsWithData.add(name);
                            }
                          }
                          filledProfessors = professorsWithData.length;
                        }
                      }

                      final progressPercentage = totalProfessors > 0
                          ? (filledProfessors / totalProfessors * 100).round()
                          : 0;

                      return Card(
                        elevation: 4,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.analytics,
                                size: 48,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Progress Overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '$filledProfessors',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const Text('Filled'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '/',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$totalProfessors',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const Text('Total'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: totalProfessors > 0
                                    ? filledProfessors / totalProfessors
                                    : 0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progressPercentage >= 75
                                      ? Colors.green
                                      : progressPercentage >= 50
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$progressPercentage% Complete',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: progressPercentage >= 75
                                      ? Colors.green
                                      : progressPercentage >= 50
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Cold Email App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Manage your professors and upload data',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormPage()),
                );
              },
              child: const Text('Upload Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfessorsListPage()),
                );
              },
              child: const Text('View Professors'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BulkImportPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Import Professors'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FirestoreTestPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
