import 'dart:async';
import 'package:flutter/material.dart';

/// 倒计时单独封装为一个组件，减少页面重绘范围，提升性能
class VerificationCodeButton extends StatefulWidget {
  /// Callback triggered when the button is pressed and not in countdown mode.
  final VoidCallback onSendCode;

  const VerificationCodeButton({
    super.key,
    required this.onSendCode,
  });

  @override
  _VerificationCodeButtonState createState() => _VerificationCodeButtonState();
}

class _VerificationCodeButtonState extends State<VerificationCodeButton> {
  bool _isCountingDown = false;
  int _countdown = 60;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (!mounted) return;
    setState(() {
      _isCountingDown = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          _isCountingDown = false;
          _countdown = 60;
          _timer?.cancel();
        }
      });
    });
  }

  void _onPressed() {
    // Do nothing if already counting down.
    if (_isCountingDown) {
      return;
    }
    // Trigger the callback provided by the parent widget.
    widget.onSendCode();
    // Start the countdown.
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: TextButton(
        // Disable the button press if it's counting down.
        onPressed: _isCountingDown ? null : _onPressed,
        child: Text(
          _isCountingDown ? '重新发送($_countdown)' : '发送验证码',
        ),
      ),
    );
  }
}
