import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestPage extends StatelessWidget {
  const FirestoreTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Connection Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Cold Email Data in Firestore:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cold_email_data')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child:
                          Text('No data found in cold_email_data collection'),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(data['professor_name'] ??
                              data['name'] ??
                              'No name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Professor ID: ${data['professor_id'] ?? 'No ID'}'),
                              Text('Email: ${data['email'] ?? 'No email'}'),
                              Text(
                                  'Hook: ${data['hook_text'] ?? 'No hook text'}'),
                              Text(
                                  'Publication: ${data['publication_title'] ?? 'No publication'}'),
                              Text(
                                  'Year: ${data['publication_year'] ?? 'No year'}'),
                              Text(
                                  'Journal: ${data['journal_name'] ?? 'No journal'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await docs[index].reference.delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Record deleted'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Test adding data
                      await FirebaseFirestore.instance
                          .collection('cold_email_data')
                          .add({
                        'name': 'Test Professor',
                        'email': 'test@university.edu',
                        'hook_text': 'Test hook text',
                        'publication_title': 'Test Publication',
                        'publication_year': '2024',
                        'journal_name': 'Test Journal',
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test data added!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: const Text('Add Test Data'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Clear all data
                      final snapshot = await FirebaseFirestore.instance
                          .collection('cold_email_data')
                          .get();

                      for (final doc in snapshot.docs) {
                        await doc.reference.delete();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All data cleared!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
