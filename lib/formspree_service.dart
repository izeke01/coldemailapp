import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormspreeService {
  // Your Formspree form endpoint - get from formspree.io
  static const String _formspreeEndpoint =
      'https://formspree.io/f/your_form_id';

  static Future<bool> sendEmailWithAttachments({
    required String recipientEmail,
    required String subject,
    required String body,
    required String senderName,
  }) async {
    try {
      print('Sending email via Formspree (web-compatible)...');

      // Load PDF attachments as base64
      final attachments = await _loadPDFAttachmentsAsBase64();

      // Prepare form data
      final formData = {
        'email': recipientEmail,
        'subject': subject,
        'message': body,
        'sender_name': senderName,
        'cv_attachment': attachments['cv'] ?? '',
        'transcript_attachment': attachments['transcript'] ?? '',
        '_replyto': 'isaacenuma@gmail.com',
        '_subject': subject,
      };

      // Send via Formspree
      final response = await http.post(
        Uri.parse(_formspreeEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        print('Email sent successfully via Formspree!');
        return true;
      } else {
        print('Formspree Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending email via Formspree: $e');
      return false;
    }
  }

  static Future<Map<String, String?>> _loadPDFAttachmentsAsBase64() async {
    String? cvBase64;
    String? transcriptBase64;

    try {
      // Load CV
      final cvData = await rootBundle.load('assets/pdfs/Isaac Enuma CV.pdf');
      final cvBytes = cvData.buffer.asUint8List();
      cvBase64 = base64Encode(cvBytes);
      print('CV loaded and encoded');
    } catch (e) {
      print('Error loading CV: $e');
    }

    try {
      // Load Transcript
      final transcriptData =
          await rootBundle.load('assets/pdfs/ISAAC ENUMA TRANSCRIPT.pdf');
      final transcriptBytes = transcriptData.buffer.asUint8List();
      transcriptBase64 = base64Encode(transcriptBytes);
      print('Transcript loaded and encoded');
    } catch (e) {
      print('Error loading transcript: $e');
    }

    return {
      'cv': cvBase64,
      'transcript': transcriptBase64,
    };
  }

  // Test Formspree connection
  static Future<bool> testConnection() async {
    try {
      return await sendEmailWithAttachments(
        recipientEmail: 'isaacenuma@gmail.com',
        subject: 'Test Email - Cold Email App via Formspree',
        body:
            'This is a test email from your Cold Email App using Formspree - works on web!',
        senderName: 'Isaac Enuma',
      );
    } catch (e) {
      print('Formspree test failed: $e');
      return false;
    }
  }
}
