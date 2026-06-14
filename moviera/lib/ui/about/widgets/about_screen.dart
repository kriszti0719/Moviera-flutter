import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 80, color: Colors.blueGrey),
            SizedBox(height: 24),
            Text(
              'Moviera Application',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 24),
            Text(
              'This application was developed as a university mobile development project. It implements a clean MVVM architecture leveraging Flutter, Firebase Authentication for session management, TMDB REST API for movie discovery, and sqflite for local data caching and offline tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}