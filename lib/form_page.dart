import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPage extends StatefulWidget {
  final String? professorName;
  final String? professorEmail;
  final bool isUpdate;
  final Map<String, dynamic>? existingData;
  final String? documentId;

  const FormPage({
    super.key,
    this.professorName,
    this.professorEmail,
    this.isUpdate = false,
    this.existingData,
    this.documentId,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hookTextController = TextEditingController();
  final _emailController = TextEditingController();
  final _publicationTitleController = TextEditingController();
  final _publicationYearController = TextEditingController();
  final _journalNameController = TextEditingController();

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill form if data is provided
    if (widget.professorName != null) {
      _nameController.text = widget.professorName!;
    }

    if (widget.professorEmail != null) {
      _emailController.text = widget.professorEmail!;
    }

    if (widget.existingData != null) {
      final data = widget.existingData!;
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _hookTextController.text = data['hook_text'] ?? '';
      _publicationTitleController.text = data['publication_title'] ?? '';
      _publicationYearController.text = data['publication_year'] ?? '';
      _journalNameController.text = data['journal_name'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hookTextController.dispose();
    _emailController.dispose();
    _publicationTitleController.dispose();
    _publicationYearController.dispose();
    _journalNameController.dispose();
    super.dispose();
  }

  Future<void> _uploadData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      if (widget.isUpdate && widget.documentId != null) {
        // Update existing document
        await FirebaseFirestore.instance
            .collection('cold_email_data')
            .doc(widget.documentId)
            .update({
          'name': _nameController.text.trim(),
          'hook_text': _hookTextController.text.trim(),
          'email': _emailController.text.trim(),
          'publication_title': _publicationTitleController.text.trim(),
          'publication_year': _publicationYearController.text.trim(),
          'journal_name': _journalNameController.text.trim(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document
        await FirebaseFirestore.instance.collection('cold_email_data').add({
          'name': _nameController.text.trim(),
          'hook_text': _hookTextController.text.trim(),
          'email': _emailController.text.trim(),
          'publication_title': _publicationTitleController.text.trim(),
          'publication_year': _publicationYearController.text.trim(),
          'journal_name': _journalNameController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Clear form after successful upload/update (only if not updating)
      if (!widget.isUpdate) {
        _nameController.clear();
        _hookTextController.clear();
        _emailController.clear();
        _publicationTitleController.clear();
        _publicationYearController.clear();
        _journalNameController.clear();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isUpdate
                ? 'Data updated successfully!'
                : 'Data uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back after successful update/upload
        if (widget.isUpdate) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isUpdate ? 'Update Cold Email Data' : 'Cold Email Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hookTextController,
                        decoration: const InputDecoration(
                          labelText: 'Hook Text',
                          border: OutlineInputBorder(),
                          hintText: 'Enter compelling opening text',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter hook text';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _publicationTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Publication Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter publication title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _publicationYearController,
                        decoration: const InputDecoration(
                          labelText: 'Publication Year',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter publication year';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _journalNameController,
                        decoration: const InputDecoration(
                          labelText: 'Journal Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter journal name';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadData,
                  child: _isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('Uploading...'),
                          ],
                        )
                      : Text(widget.isUpdate
                          ? 'Update Cold Email Data'
                          : 'Save Cold Email Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
