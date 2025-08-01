import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailJSService {
  // EmailJS configuration - you'll need to set these up at emailjs.com
  static const String _serviceId =
      'service_hj0gia4'; // Replace with your service ID
  static const String _templateId =
      'template_hms2jpq'; // Replace with your template ID
  static const String _publicKey =
      '9CadlFj-8fo9ylIkj'; // Replace with your public key
  static const String _privateKey =
      '6gtk49GYU2arDl-73hk4f'; // Replace with your private key

  static Future<bool> sendEmailWithAttachments({
    required String recipientEmail,
    required String subject,
    required String body,
    required String senderName,
  }) async {
    try {
      // Load CV attachment as base64
      final cvBase64 = await _loadCVAsBase64();

      // EmailJS endpoint
      const url = 'https://api.emailjs.com/api/v1.0/email/send';

      // Prepare email data with template parameters
      final emailData = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'accessToken': _privateKey,
        'template_params': {
          'to_email': recipientEmail,
          'to_name': _extractProfessorName(body),
          'from_name': 'Isaac Enuma',
          'university': _extractUniversity(body),
          'message': body,
          'reply_to': 'isaacenuma@gmail.com',
        }
      };

      // Send email via EmailJS
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(emailData),
      );

      if (response.statusCode == 200) {
        print('Email sent successfully via EmailJS!');
        return true;
      } else {
        print('EmailJS Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending email via EmailJS: $e');
      return false;
    }
  }

  static Future<String?> _loadCVAsBase64() async {
    try {
      // Load CV and convert to base64
      final cvData = await rootBundle.load('assets/pdfs/Isaac Enuma CV.pdf');
      final cvBytes = cvData.buffer.asUint8List();
      final cvBase64 = base64Encode(cvBytes);
      print('CV loaded and encoded for EmailJS');
      return cvBase64;
    } catch (e) {
      print('Error loading CV: $e');
      return null;
    }
  }

  // Helper function to extract professor name from email body
  static String _extractProfessorName(String body) {
    try {
      final match = RegExp(r'Dear Professor (.+?),').firstMatch(body);
      return match?.group(1) ?? 'Professor';
    } catch (e) {
      return 'Professor';
    }
  }

  // Helper function to extract university from email body
  static String _extractUniversity(String body) {
    try {
      final match = RegExp(r'PhD at (.+?) in').firstMatch(body);
      return match?.group(1) ?? 'University';
    } catch (e) {
      return 'University';
    }
  }

  // Test EmailJS connection
  static Future<bool> testConnection() async {
    try {
      return await sendEmailWithAttachments(
        recipientEmail: 'isaacenuma@gmail.com',
        subject: 'Test Email - Cold Email App via EmailJS',
        body:
            'Dear Professor Test,\n\nThis is a test email from your Cold Email App using EmailJS - works on web!\n\nI am interested in pursuing a PhD at Test University in the Fall 2026 semester.',
        senderName: 'Isaac Enuma',
      );
    } catch (e) {
      print('EmailJS test failed: $e');
      return false;
    }
  }
}
