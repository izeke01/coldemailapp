import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugDataPage extends StatelessWidget {
  final String professorId;
  final String professorName;

  const DebugDataPage({
    super.key,
    required this.professorId,
    required this.professorName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug: $professorName'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Professor ID: $professorId'),
            Text('Professor Name: $professorName'),
            const SizedBox(height: 20),
            const Text('Cold Email Data by Professor ID:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cold_email_data')
                    .where('professor_id', isEqualTo: professorId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData) {
                    return const Text('No snapshot data');
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Column(
                      children: [
                        const Text('No data found for this professor ID.'),
                        const SizedBox(height: 20),
                        const Text('All cold_email_data documents:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('cold_email_data')
                                .snapshots(),
                            builder: (context, allSnapshot) {
                              if (!allSnapshot.hasData) {
                                return const Text('Loading all data...');
                              }

                              final allDocs = allSnapshot.data!.docs;

                              if (allDocs.isEmpty) {
                                return const Text(
                                    'No cold_email_data documents exist at all.');
                              }

                              return ListView.builder(
                                itemCount: allDocs.length,
                                itemBuilder: (context, index) {
                                  final data = allDocs[index].data()
                                      as Map<String, dynamic>;
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Document ID: ${allDocs[index].id}'),
                                          Text(
                                              'Professor ID: ${data['professor_id'] ?? 'NULL'}'),
                                          Text(
                                              'Professor Name: ${data['professor_name'] ?? data['name'] ?? 'NULL'}'),
                                          Text(
                                              'Email: ${data['email'] ?? 'NULL'}'),
                                          Text(
                                              'Hook: ${data['hook_text'] ?? 'NULL'}'),
                                          const Divider(),
                                          Text('Raw data: $data'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Document ID: ${docs[index].id}'),
                              Text('Professor ID: ${data['professor_id']}'),
                              Text(
                                  'Professor Name: ${data['professor_name'] ?? data['name']}'),
                              Text('Email: ${data['email']}'),
                              Text('Hook: ${data['hook_text']}'),
                              Text('Publication: ${data['publication_title']}'),
                              Text('Year: ${data['publication_year']}'),
                              Text('Journal: ${data['journal_name']}'),
                              const Divider(),
                              Text('Raw data: $data'),
                            ],
                          ),
                        ),
                      );
                    },
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
