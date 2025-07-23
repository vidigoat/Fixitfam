import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Firebase removed for demo mode
// import 'firebase_auth_service.dart';

class PaymentService {
  late Razorpay _razorpay;
  // Firebase auth removed for demo mode
  // final FirebaseAuthService _authService = FirebaseAuthService();
  
  // Payment state tracking
  String? _currentPlanType;
  
  // TODO: Replace with your production Razorpay key
  static const String razorpayKeyId = 'rzp_live_your_key_id'; // Get from Razorpay Dashboard
  
  // TODO: Replace with your deployed backend URL
  static const String _baseUrl = 'https://your-backend-url.herokuapp.com'; // Update after backend deployment
  
  // Set to true for demo mode - NO REAL PAYMENTS
  static const bool isDemoMode = true; // DEMO MODE - NO REAL CHARGES
  
  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  Future<void> initiatePayment({
    required double amount,
    required String planType,
    required String userEmail,
    required String userName,
    String? userPhone,
  }) async {
    try {
      // Store plan type for later use
      _currentPlanType = planType;
      
      if (isDemoMode) {
        // Demo mode - simulate payment
        _simulatePayment(amount, planType, userEmail, userName);
        return;
      }
      
      // Real payment flow
      final order = await _createOrder(amount, planType);
      
      var options = {
        'key': razorpayKeyId,
        'amount': (amount * 100).toInt(), // Amount in paisa
        'order_id': order['orderId'],
        'name': 'FixitFam',
        'description': '$planType Subscription',
        'prefill': {
          'contact': userPhone ?? '',
          'email': userEmail,
        },
        'theme': {
          'color': '#6C63FF'
        },
        'notes': {
          'plan_type': planType,
          'user_email': userEmail,
        }
      };
      
      _razorpay.open(options);
    } catch (e) {
      _onPaymentError?.call('Payment initiation failed: $e');
    }
  }
  
