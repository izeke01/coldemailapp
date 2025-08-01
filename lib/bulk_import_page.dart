import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BulkImportPage extends StatefulWidget {
  const BulkImportPage({super.key});

  @override
  State<BulkImportPage> createState() => _BulkImportPageState();
}

class _BulkImportPageState extends State<BulkImportPage> {
  bool _isImporting = false;
  int _importedCount = 0;
  int _totalCount = 0;

  final List<Map<String, String>> _professorsData = [
    {"university": "Michigan State University", "name": "Krista Wigginton"},
    {"university": "Wayne State University", "name": "Carol Miller"},
    {"university": "University at Buffalo--SUNY", "name": "Ian Bradley"},
    {"university": "Montana State University", "name": "Otto stein"},
    {
      "university": "University of Tennessee--Knoxville (Tickle)",
      "name": "Qiang He"
    },
    {"university": "University of Washington", "name": "Michael Dodd"},
    {
      "university": "Missouri University of Science & Technology",
      "name": "Jianmin Wang"
    },
    {"university": "North Carolina State University", "name": "Douglas Call"},
    {"university": "Tennessee Technological University", "name": "Tania Datta"},
    {"university": "Oklahoma State University", "name": "Mary Foltz"},
    {"university": "University of Maine", "name": "Onur G Apul"},
    {"university": "Rutgers University", "name": "Nicole Fahrenfeld"},
    {"university": "Texas A&M University", "name": "Shankar Chellam"},
    {"university": "University of Missouri", "name": "Baolin Deng"},
    {"university": "Carnegie Mellon University", "name": "Sarah Fakhreddine"},
    {
      "university": "Florida International University",
      "name": "Hooman Vatankhah"
    },
    {
      "university": "Louisiana State University--Baton Rouge",
      "name": "William Moe"
    },
    {"university": "Texas State University", "name": "Keisuke Ikehata"},
    {"university": "Purdue University", "name": "Ernest R. Blatchley III"},
    {
      "university": "University of Nevada--Las Vegas (Hughes)",
      "name": "Jacimaria Batista"
    },
    {"university": "University of Minnesota", "name": "Hozalski, Raymond"},
    {"university": "Syracuse University", "name": "Teng Zeng"},
    {
      "university": "University of North Carolina--Charlotte (W.S.Lee)",
      "name": "James E. Amburgey"
    },
    {"university": "University of Alabama", "name": "Matthew Blair"},
    {"university": "University of Akron", "name": "Christopher M. Miller"},
    {"university": "Vanderbilt University", "name": "Alan R Bowers"},
    {"university": "University of Idaho", "name": "Erik R. Coats"},
    {"university": "Northwestern University", "name": "George Wells"},
    {"university": "University of Virginia", "name": "Lisa Colosi Peterson"},
    {"university": "Stony Brook University", "name": "Xinwei Mao"},
    {"university": "University of Arkansas", "name": "Julian Fairey"},
    {"university": "University of Hawaii--Manoa", "name": "Juhee Kim"},
    {
      "university": "University of Texas--San Antonio (Klesse)",
      "name": "Vikram Kapoor"
    },
    {"university": "Tennessee State University", "name": "Roger Painter"},
    {"university": "Florida Atlantic University", "name": "Fred Bloetscher"},
    {"university": "Kansas State University", "name": "Jeongdae Im"},
    {
      "university": "Texas Tech University (Whitacre)",
      "name": "Clifford B. Fedler"
    },
    {"university": "Brigham Young University", "name": "Rob Sowby"},
    {"university": "Rice University", "name": "Menachem Elimelech"},
    {"university": "University of Nebraska", "name": "Nirupam Aich"},
    {"university": "Columbia University", "name": "Kartik Chandran"},
    {"university": "Georgia Institute of Technology", "name": "Sharon Just"},
    {
      "university": "North Dakota State University",
      "name": "Syeed Md Iskander"
    },
    {"university": "Illinois Institute of Technology", "name": "David Lampert"},
    {"university": "University of Wisconsin--Milwaukee", "name": "Jin Li"},
    {
      "university": "University of Alabama at Birmingham",
      "name": "Robert W. Peters"
    },
    {"university": "University of Oklahoma", "name": "Ngoc Bui"},
    {"university": "University of Michigan Ann Arbor", "name": "Glen Daigger"},
    {"university": "University of New Hampshire", "name": "Alison Watts"},
    {"university": "University of New Mexico", "name": "Allyson McGaughey"},
    {"university": "Utah State University", "name": "Michael McFarland"},
    {
      "university": "Portland State University (Maseeh)",
      "name": "Gwynn Johnson"
    },
    {"university": "Lamar University", "name": "Thinesh Selvaratnam"},
    {"university": "University of Iowa", "name": "David Cwiertny"},
    {"university": "University of Pittsburgh (Swanson)", "name": "Sarah Haig"},
    {
      "university": "West Virginia University (Statler)",
      "name": "Emily Garner"
    },
    {
      "university": "The University of Texas at Arlington",
      "name": "Xiujuan Chen"
    },
    {"university": "Case Western Reserve University", "name": "Kurt Rhoads"},
    {"university": "Florida A&M University", "name": "Sol Park"},
    {"university": "Virginia Tech", "name": "Kirin E. Furst"},
    {"university": "University of Vermont", "name": "Matthew J. Scarborough"},
    {
      "university": "University of California, Davis",
      "name": "Casey De Finnda (Finnerty)"
    },
    {"university": "University of Kentucky", "name": "Minjae Kim"},
    {"university": "University of Texas at Austin", "name": "Mary Jo Kirisits"},
    {"university": "Ohio State University", "name": "Jeff Bielicki"},
    {"university": "Oregon State University", "name": "Kathryn Newhart"},
    {"university": "Northeastern University", "name": "Marieh Arekhi"},
    {"university": "New York University", "name": "Andrea Silverman"},
    {
      "university": "University of Massachusetts--Lowell",
      "name": "Xiaoqi (Jackie) Zhang"
    },
    {
      "university": "Mississippi State University",
      "name": "Benjamin S. Magbanua"
    },
    {"university": "University of Arizona", "name": "Reyes Sierra-Alvarez"},
    {"university": "New Jersey Institute of Technology", "name": "Yuan Ding"},
    {"university": "University of Nevada--Reno", "name": "Ben Ma"},
    {
      "university": "University of Louisiana--Lafayette",
      "name": "Mark E. Zappi"
    },
    {"university": "University of Colorado--Boulder", "name": "Sherri Cook"},
    {"university": "University of South Florida", "name": "Katherine Alfredo"},
    {
      "university": "University of Louisville (Speed)",
      "name": "Thomas Rockaway"
    },
    {"university": "Arizona State University", "name": "Treavor Boyer"},
    {
      "university": "New Mexico Institute of Mining and Technology",
      "name": "Frank Y.C. Huang"
    },
    {"university": "Auburn University", "name": "Jillian Maxcy-Brown"},
    {"university": "University of Delaware", "name": "Jennie Saxe"},
    {
      "university": "University of California--Los Angeles",
      "name": "Shaily Mahendra"
    },
    {"university": "Drexel University", "name": "Franco Montalto"},
    {
      "university": "Michigan Technological University",
      "name": "Daisuke Minakata"
    },
    {"university": "University of Alabama--Huntsville", "name": "Tingting Wu"},
    {"university": "Florida Institute of Technology", "name": "Howell H. Heck"},
    {"university": "University of Miami", "name": "Helena M Solo-Gabriele"},
    {"university": "Jackson State University", "name": "danuta leszczynska"},
    {
      "university": "University of Illinois at Urbana-Champaign",
      "name": "JEREMY GUEST"
    },
    {"university": "Clemson University", "name": "Ezra L. Cates"},
    {
      "university": "Texas A&M University--Kingsville (Dotterweich)",
      "name": "Lucy M. Camacho"
    },
    {"university": "University of Wisconsin--Madison", "name": "Mohan Qin"},
    {
      "university": "University of Southern California",
      "name": "Amy Childress"
    },
    {"university": "University of Georgia", "name": "Ke \"Luke\" Li"},
    {
      "university": "University of Alaska--Fairbanks",
      "name": "Srijan Aggarwal"
    },
    {"university": "Cornell University", "name": "Natalie Cápiro"},
    {"university": "San Diego State University", "name": "Matthew E. Verbyla"},
    {"university": "Temple University", "name": "Rominder Suri"},
    {"university": "University of Connecticut", "name": "Baikun Li"},
    {
      "university": "Rensselaer Polytechnic Institute",
      "name": "Marianne Nyman"
    },
    {
      "university": "South Dakota State University",
      "name": "Christopher Schmit"
    },
    {"university": "Idaho State University", "name": "Solomon Leung"},
    {"university": "New Mexico State University", "name": "Pei Xu"},
    {"university": "University of South Carolina", "name": "Nicole D. Berge"},
    {
      "university": "Worcester Polytechnic Institute",
      "name": "John Bergendahl"
    },
    {"university": "Tufts University", "name": "Wayne Chudyk"},
    {"university": "Boise State University", "name": "Natalie Hull"},
    {"university": "Stevens Institute of Technology", "name": "Xiaoguang Meng"},
    {"university": "University of North Dakota", "name": "Mahmut Selim Ersan"},
    {"university": "University of Wyoming", "name": "Jonathan A. Brant"},
    {"university": "Iowa State University", "name": "Joe Charbonnet"},
    {"university": "University of California, Berkeley", "name": "Baoxia Mi"},
    {"university": "University of Utah", "name": "Andy Hong"},
    {
      "university": "Colorado School of Mines",
      "name": "Christopher P. Higgins"
    },
    {"university": "University of Houston", "name": "Stacey Louie"},
    {
      "university": "University of South Alabama",
      "name": "Kaushik Venkiteshwaran"
    },
    {"university": "University of Notre Dame", "name": "Kyle Bibby"},
    {"university": "University of California, Irvine", "name": "Shakira Hobbs"},
    {
      "university": "University of California, Los Angeles",
      "name": "Eric Hoek"
    },
    {"university": "University of Maryland", "name": "Davis, Allen P."},
    {"university": "Washington State University", "name": "Indranil Chowdhury"},
    {"university": "University of Florida", "name": "Andreia Faria"},
    {
      "university": "The University of Texas at El Paso",
      "name": "Camila Leite Madeira"
    },
    {"university": "Duke University", "name": "Lee Ferguson"},
    {"university": "Pennsylvania State University", "name": "Meng Wang"},
    {"university": "Colorado State University", "name": "Mazdak Arabi"},
    {
      "university": "South Dakota School of Mines",
      "name": "Venkataramana Gadhamshetty"
    },
  ];

