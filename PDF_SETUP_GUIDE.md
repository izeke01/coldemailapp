# PDF File Setup Guide

## 📁 File Structure
Create this folder structure in your Flutter project:

```
c:\Users\Blue Plus\coldemailapp\
├── assets/
│   └── pdfs/
│       ├── CV_Isaac_Enuma.pdf
│       └── Transcript_Isaac_Enuma.pdf
└── lib/
    └── (your flutter files)
```

## 📋 Setup Steps:

1. **Create assets folder** in your project root
2. **Create pdfs subfolder** inside assets
3. **Place your PDF files** with these exact names:
   - `CV_Isaac_Enuma.pdf`
   - `Transcript_Isaac_Enuma.pdf`

## 🔧 Alternative Custom Paths:
You can also specify custom paths when calling the service:

```dart
GmailSMTPService.sendEmailWithDefaultAttachments(
  recipientEmail: email,
  subject: subject,
  body: body,
  cvPath: 'C:/path/to/your/cv.pdf',
  transcriptPath: 'C:/path/to/your/transcript.pdf',
);
```

## ✅ Ready to Use:
Once files are in place, the "Send Direct" button will automatically attach both PDFs to your emails from the assets folder!

## 📧 Email Method Used:
The app now uses `sendEmailWithAssetAttachments()` which loads PDFs directly from Flutter assets.