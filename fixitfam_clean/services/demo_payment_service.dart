import 'package:flutter/material.dart';
import 'dart:async';

class DemoPaymentService {
  // Demo payment service that works without Razorpay account
  
  Future<Map<String, dynamic>> initiatePayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String description,
    String? email,
    String? phone,
    String? planType,
  }) async {
    
    // Show payment UI
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaymentDialog(
        amount: amount,
        currency: currency,
        description: description,
        planType: planType ?? 'Premium',
      ),
    );
    
    return result ?? {
      'success': false,
      'error': 'Payment cancelled by user',
    };
  }
  
  Future<bool> verifyPayment(String paymentId) async {
    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 1));
    return true; // Always successful in demo
  }
  
  String generatePaymentId() {
    return 'demo_pay_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  String generateOrderId() {
    return 'demo_order_${DateTime.now().millisecondsSinceEpoch}';
  }
}

class _PaymentDialog extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final String planType;
  
  const _PaymentDialog({
    required this.amount,
    required this.currency,
    required this.description,
    required this.planType,
  });
  
  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> 
    with SingleTickerProviderStateMixin {
  
  bool _isProcessing = false;
  String _selectedMethod = 'card';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_animationController);
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payment, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Demo Payment Gateway',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white60),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Plan Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.planType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '${widget.currency} ${widget.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Payment Methods (Demo)
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildPaymentMethod(
                'card',
                'Credit/Debit Card',
                Icons.credit_card,
                'Visa, Mastercard, RuPay',
              ),
              const SizedBox(height: 8),
              _buildPaymentMethod(
                'upi',
                'UPI',
                Icons.account_balance,
                'Google Pay, PhonePe, Paytm',
              ),
              const SizedBox(height: 8),
              _buildPaymentMethod(
                'netbanking',
                'Net Banking',
                Icons.account_balance_wallet,
                'All major banks',
              ),
              
              const SizedBox(height: 24),
              
              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Pay ₹${widget.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Security Note
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Demo Mode - No actual payment required',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethod(String value, String title, IconData icon, String subtitle) {
    bool isSelected = _selectedMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.2) : const Color(0xFF2A2A40),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white60,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate demo payment data
    final paymentResult = {
      'success': true,
      'payment_id': 'demo_pay_${DateTime.now().millisecondsSinceEpoch}',
      'order_id': 'demo_order_${DateTime.now().millisecondsSinceEpoch}',
      'amount': widget.amount,
      'currency': widget.currency,
      'status': 'captured',
      'method': _selectedMethod,
      'timestamp': DateTime.now().toIso8601String(),
      'description': widget.description,
    };
    
    Navigator.pop(context, paymentResult);
  }
}
