import 'package:flutter/material.dart';
import '../models/subscription_plan_model.dart';
import 'auth_provider.dart';

enum BillingCycle { monthly, yearly }

class SubscriptionProvider extends ChangeNotifier {
  final List<SubscriptionPlanModel> _plans = SubscriptionPlanModel.getDefaultPlans();
  List<SubscriptionPlanModel> get plans => _plans;

  SubscriptionPlanModel _selectedPlan = SubscriptionPlanModel.getDefaultPlans()[1]; // Pro por defecto
  SubscriptionPlanModel get selectedPlan => _selectedPlan;

  BillingCycle _billingCycle = BillingCycle.monthly;
  BillingCycle get billingCycle => _billingCycle;

  bool _isProcessingSubscription = false;
  bool get isProcessingSubscription => _isProcessingSubscription;

  void selectPlan(SubscriptionPlanModel plan) {
    if (_selectedPlan.id != plan.id) {
      _selectedPlan = plan;
      notifyListeners();
    }
  }

  void setBillingCycle(BillingCycle cycle) {
    if (_billingCycle != cycle) {
      _billingCycle = cycle;
      notifyListeners();
    }
  }

  double get currentPlanPrice => _billingCycle == BillingCycle.monthly
      ? _selectedPlan.priceMonthly
      : _selectedPlan.priceYearly;

  Future<bool> subscribe({
    required AuthProvider authProvider,
    required String cardLast4,
    required String cardBrand,
  }) async {
    _isProcessingSubscription = true;
    notifyListeners();

    try {
      // Simulación de transacción de suscripción recurrente con Stripe/RevenueCat
      await Future.delayed(const Duration(seconds: 2));

      // Actualizar tier del usuario en Firestore y en la sesión activa
      authProvider.updateSubscriptionTier(_selectedPlan.id);

      _isProcessingSubscription = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessingSubscription = false;
      notifyListeners();
      return false;
    }
  }
}
