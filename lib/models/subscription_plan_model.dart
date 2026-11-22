class SubscriptionPlanModel {
  final String id; // 'basic', 'pro', 'black_vip'
  final String name;
  final String tagline;
  final double priceMonthly;
  final double priceYearly;
  final List<String> benefits;
  final bool isPopular;
  final int accessLevel; // 1: 1 club, 2: regional, 3: global/todos

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.priceMonthly,
    required this.priceYearly,
    required this.benefits,
    this.isPopular = false,
    required this.accessLevel,
  });

  static List<SubscriptionPlanModel> getDefaultPlans() {
    return [
      SubscriptionPlanModel(
        id: 'basic',
        name: 'Plan Smart Basic',
        tagline: 'Ideal para iniciar tu transformación física.',
        priceMonthly: 19.99,
        priceYearly: 199.99,
        accessLevel: 1,
        benefits: [
          'Acceso a tu club sede elegido',
          'Área de pesas y cardio ilimitada',
          'App FitPulse con seguimiento básico',
          'Casillero estándar de uso diario',
        ],
      ),
      SubscriptionPlanModel(
        id: 'pro',
        name: 'Plan Pro Performance',
        tagline: 'El favorito de los atletas dedicados.',
        priceMonthly: 39.99,
        priceYearly: 399.99,
        isPopular: true,
        accessLevel: 2,
        benefits: [
          'Acceso a todos los clubes a nivel nacional',
          'Clases grupales ilimitadas (Spinning, Yoga, CrossFit)',
          '1 Evaluación antropométrica mensual',
          '10% de descuento en Pro Shop de suplementos',
          'Acceso a zonas de sauna y vapor',
        ],
      ),
      SubscriptionPlanModel(
        id: 'black_vip',
        name: 'Black Elite VIP',
        tagline: 'Experiencia premium sin ningún límite.',
        priceMonthly: 69.99,
        priceYearly: 699.99,
        accessLevel: 3,
        benefits: [
          'Acceso VIP ilimitado global (todas las sedes)',
          'Entrenador personal 2 sesiones semanales',
          'Invitación ilimitada para 1 amigo por visita',
          'Sillones de hidromasaje y recuperación deportiva',
          '20% de descuento en Pro Shop y cafetería',
          'Kit de bienvenida exclusivo FitPulse VIP',
        ],
      ),
    ];
  }
}
