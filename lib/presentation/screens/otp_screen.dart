import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:digitaledir/core/theme/app_theme.dart';
import 'package:digitaledir/core/providers/auth_provider.dart';
import 'package:digitaledir/presentation/widgets/custom_button.dart';

class OTPScreen extends StatefulWidget {
  final String? email;
  final String? phone;

  const OTPScreen({super.key, this.email, this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _otpSent = false;

  int _resendCooldown = 0;
  Timer? _timer;

  String? _requestId; // ✅ REQUIRED

  @override
  void initState() {
    super.initState();
    _requestOTP();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  // ===================== OTP REQUEST =====================
  Future<void> _requestOTP() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final response = await authProvider.requestOTP(
        method: widget.email != null ? 'email' : 'phone',
        value: widget.email ?? widget.phone!,
      );

      _requestId = response['requestId']; // ✅ STORE requestId

      setState(() {
        _isLoading = false;
        _otpSent = true;
      });

      _startResendCooldown();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    }
  }

  // ===================== RESEND TIMER =====================
  void _startResendCooldown() {
    _resendCooldown = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ===================== OTP VERIFY =====================
  Future<void> _verifyOTP() async {
    if (_requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP request not found. Please resend OTP.'),
        ),
      );
      return;
    }

    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final isAdminLogin = widget.email?.contains('admin') == true ||
          widget.phone?.contains('admin') == true;

      await authProvider.verifyOTP(
        requestId: _requestId!,
        otpCode: otp,
        isAdmin: isAdminLogin,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (_) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed: $e')),
      );
    }
  }

  // ===================== OTP INPUT HANDLER =====================
  void _handleOtpChange(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final contactInfo = widget.email ?? widget.phone ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),

            // Title
            const Text(
              'Enter Verification Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'We sent a 6-digit code to $contactInfo',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.greyColor,
              ),
            ),
            const SizedBox(height: 48),

            // OTP Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  height: 60,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    onChanged: (v) => _handleOtpChange(index, v),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Verify Button
            CustomButton(
              text: 'Verify OTP',
              onPressed: _verifyOTP,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),

            // Resend
            Column(
              children: [
                Text(
                  _resendCooldown > 0
                      ? 'Resend code in $_resendCooldown seconds'
                      : 'Didn’t receive the code?',
                  style: const TextStyle(color: AppTheme.greyColor),
                ),
                TextButton(
                  onPressed: _resendCooldown == 0 ? _requestOTP : null,
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _resendCooldown == 0
                          ? AppTheme.primaryColor
                          : AppTheme.greyColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Back
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16),
                  SizedBox(width: 8),
                  Text('Back to Login'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