  void _simulatePayment(double amount, String planType, String userEmail, String userName) {
    // Simulate payment delay
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        // Store the plan type for verification
        _currentPlanType = planType;
        
        // Create mock payment response with map format
        final mockResponse = PaymentSuccessResponse(
          'demo_payment_${DateTime.now().millisecondsSinceEpoch}',
          'demo_order_${DateTime.now().millisecondsSinceEpoch}',
          'demo_signature_${DateTime.now().millisecondsSinceEpoch}',
          null // wallet parameter
        );
        
        // Update subscription status
        await _updateSubscriptionStatus(planType, 'demo_payment_id');
        
        _onPaymentSuccess?.call(mockResponse);
      } catch (e) {
        _onPaymentError?.call('Demo payment failed: $e');
      }
    });
  }
  
  Future<Map<String, dynamic>> _createOrder(double amount, String planType) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'amount': amount,
          'planType': planType,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<String?> _getAuthToken() async {
    // Demo mode - no real auth token needed
    if (isDemoMode) {
      return 'demo_token_12345';
    }
    
    try {
      // Will be restored for production with Firebase
      return 'demo_token_12345';
    } catch (e) {
      print('Error getting auth token: $e');
    }
    return null;
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      if (isDemoMode) {
        _onPaymentSuccess?.call(response);
        return;
      }
      
      // Verify payment on backend
      final verification = await _verifyPayment(
        response.orderId!,
        response.paymentId!,
        response.signature!,
      );
      
      if (verification['status'] == 'success') {
        // Payment successful
        await _updateSubscriptionStatus(
          verification['plan_type'] ?? 'unknown',
          response.paymentId!,
        );
        _onPaymentSuccess?.call(response);
      } else {
        _onPaymentError?.call('Payment verification failed');
      }
    } catch (e) {
      _onPaymentError?.call('Payment verification error: $e');
    }
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    String errorMessage = 'Payment failed';
    
    if (response.code != null) {
      switch (response.code) {
        case Razorpay.PAYMENT_CANCELLED:
          errorMessage = 'Payment was cancelled';
          break;
        case Razorpay.NETWORK_ERROR:
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = response.message ?? 'Payment failed';
      }
    }
    
    _onPaymentError?.call(errorMessage);
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    _onPaymentError?.call('External wallet payments are not supported yet');
  }
  
  Future<Map<String, dynamic>> _verifyPayment(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'orderId': orderId,
          'paymentId': paymentId,
          'signature': signature,
          'planType': _currentPlanType ?? 'monthly',
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Verification error: $e');
    }
  }
  
  Future<void> _updateSubscriptionStatus(String planType, String paymentId) async {
    try {
      final bool isPremium = planType != 'free';
      
      // Demo mode - update locally only
      if (isDemoMode) {
        print('✅ Demo: Updated subscription to $planType (isPremium: $isPremium)');
        // Save to local storage for demo
        // In production, this will update Firebase user profile
        return;
      }
      
      // Production: will use Firebase auth service
      // await _authService.updatePremiumStatus(isPremium, planType);
      
    } catch (e) {
      print('Error updating subscription status: $e');
      throw Exception('Failed to update subscription');
    }
  }
  
  // Check subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      if (isDemoMode) {
        // Demo mode - return demo premium status
        return {
          'isPremium': true, // Demo shows premium features
          'subscriptionType': 'premium_annual',
          'status': 'active',
        };
      }
      
      // Production: will use Firebase auth service
      // final user = await _authService.getCurrentUser();
      // if (user != null) {
      //   return {
      //     'isPremium': user.isPremium,
      //     'subscriptionType': user.subscriptionType,
      //     'status': user.isPremium ? 'active' : 'inactive',
      //   };
      // }
      
      return {
        'isPremium': false,
        'subscriptionType': 'free',
        'status': 'inactive',
      };
    } catch (e) {
      print('Error getting subscription status: $e');
      return {
        'isPremium': false,
        'subscriptionType': 'free',
        'status': 'inactive',
      };
    }
  }
  
  // Cancel subscription (demo version)
  Future<void> cancelSubscription() async {
    try {
      if (isDemoMode) {
        print('🚫 Demo: Subscription cancelled');
        _onSubscriptionCancelled?.call();
        return;
      }
      
      // Production: will use Firebase auth service
      // await _authService.updatePremiumStatus(false, 'free');
      _onSubscriptionCancelled?.call();
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }
  
  // Payment plans configuration
  static const Map<String, Map<String, dynamic>> paymentPlans = {
    'monthly': {
      'amount': 99.0,
      'currency': 'INR',
      'period': 'month',
      'description': 'Monthly Premium Plan',
      'features': [
        'Unlimited FamBot messages',
        'Advanced SmartBudget features',
        'TripMode access',
        'Premium FamilyCare tools',
        'Priority support',
      ],
    },
    'yearly': {
      'amount': 999.0,
      'currency': 'INR',
      'period': 'year',
      'description': 'Yearly Premium Plan',
      'savings': '₹189 saved vs monthly',
      'features': [
        'All monthly features',
        'Family sharing (up to 6 members)',
        'Advanced analytics',
        'Data export',
        '24/7 premium support',
      ],
    },
  };
  
  // Get plan details
  static Map<String, dynamic>? getPlanDetails(String planType) {
    return paymentPlans[planType];
  }
  
  // Callbacks
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(String)? _onPaymentError;
  Function()? _onSubscriptionCancelled;
  
  void setPaymentCallbacks({
    Function(PaymentSuccessResponse)? onSuccess,
    Function(String)? onError,
    Function()? onSubscriptionCancelled,
  }) {
    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;
    _onSubscriptionCancelled = onSubscriptionCancelled;
  }
  
  void dispose() {
    _razorpay.clear();
  }
}

// Helper class for payment plans
class PaymentPlan {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final String period;
  final String description;
  final List<String> features;
  final String? savings;
  
  PaymentPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.period,
    required this.description,
    required this.features,
    this.savings,
  });
  
  factory PaymentPlan.fromMap(String id, Map<String, dynamic> map) {
    return PaymentPlan(
      id: id,
      name: map['name'] ?? id,
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'INR',
      period: map['period'] ?? 'month',
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      savings: map['savings'],
    );
  }
  
  String get formattedAmount => '₹${amount.toInt()}';
  String get formattedPeriod => '/$period';
  String get fullPrice => '$formattedAmount$formattedPeriod';
}
