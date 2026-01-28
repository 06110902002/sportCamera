import 'package:flutter/material.dart';

class LoginFailPage extends StatelessWidget {
  const LoginFailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录失败'),
        automaticallyImplyLeading: false, // Hide the back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('登录失败，请重试'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Go back to the login page
                Navigator.pop(context);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
