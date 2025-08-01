import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class GmailSMTPService {
  static const String _email = 'isaacenuma@gmail.com';
  static const String _appPassword =
      'eyrs cuae itmb iasd'; // Replace with your actual app password

  static Future<bool> sendEmailWithAttachments({
    required String recipientEmail,
    required String subject,
    required String body,
    required String senderName,
  }) async {
    try {
      // Gmail SMTP configuration
      final smtpServer = gmail(_email, _appPassword);

      // Create message
      final message = Message()
        ..from = Address(_email, senderName)
        ..recipients.add(recipientEmail)
        ..subject = subject
        ..text = body
        ..html = body.replaceAll('\n', '<br>');

      // Load and attach PDFs
      await _attachPDFs(message);

      // Send email
      final sendReport = await send(message, smtpServer);
      print('Email sent successfully: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('Error sending email via Gmail SMTP: $e');
      return false;
    }
  }

  static Future<void> _attachPDFs(Message message) async {
    try {
      // Load CV
      final cvData = await rootBundle.load('assets/pdfs/Isaac Enuma CV.pdf');
      final cvBytes = cvData.buffer.asUint8List();

      message.attachments.add(StreamAttachment(
        Stream.fromIterable([cvBytes]),
        'Isaac Enuma CV.pdf',
      ));

      print('CV attached successfully');
    } catch (e) {
      print('Error loading CV: $e');
    }
  }

  // Test Gmail SMTP connection
  static Future<bool> testConnection() async {
    try {
      return await sendEmailWithAttachments(
        recipientEmail: _email, // Send test email to self
        subject: 'Test Email - Cold Email App via Gmail SMTP',
        body:
            'This is a test email from your Cold Email App using Gmail SMTP with app password.',
        senderName: 'Isaac Enuma',
      );
    } catch (e) {
      print('Gmail SMTP test failed: $e');
      return false;
    }
  }
}
