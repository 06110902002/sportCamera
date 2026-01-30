import 'package:flutter/material.dart';

/// A login button that manages its own loading state.
class LoginButton extends StatefulWidget {
  /// An asynchronous function to be executed when the button is pressed.
  final Future<void> Function() onPressed;

  /// A boolean to determine if the login button should be enabled.
  final bool canLogin;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.canLogin,
  });

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isLoading = false;

  void _handlePressed() async {
    // Prevent multiple presses while loading.
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Execute the async task.
      await widget.onPressed();
    } finally {
      // Ensure the loading state is updated even if an error occurs.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        // Disable the button if it can't be pressed or if it's loading.
        onPressed: (widget.canLogin && !_isLoading) ? _handlePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.canLogin ? Colors.blue : Colors.grey[300],
          foregroundColor: widget.canLogin ? Colors.white : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Set a minimum size to prevent layout shifts when loading.
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('登录'),
      ),
    );
  }
}
