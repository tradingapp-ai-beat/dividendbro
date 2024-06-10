import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'At DividendBeat, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your personal information in accordance with the General Data Protection Regulation (GDPR) and other relevant privacy laws.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'Information We Collect',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'We collect personal information that you provide to us directly, such as when you create an account, use our services, or communicate with us. This information may include your name, email address, and payment information.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'How We Use Your Information',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'We use your personal information to provide and improve our services, process transactions, communicate with you, and comply with legal obligations. We may also use your information for marketing purposes with your consent.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'Data Protection Rights',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Under the GDPR, you have the right to access, rectify, or erase your personal data. You also have the right to restrict or object to certain processing of your data, and to data portability. If you wish to exercise any of these rights, please contact us at support@dividendbeat.com.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'Data Security',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction. However, please be aware that no security measures are completely foolproof.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'Third-Party Services',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'We may share your information with third-party service providers who assist us in providing our services. These third parties are obligated to protect your information and use it only for the purposes for which it was disclosed.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'Changes to This Policy',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new policy on our website. Your continued use of our services after the changes take effect constitutes acceptance of the new policy.',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Text(
                'Contact Us',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at support@dividendbeat.com.',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