  Future<void> _importProfessors() async {
    setState(() {
      _isImporting = true;
      _importedCount = 0;
      _totalCount = _professorsData.length;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance.collection('professors');

      for (int i = 0; i < _professorsData.length; i++) {
        final professor = _professorsData[i];
        final docRef = collection.doc();

        batch.set(docRef, {
          'name': professor['name'],
          'university': professor['university'],
          'department': 'Environmental Engineering', // Default department
          'created_at': FieldValue.serverTimestamp(),
          'imported': true,
        });

        // Commit in batches of 500 (Firestore limit)
        if ((i + 1) % 500 == 0 || i == _professorsData.length - 1) {
          await batch.commit();
          setState(() {
            _importedCount = i + 1;
          });

          // Small delay to avoid overwhelming Firestore
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $_totalCount professors!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing professors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _clearProfessors() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Professors'),
        content: const Text(
            'Are you sure you want to delete all professors? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final snapshot =
            await FirebaseFirestore.instance.collection('professors').get();
        final batch = FirebaseFirestore.instance.batch();

        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All professors deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting professors: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Import Professors'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.upload_file,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Import ${_professorsData.length} Professors',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will import all professors from the provided list into your Firestore database.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    if (_isImporting) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value:
                            _totalCount > 0 ? _importedCount / _totalCount : 0,
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Imported $_importedCount of $_totalCount professors'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isImporting ? null : _importProfessors,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isImporting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Importing...'),
                      ],
                    )
                  : const Text('Import All Professors'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _isImporting ? null : _clearProfessors,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Clear All Professors'),
            ),
            const Spacer(),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(height: 8),
                    Text(
                      'Note: Each professor will be imported with "Environmental Engineering" as the default department. You can edit individual professors later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
