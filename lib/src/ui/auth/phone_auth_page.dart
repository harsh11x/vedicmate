import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'otp_page.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  void _sendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Enter phone number');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.signInWithPhone(phone, (verificationId, token) {
        setState(() {
          _loading = false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (_) => OtpPage(verificationId: verificationId,)));
      }, (err) {
        setState(() {
          _loading = false;
          _error = err.message;
        });
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in with phone')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(prefixText: '+91 ', labelText: 'Phone number'),
            ),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _sendCode,
              child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
