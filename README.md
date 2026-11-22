# FitPulse: Fitness Club & Pro Shop 🏋️‍♂️💳📍

> **Proyecto Final de Programación Móvil**  
> Aplicación integral multiplataforma desarrollada en **Flutter**, con arquitectura reactiva basada en **Provider**, persistencia y autenticación en la nube con **Firebase**, servicios nativos de hardware (**sensores de acelerómetro y biometría**), **geolocalización nativa con mapas** y una **pasarela de pagos nativa** con modelos transaccionales de venta de productos y planes de suscripción.

---

## 📋 Cumplimiento de Criterios y Requerimientos Técnicos

### 1. Definición del Proyecto y Alcance
* **Problemática**: Fragmentación en la experiencia de usuarios que practican deportes y acuden a gimnasios: necesidad de gestionar compras de suplementos deportivos, controlar membresías a diferentes clubes, monitorear actividad física con telemetría de sensores y ubicar sedes en mapas nativos.
* **Solución**: **FitPulse Club & Pro Shop**, un ecosistema unificado móvil y de escritorio con sincronización en tiempo real.

---

### 2. Integración de Servicios de Firebase
* **Firebase Storage**:
  * Gestión y almacenamiento de fotos de perfil (`profile_pictures/{uid}.jpg`).
  * Sincronización dinámica de avatares entre el dashboard principal y la sección de perfil de usuario.
  * **Restricción estricta de edición**: La modificación de foto de perfil está bloqueada para cuentas de terceros (Google/GitHub) y permitida **únicamente para cuentas registradas vía correo electrónico y contraseña**.
* **Firebase Database (Cloud Firestore)**:
  * Persistencia en tiempo real de usuarios (`users`), catálogo de suplementación (`products`), órdenes de compra (`orders`) y sedes deportivas.
* **Cloud Messaging (FCM - Notificaciones Push)**:
  * Gestión directa desde la consola de Firebase sin necesidad de backend propio.
  * **Escuchador global (listener)** implementado mediante `GlobalAppOverlayListener` activo en todas las pantallas de la app.
  * **Sistema de suscripción a temas (FCM Topics)**: Canales como `promociones`, `novedades`, `eventos_fitness` y `consejos_salud`.
  * **Soporte en los 3 estados del ciclo de vida**:
    1. *Primer plano (foreground)*: `FirebaseMessaging.onMessage` con banner in-app flotante.
    2. *Segundo plano (background)*: `_firebaseMessagingBackgroundHandler` con notificación nativa del sistema.
    3. *Cerrada (terminated)*: `FirebaseMessaging.instance.getInitialMessage()`.
* **Firebase Authentication**:
  * **Proveedores habilitados**:
    * Registro e inicio de sesión con Correo Electrónico y Contraseña.
    * Inicio de sesión social con Google (`google.com`).
    * Inicio de sesión social con GitHub (`github.com`).
  * **Mecanismos de verificación y seguridad**:
    * Validación obligatoria de correo electrónico previa al otorgamiento de acceso (`emailVerified`).
    * Opción para **reenviar el correo de confirmación de cuenta**.
    * Flujo completo de **recuperación de contraseña** (`sendPasswordResetEmail`).

---

### 3. Arquitectura, UI/UX y Manejo de Estado
* **Patrón de Estado**: Implementación integral mediante **Provider** (`ChangeNotifierProvider`, `Consumer`, `context.watch`, `context.read`).  
  ⚠️ **Cero uso de `setState` y `ValueNotifier`**, cumpliendo con la restricción estricta del curso.
* **Tipografía y Temas**: Integración de tipografía personalizada con `GoogleFonts.poppins` y soporte para **cambio dinámico de tema (Modo Claro / Modo Oscuro)** persistente en disco con `SharedPreferences`.
* **Onboarding**: Secuencia guiada de bienvenida con `PageView`, indicadores circulares animados y presentación de funciones clave.
* **Diseño Responsivo**: Adaptación responsiva mediante `ResponsiveLayout`:
  * En dispositivos móviles: `BottomNavigationBar` ergonómico.
  * En pantallas de escritorio / tablets: `NavigationRail` lateral expandido.
* **Innovación en UI (10% de la calificación)**:
  * `FitnessPulseRadar`: Widget avanzado con `CustomPainter` que dibuja un radar biométrico y tacómetro de aceleración reactivo en vivo a las fuerzas de movimiento.
  * `GlassMembershipCard`: Tarjeta de membresía interactiva con efecto Neumórfico / Glassmorphic 3D y chip de seguridad holográfico con credencialización según plan (Basic, Pro, Black VIP).
* **Persistencia y Caché**: Integración de `CachedNetworkImage` para almacenamiento local en caché de todas las imágenes de la tienda y avatares, permitiendo su visualización en ausencia de conexión a internet.

---

### 4. Hardware, Módulo Transaccional y Geolocalización
* **Integración de Sensores Nativos**:
  * **Lector Biométrico (`local_auth`)**: Autenticación rápida por huella dactilar o Face ID al ingresar a la app y autorización de segundo factor para transacciones de pago.
  * **Acelerómetro (`sensors_plus`)**: Detección de agitación (*Shake Detection*). Al agitar el teléfono, se activa un diálogo interactivo "Shake-to-Win" que otorga un cupón de 15% de descuento en la tienda Pro Shop (`FITPULSE15`).
