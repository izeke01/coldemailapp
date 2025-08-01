import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'form_page.dart';
import 'emailjs_service.dart';

class ProfessorsListPage extends StatefulWidget {
  const ProfessorsListPage({super.key});

  @override
  State<ProfessorsListPage> createState() => _ProfessorsListPageState();
}

class _ProfessorsListPageState extends State<ProfessorsListPage> {
  String _filterStatus =
      'all'; // 'all', 'filled', 'unfilled', 'emailed', 'responded', 'not_responded'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professors List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _filterStatus == 'all'
                      ? Icons.list
                      : _filterStatus == 'filled'
                          ? Icons.check_circle
                          : _filterStatus == 'emailed'
                              ? Icons.email
                              : _filterStatus == 'responded'
                                  ? Icons.reply
                                  : _filterStatus == 'not_responded'
                                      ? Icons.reply_outlined
                                      : Icons.radio_button_unchecked,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.filter_list),
              ],
            ),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list,
                        color:
                            _filterStatus == 'all' ? Colors.blue : Colors.grey),
                    const SizedBox(width: 8),
                    Text('All Professors',
                        style: TextStyle(
                          fontWeight: _filterStatus == 'all'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unfilled',
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked,
                        color: _filterStatus == 'unfilled'
                            ? Colors.orange
                            : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Unfilled Only',
                        style: TextStyle(
                          fontWeight: _filterStatus == 'unfilled'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'filled',
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: _filterStatus == 'filled'
                            ? Colors.green
                            : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Filled Only',
                        style: TextStyle(
                          fontWeight: _filterStatus == 'filled'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'emailed',
                child: Row(
                  children: [
                    Icon(Icons.email,
                        color: _filterStatus == 'emailed'
                            ? Colors.blue
                            : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Emailed Only',
                        style: TextStyle(
                          fontWeight: _filterStatus == 'emailed'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'responded',
                child: Row(
                  children: [
                    Icon(Icons.reply,
                        color: _filterStatus == 'responded'
                            ? Colors.purple
                            : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Responded Only',
                        style: TextStyle(
                          fontWeight: _filterStatus == 'responded'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'not_responded',
                child: Row(
                  children: [
                    Icon(Icons.reply_outlined,
                        color: _filterStatus == 'not_responded'
                            ? Colors.red
                            : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Not Responded',
                        style: TextStyle(
                          fontWeight: _filterStatus == 'not_responded'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search professors by name, university, or department...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Professors list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('professors')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No professors found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some professors to the Firestore database',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final professors = snapshot.data!.docs;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cold_email_data')
                      .snapshots(),
                  builder: (context, emailSnapshot) {
                    // Create maps for professor data, emailed status, and response status
                    final emailDataMap = <String, bool>{};
                    final emailedProfessorsMap = <String, bool>{};
                    final respondedProfessorsMap = <String, bool>{};

                    if (emailSnapshot.hasData) {
                      for (var doc in emailSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name'] as String?;
                        if (name != null) {
                          emailDataMap[name] = true;
                          // Check if professor has been emailed
                          final isEmailed = data['emailed'] == true;
                          if (isEmailed) {
                            emailedProfessorsMap[name] = true;
                          }
                          // Check if professor has responded
                          final hasResponse = data['response'] != null &&
                              data['response'].toString().trim().isNotEmpty;
                          if (hasResponse) {
                            respondedProfessorsMap[name] = true;
                          }
                        }
                      }
                    }

                    // Filter professors based on current filter status and search query
                    final filteredProfessors = professors.where((professor) {
                      final data = professor.data() as Map<String, dynamic>;
                      final professorName = data['name'] as String?;
                      if (professorName == null) return false;

                      // Search filter
                      if (_searchQuery.isNotEmpty) {
                        final name = professorName.toLowerCase();
                        final university =
                            (data['university'] as String?)?.toLowerCase() ??
                                '';
                        final department =
                            (data['department'] as String?)?.toLowerCase() ??
                                '';
                        final email =
                            (data['email'] as String?)?.toLowerCase() ?? '';

                        if (!name.contains(_searchQuery) &&
                            !university.contains(_searchQuery) &&
                            !department.contains(_searchQuery) &&
                            !email.contains(_searchQuery)) {
                          return false;
                        }
                      }

                      // Status filter
                      final hasData = emailDataMap.containsKey(professorName);
                      final isEmailed =
                          emailedProfessorsMap.containsKey(professorName);
                      final hasResponded =
                          respondedProfessorsMap.containsKey(professorName);

                      switch (_filterStatus) {
                        case 'filled':
                          return hasData;
                        case 'unfilled':
                          return !hasData;
                        case 'emailed':
                          return isEmailed;
                        case 'responded':
                          return hasResponded;
                        case 'not_responded':
                          return isEmailed &&
                              !hasResponded; // Emailed but no response
                        case 'all':
                        default:
                          return true;
                      }
                    }).toList();
                    if (filteredProfessors.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _filterStatus == 'filled'
                                  ? Icons.check_circle_outline
                                  : _filterStatus == 'unfilled'
                                      ? Icons.radio_button_unchecked
                                      : _filterStatus == 'emailed'
                                          ? Icons.email_outlined
                                          : _filterStatus == 'responded'
                                              ? Icons.reply_outlined
                                              : _filterStatus == 'not_responded'
                                                  ? Icons.reply_outlined
                                                  : Icons.school_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filterStatus == 'filled'
                                  ? 'No professors with filled data'
                                  : _filterStatus == 'unfilled'
                                      ? 'No professors with unfilled data'
                                      : _filterStatus == 'emailed'
                                          ? 'No professors have been emailed yet'
                                          : _filterStatus == 'responded'
                                              ? 'No professors have responded yet'
                                              : _filterStatus == 'not_responded'
                                                  ? 'All emailed professors have responded!'
                                                  : _searchQuery.isNotEmpty
                                                      ? 'No professors match your search'
                                                      : 'No professors found',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _filterStatus == 'filled'
                                  ? 'Start adding cold email data to professors'
                                  : _filterStatus == 'unfilled'
                                      ? 'All professors have cold email data!'
                                      : _filterStatus == 'emailed'
                                          ? 'Send some emails to see them here'
                                          : _filterStatus == 'responded'
                                              ? 'Responses will appear here once professors reply'
                                              : _filterStatus == 'not_responded'
                                                  ? 'Great job! All your emails got responses'
                                                  : _searchQuery.isNotEmpty
                                                      ? 'Try adjusting your search terms'
                                                      : 'Add some professors to the Firestore database',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProfessors.length,
                      itemBuilder: (context, index) {
                        final professor = filteredProfessors[index];
                        final data = professor.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('cold_email_data')
                                .where('name', isEqualTo: data['name'])
                                .limit(1)
                                .snapshots(),
                            builder: (context, dataSnapshot) {
                              final hasData = dataSnapshot.hasData &&
                                  dataSnapshot.data!.docs.isNotEmpty;

                              // Check if professor has been emailed and responded
                              bool isEmailed = false;
                              bool hasResponded = false;
                              if (hasData &&
                                  dataSnapshot.data!.docs.isNotEmpty) {
                                final emailData = dataSnapshot.data!.docs.first
                                    .data() as Map<String, dynamic>;
                                isEmailed = emailData['emailed'] == true;
                                hasResponded = emailData['response'] != null &&
                                    emailData['response']
                                        .toString()
                                        .trim()
                                        .isNotEmpty;
                              }

                              // Get email from either professor data or cold email data
                              String? professorEmail = data['email'] as String?;
                              if (hasData &&
                                  dataSnapshot.data!.docs.isNotEmpty) {
                                final emailData = dataSnapshot.data!.docs.first
                                    .data() as Map<String, dynamic>;
                                professorEmail = professorEmail ??
                                    emailData['email'] as String?;
                              }

                              return ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        _getInitials(data['name'] ?? 'Unknown'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (hasData)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Text(
                                  data['name'] ?? 'Unknown Professor',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (data['department'] != null)
                                      Text('Department: ${data['department']}'),
                                    if (data['university'] != null)
                                      Text('University: ${data['university']}'),
                                    if (professorEmail != null &&
                                        professorEmail.isNotEmpty)
                                      Text('Email: $professorEmail'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Badge system for professor status - highest priority first
                                    if (hasResponded)
                                      Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.reply,
                                                color: Colors.white, size: 10),
                                            SizedBox(width: 2),
                                            Text(
                                              'Responded',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isEmailed && !hasResponded)
                                      Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.email,
                                                color: Colors.white, size: 10),
                                            SizedBox(width: 2),
                                            Text(
                                              'Emailed',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (hasData && !isEmailed)
                                      Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check,
                                                color: Colors.white, size: 10),
                                            SizedBox(width: 2),
                                            Text(
                                              'Filled',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (!hasData)
                                      Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.pending,
                                                color: Colors.white, size: 10),
                                            SizedBox(width: 2),
                                            Text(
                                              'Unfilled',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () {
                                        _showProfessorDetails(
                                            context, data, professor.id);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _showProfessorDetails(
                                      context, data, professor.id);
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProfessorDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  void _showProfessorDetails(
      BuildContext context, Map<String, dynamic> data, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['name'] ?? 'Professor Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Professor basic info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Professor Information:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      if (data['department'] != null) ...[
                        Text('Department: ${data['department']}'),
                        const SizedBox(height: 4),
                      ],
                      if (data['university'] != null) ...[
                        Text('University: ${data['university']}'),
                        const SizedBox(height: 4),
                      ],
                      if (data['email'] != null) ...[
                        Text('Email: ${data['email']}'),
                        const SizedBox(height: 4),
                      ],
                      if (data['research_interests'] != null) ...[
                        Text(
                            'Research Interests: ${data['research_interests']}'),
                        const SizedBox(height: 4),
                      ],
                      if (data['phone'] != null) ...[
                        Text('Phone: ${data['phone']}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Cold email data
              const Text('Cold Email Data:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cold_email_data')
                      .where('name', isEqualTo: data['name'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error loading data: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No cold email data found for this professor.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    // Sort manually since we removed orderBy to avoid index requirement
                    final emailData = snapshot.data!.docs;
                    emailData.sort((a, b) {
                      final aTime = a.data() as Map<String, dynamic>;
                      final bTime = b.data() as Map<String, dynamic>;
                      final aTimestamp = aTime['timestamp'] as Timestamp?;
                      final bTimestamp = bTime['timestamp'] as Timestamp?;

                      if (aTimestamp == null && bTimestamp == null) return 0;
                      if (aTimestamp == null) return 1;
                      if (bTimestamp == null) return -1;

                      return bTimestamp
                          .compareTo(aTimestamp); // Descending order
                    });

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: emailData.length,
                      itemBuilder: (context, index) {
                        final emailDoc = emailData[index];
                        final emailInfo =
                            emailDoc.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        size: 16, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Entry ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (emailInfo['timestamp'] != null)
                                      Text(
                                        _formatTimestamp(
                                            emailInfo['timestamp']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (emailInfo['email'] != null) ...[
                                  const Text('Email:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  SelectableText(
                                    emailInfo['email'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (emailInfo['hook_text'] != null) ...[
                                  const Text('Hook Text:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  SelectableText(
                                    emailInfo['hook_text'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (emailInfo['publication_title'] != null) ...[
                                  const Text('Publication:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  SelectableText(
                                    emailInfo['publication_title'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (emailInfo['publication_year'] != null) ...[
                                  const Text('Year:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  SelectableText(
                                    emailInfo['publication_year'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (emailInfo['journal_name'] != null) ...[
                                  const Text('Journal:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  SelectableText(
                                    emailInfo['journal_name'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                                if (emailInfo['emailed'] == true) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.email,
                                            color: Colors.blue.shade700,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Emailed on ${emailInfo['emailed_timestamp'] != null ? _formatTimestamp(emailInfo['emailed_timestamp']) : 'Unknown date'}',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (emailInfo['response'] != null &&
                                    emailInfo['response']
                                        .toString()
                                        .trim()
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.purple.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.reply,
                                                color: Colors.purple.shade700,
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Professor Response:',
                                              style: TextStyle(
                                                color: Colors.purple.shade700,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        SelectableText(
                                          emailInfo['response'],
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black),
                                        ),
                                        if (emailInfo['response_timestamp'] !=
                                            null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Responded on ${_formatTimestamp(emailInfo['response_timestamp'])}',
                                            style: TextStyle(
                                              color: Colors.purple.shade600,
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
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
        actions: [
          // Smart button based on whether data exists
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cold_email_data')
                .where('name', isEqualTo: data['name'])
                .limit(1)
                .snapshots(),
            builder: (context, dataSnapshot) {
              final hasData =
                  dataSnapshot.hasData && dataSnapshot.data!.docs.isNotEmpty;

              // Check if professor has been emailed
              bool isEmailed = false;
              if (hasData && dataSnapshot.data!.docs.isNotEmpty) {
                final emailData = dataSnapshot.data!.docs.first.data()
                    as Map<String, dynamic>;
                isEmailed = emailData['emailed'] == true;
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close current dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPage(
                            professorName: data['name'],
                            professorEmail: data['email'],
                            isUpdate: hasData,
                            existingData:
                                hasData && dataSnapshot.data!.docs.isNotEmpty
                                    ? dataSnapshot.data!.docs.first.data()
                                        as Map<String, dynamic>
                                    : null,
                            documentId:
                                hasData && dataSnapshot.data!.docs.isNotEmpty
                                    ? dataSnapshot.data!.docs.first.id
                                    : null,
                          ),
                        ),
                      );
                    },
                    icon: Icon(hasData ? Icons.edit : Icons.add),
                    label: Text(hasData ? 'Update Data' : 'Add Cold Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasData ? Colors.orange : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final emailData = dataSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                        _showGeneratedEmail(context, data, emailData);
                      },
                      icon: const Icon(Icons.mail),
                      label: const Text('Generate Email'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  if (isEmailed) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final emailData = dataSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                        _showAddResponseDialog(
                            context, data['name'], emailData);
                      },
                      icon: const Icon(Icons.reply),
                      label: const Text('Add Response'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else {
        return timestamp.toString();
      }

      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp.toString();
    }
  }

  void _showGeneratedEmail(BuildContext context,
      Map<String, dynamic> professorData, Map<String, dynamic> emailData) {
    final emailTemplate = '''Dear Professor [Name],

I recently read your [Publication year] study, titled "[Publication title]", which was published in [Publication Journal]. [Hook]. Honestly, this was remarkable. It is inspiring and exactly the kind of research I want to contribute to. 

I am Isaac Enuma, a Civil Engineering graduate from the University of Benin, Nigeria, where I obtained a Bachelor of Engineering degree and graduated in the top 4% of my class with a 4.49/5.0 CGPA. I am writing to express my strong interest in pursuing a PhD at [University name] in either the Spring or Fall 2026 semester. I would greatly appreciate the opportunity to be advised by you and learn from your expertise in the field.

My research focuses on sustainable water treatment, resource recovery, and remediation processes. During my time as an Undergraduate Research Assistant, I worked with water hyacinth plants to remove oil pollution from wastewater; we were able to eliminate nearly 99% of the hydrocarbons. Another study I did focused on designing a membrane bioreactor system using locally available materials to treat polluted water from an oil field. I also leverage Python (ML), MATLAB, and BioWin to model and optimize processes. These are skills I possess and can contribute effectively. What I truly enjoy about this line of research is discovering practical solutions that can make a tangible difference, especially in areas where expensive treatment systems aren't an option.

I would be more than glad to schedule an online call with you to ascertain my suitability further. I'm happy to accommodate your schedule. I have attached my CV and Unofficial Transcript for your review. Thank you very much for your time and consideration spent in reading this email. I look forward to hearing from you at your earliest convenience.''';

    // Replace placeholders with actual data
    String personalizedEmail = emailTemplate
        .replaceAll('[Name]', professorData['name'] ?? '[Name]')
        .replaceAll('[Publication year]',
            emailData['publication_year'] ?? '[Publication year]')
        .replaceAll('[Publication title]',
            emailData['publication_title'] ?? '[Publication title]')
        .replaceAll('[Publication Journal]',
            emailData['journal_name'] ?? '[Publication Journal]')
        .replaceAll('[Hook]', emailData['hook_text'] ?? '[Hook]')
        .replaceAll('[University name]',
            professorData['university'] ?? '[University name]');

    // Get email from either professor data or cold email data
    final professorEmail =
        professorData['email'] as String? ?? emailData['email'] as String?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.mail, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Generated Cold Email for ${professorData['name']}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This email has been personalized with the professor\'s data. You can select and copy the text below.',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      personalizedEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: personalizedEmail));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email content copied to clipboard!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.content_copy),
            label: const Text('Copy Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                // Get email from either professor data or cold email data
                final professorEmail = professorData['email'] as String? ??
                    emailData['email'] as String?;
                print('Mailgun - Professor email check: $professorEmail');
                print('Mailgun - Professor data: $professorData');
                print('Mailgun - Email data: $emailData');

                if (professorEmail != null && professorEmail.isNotEmpty) {
                  // Show Gmail SMTP email setup/send dialog
                  await _showGmailSMTPEmailDialog(context, professorEmail,
                      personalizedEmail, professorData);
                } else {
                  if (context.mounted) {
                    // Show dialog to add email directly
                    final shouldAddEmail = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Missing Email'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'Professor "${professorData['name']}" does not have an email address.'),
                            const SizedBox(height: 12),
                            Text(
                                'Available professor fields: ${professorData.keys.join(", ")}'),
                            const SizedBox(height: 8),
                            Text(
                                'Available email fields: ${emailData.keys.join(", ")}'),
                            const SizedBox(height: 12),
                            const Text(
                                'Would you like to add an email address now?'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Add Email'),
                          ),
                        ],
                      ),
                    );

                    if (shouldAddEmail == true) {
                      _showQuickEmailDialog(context, professorData);
                    }
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Send via Gmail'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGmailSMTPEmailDialog(
      BuildContext context,
      String recipientEmail,
      String emailBody,
      Map<String, dynamic> professorData) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            SizedBox(width: 8),
            Text('Send Email via Gmail SMTP'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will send the email directly using Gmail SMTP with automatic PDF attachments.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Using your Gmail app password from lib/gmail_app_password.txt',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'CV and Transcript PDFs will be automatically attached.',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context); // Close email dialog first

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Sending email...'),
                    ],
                  ),
                ),
              );

              try {
                // Send email using EmailJS
                final success = await EmailJSService.sendEmailWithAttachments(
                  recipientEmail: recipientEmail,
                  subject:
                      'PhD Application Inquiry - ${professorData['university']}',
                  body: emailBody,
                  senderName: 'Isaac Enuma',
                );

                // If email sent successfully, mark professor as emailed
                if (success) {
                  await _markProfessorAsEmailed(professorData['name']);
                }

                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);

                  // Show result message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Email sent successfully via EmailJS!'
                          : 'Failed to send email. Check console for details.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: Duration(seconds: success ? 3 : 5),
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog on error
                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending email: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickEmailDialog(
      BuildContext context, Map<String, dynamic> professorData) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Email for ${professorData['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isNotEmpty) {
                try {
                  // Find the professor document and update it
                  final querySnapshot = await FirebaseFirestore.instance
                      .collection('professors')
                      .where('name', isEqualTo: professorData['name'])
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    final docId = querySnapshot.docs.first.id;
                    await FirebaseFirestore.instance
                        .collection('professors')
                        .doc(docId)
                        .update({'email': emailController.text.trim()});

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Email added successfully! Try Gmail SMTP again.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding email: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddProfessorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final departmentController = TextEditingController();
    final universityController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Professor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: universityController,
                decoration: const InputDecoration(
                  labelText: 'University',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('professors')
                      .add({
                    'name': nameController.text.trim(),
                    'department': departmentController.text.trim(),
                    'university': universityController.text.trim(),
                    'email': emailController.text.trim(),
                    'created_at': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Professor added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding professor: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddResponseDialog(BuildContext context, String professorName,
      Map<String, dynamic> emailData) {
    final responseController = TextEditingController();

    // Pre-fill if response already exists
    if (emailData['response'] != null) {
      responseController.text = emailData['response'].toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.reply, color: Colors.purple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Add Response for $professorName',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.purple.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Record the professor\'s response to your cold email. This will help track your outreach progress.',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: responseController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Professor Response',
                  hintText: 'Enter the professor\'s response here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (emailData['response'] != null) ...[
            TextButton(
              onPressed: () async {
                // Remove response
                await _updateProfessorResponse(professorName, null);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response removed successfully!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Remove Response'),
            ),
          ],
          ElevatedButton.icon(
            onPressed: () async {
              final responseText = responseController.text.trim();
              if (responseText.isNotEmpty) {
                try {
                  await _updateProfessorResponse(professorName, responseText);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Response saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving response: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a response before saving.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Response'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to update professor response
  Future<void> _updateProfessorResponse(
      String professorName, String? response) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('cold_email_data')
          .where('name', isEqualTo: professorName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        Map<String, dynamic> updateData;
        if (response != null) {
          updateData = {
            'response': response,
            'response_timestamp': FieldValue.serverTimestamp(),
          };
        } else {
          updateData = {
            'response': FieldValue.delete(),
            'response_timestamp': FieldValue.delete(),
          };
        }

        await FirebaseFirestore.instance
            .collection('cold_email_data')
            .doc(docId)
            .update(updateData);

        print('Updated response for $professorName');
      }
    } catch (e) {
      print('Error updating professor response: $e');
    }
  }

  // Helper function to mark professor as emailed
  Future<void> _markProfessorAsEmailed(String professorName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('cold_email_data')
          .where('name', isEqualTo: professorName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('cold_email_data')
            .doc(docId)
            .update({
          'emailed': true,
          'emailed_timestamp': FieldValue.serverTimestamp(),
        });
        print('Marked $professorName as emailed');
      }
    } catch (e) {
      print('Error marking professor as emailed: $e');
    }
  }
}