* **Geolocalización Nativa**:
  * Pantalla con mapa nativo integrado (`flutter_map` con OpenStreetMap / tiles nativos), sin uso de visores web (WebViews).
  * Detección de ubicación GPS en tiempo real mediante `Geolocator`, cálculo matemático de distancias a las sedes y ordenamiento por cercanía.
* **Pasarela de Pagos / Suscripciones (15% de la calificación)**:
  * **Venta de productos**: Carrito de compras, desglose de subtotal, envío, aplicación de cupones ganados por sensor, generación de orden y recibo fiscal en Firestore.
  * **Sistema de suscripción**: 3 planes distintos (*Smart Basic*, *Pro Performance* y *Black Elite VIP*) con selector de periodicidad (facturación mensual o anual).
  * **Interfaz de pago**: Pantallas nativas estructuradas con validación segura de tarjeta de crédito/débito utilizando el **Algoritmo de Luhn (Módulo 10)**, fecha de vencimiento (MM/YY), CVV y detección automática del emisor (Visa, MasterCard, Amex).

---

## 📁 Estructura del Código Fuente

```
fitpulse_app/
├── lib/
│   ├── main.dart                               # Punto de entrada, MultiProvider y temas
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart                 # Paleta deportiva / de alto impacto
│   │   │   ├── app_constants.dart              # Nombres de colecciones y topics FCM
│   │   │   └── app_theme.dart                  # Configuración de Temas Claro y Oscuro
│   │   ├── utils/
│   │   │   ├── credit_card_validator.dart      # Algoritmo de Luhn y validación de tarjetas
│   │   │   └── responsive_layout.dart          # Breakpoints para Móvil y Desktop
│   │   └── services/
│   │       ├── firebase_service.dart           # Auth, Firestore y Storage
│   │       ├── fcm_service.dart                # Push notifications (3 estados de ciclo de vida)
│   │       ├── biometric_service.dart          # Lector de huella y Face ID
│   │       ├── sensor_service.dart             # Acelerómetro y Shake Detector
│   │       └── location_service.dart           # GPS y cálculo de distancias
│   ├── models/
│   │   ├── user_model.dart                     # Modelo de usuario con restricción de edición
│   │   ├── product_model.dart                  # Productos de la tienda Pro Shop
│   │   ├── subscription_plan_model.dart        # 3 planes de suscripción
│   │   ├── cart_item_model.dart                # Elementos del carrito
│   │   ├── order_model.dart                    # Transacciones y pedidos
│   │   └── gym_location_model.dart             # Sedes del club deportivo
│   ├── providers/
│   │   ├── theme_provider.dart                 # Gestión de modo claro/oscuro
│   │   ├── auth_provider.dart                  # Email, Google, GitHub, reset password
│   │   ├── onboarding_provider.dart            # Control de bienvenida guiada
│   │   ├── navigation_provider.dart            # Control de pestañas sin setState
│   │   ├── notification_provider.dart          # Suscripciones a FCM Topics y listener
│   │   ├── sensor_provider.dart                # Shake to win y telemetría de pasos
│   │   ├── products_provider.dart              # Catálogo y filtros en tiempo real
│   │   ├── cart_provider.dart                  # Carrito, cupones y checkout
│   │   ├── subscription_provider.dart          # Gestión de membresías
│   │   └── locations_provider.dart             # Sedes y proximidad GPS
│   ├── views/
│   │   ├── splash/                             # Pantalla de carga con verificación de sesión
│   │   ├── onboarding/                         # Introducción de 3 pasos
│   │   ├── auth/                               # Login, Register, Verify Email, Forgot Password
│   │   ├── dashboard/                          # Navegación responsiva y dashboard principal
│   │   ├── shop/                               # Catálogo, Detalle de producto y Carrito
│   │   ├── subscriptions/                      # Pantalla de los 3 planes de membresía
│   │   ├── checkout/                           # Formulario nativo de tarjeta con Luhn y biometría
│   │   ├── map/                                # Mapa nativo de sedes y geolocalización
│   │   ├── notifications/                      # Gestión de topics de Firebase Cloud Messaging
│   │   └── profile/                            # Perfil de usuario con restricción de foto
│   └── widgets/
│       ├── cached_network_image_wrapper.dart   # Caché offline de imágenes
│       ├── global_notification_listener.dart   # Escuchador global en todas las pantallas
│       ├── shake_reward_dialog.dart            # Diálogo emergente por acelerómetro
│       ├── custom_button.dart                  # Botón con estados de carga
│       ├── custom_text_field.dart              # Input estilizado con validaciones
│       └── ui_innovation/
│           ├── fitness_pulse_radar.dart        # Widget avanzado: Tacómetro y radar dinámico
│           └── glass_membership_card.dart      # Carnet digital Glassmorphic 3D
```

---

## 🚀 Instrucciones de Ejecución

1. Clona o abre el directorio del proyecto:
   ```bash
   cd fitpulse_app
   ```
2. Instala las dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. (Opcional) Conectar con tu propio proyecto de Firebase:
   * Coloca el archivo `google-services.json` en `android/app/`.
   * Coloca el archivo `GoogleService-Info.plist` en `ios/Runner/`.
   * *Nota: La aplicación incluye controladores con comportamiento defensivo e interactivo, por lo que puede ejecutarse y probarse incluso antes de enlazar los archivos de Firebase de producción.*
4. Ejecuta la aplicación:
   ```bash
   flutter run
   ```
