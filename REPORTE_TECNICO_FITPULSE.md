# 📋 REPORTE TÉCNICO DE PROYECTO: FITPULSE CLUB & PRO SHOP

**Institución / Curso:** Desarrollo de Aplicaciones Móviles Avanzadas  
**Nombre del Proyecto:** FitPulse – Ecosistema Integral de Fitness, Telemetría y Comercio Electrónico  
**Autora:** Natalia Villagómez Sancén (`NatSan31`)  
**Repositorio Oficial en GitHub:** [https://github.com/NatSan31/Mov](https://github.com/NatSan31/Mov)  
**Tecnología Principal:** Flutter SDK 3.x / Dart / Firebase Suite / Sensores Nativos  

---

## 1. Planteamiento de la Problemática y Alcance

### 1.1 Planteamiento de la Problemática
En la actualidad, las personas que asisten a clubes de entrenamiento y gimnasios enfrentan una experiencia fragmentada: utilizan una aplicación para ingresar a las instalaciones, otra diferente para monitorear su actividad física o pulsaciones cardíacas, herramientas externas de mapas para localizar sedes cercanas, y tiendas electrónicas independientes para adquirir suplementos o renovar membresías. Esta dispersión genera una alta fricción de uso, pérdida de datos biométricos y abandono del hábito de entrenamiento.

### 1.2 Objetivo General
Diseñar, estructurar e implementar una aplicación móvil integral denominada **FitPulse**, construida bajo una arquitectura limpia y reactiva en Flutter, que unifique la gestión de membresías digitales, la telemetría biométrica mediante sensores de hardware, la geolocalización nativa de sucursales con cálculo de rutas, y un módulo transaccional seguro con sincronización en tiempo real a través de los servicios de Google Firebase.

### 1.3 Alcance del Proyecto
* **Autenticación Multi-proveedor:** Registro e inicio de sesión con correo y contraseña (con verificación estricta obligatoria), así como proveedores OAuth (Google Sign-In y GitHub).
* **Gestión de Perfil y Almacenamiento en la Nube:** Almacenamiento y sincronización de fotografías en Firebase Storage con reglas de restricción de edición exclusivas para cuentas de correo.
* **Persistencia en Tiempo Real:** Base de datos NoSQL con Cloud Firestore para catálogos de productos, registro de transacciones, sedes físicas y perfiles de atletas.
* **Sistema de Notificaciones Push:** Firebase Cloud Messaging (FCM) con escuchador global y canales temáticos (*Topics*).
* **Sensores de Hardware:** Integración de acelerómetro en tiempo real para estimación de intensidad motriz, algoritmo de detección de agitación (*shake reward*) y confirmación biométrica con lector de huella dactilar/rostro (*local_auth*).
* **Geolocalización Nativa:** Visualización sobre OpenStreetMap sin visores web, cálculo euclidiano de distancias y motor de trazado de la ruta más rápida (vehicular y peatonal).
* **Módulo Transaccional:** Pasarela de pago simulada con validación de tarjetas bancarias mediante el algoritmo de Luhn, recibo fiscal digital y seguimiento de paquetería en tiempo real.

---

## 2. Arquitectura de Software y Manejo de Estado

### 2.1 Patrón Arquitectónico (Clean Architecture)
El proyecto se organizó bajo una separación estricta de responsabilidades en capas desacopladas dentro del directorio `lib/`:

```text
lib/
├── core/                  # Componentes transversales
│   ├── constants/         # AppColors, AppTheme (Material 3), AppConstants
│   ├── services/          # FirebaseService, FCMService, BiometricService, SensorService, LocationService
│   └── utils/             # CreditCardValidator (Luhn), ResponsiveLayout
├── models/                # Modelos de dominio inmutables (User, Product, CartItem, GymLocation, Order, etc.)
├── providers/             # Manejadores de estado reactivos (ChangeNotifier / Provider)
├── views/                 # Pantallas de la aplicación (Auth, Dashboard, Shop, Map, Subscriptions, Admin)
└── widgets/               # Componentes UI reutilizables e innovaciones visuales
```

### 2.2 Manejo de Estado Reactivo (Estricto)
En estricto cumplimiento con la normativa de la actividad, **se eliminó por completo el uso de `setState` y `ValueNotifier` en todas las pantallas y formularios**. El flujo de datos y la mutación de estado se rigen exclusivamente bajo el patrón **Provider**:
* `AuthProvider`: Orquesta el ciclo de vida de autenticación, recarga de verificación de correo en Firebase y sesión activa.
* `ProductsProvider`: Mantiene el stream reactivo de productos desde Firestore y gestiona filtros y búsqueda.
* `CartProvider`: Administra el carrito de compras, cupones de descuento y persistencia de órdenes.
* `LocationsProvider`: Gestiona el GPS, ordenamiento de clubes por cercanía y cálculo de la polilínea de ruta.
* `SensorProvider`: Conecta el flujo del acelerómetro físico para alimentar el radar biométrico.
* `ThemeProvider`: Controla el cambio dinámico entre Modo Claro y Modo Oscuro.

---

## 3. Integración de Servicios de Firebase

| Servicio | Implementación Técnica |
| :--- | :--- |
| **Firebase Authentication** | Inicio de sesión con Email/Password, Google Sign-In y GitHub OAuth. Verificación obligatoria vía `sendEmailVerification()` antes de otorgar acceso. |
| **Cloud Firestore** | Colecciones en tiempo real: `users`, `products`, `gym_locations` y `orders`. Cuenta con auto-sembrado (*auto-seeding*) automático al iniciar. |
| **Firebase Storage** | Subida y alojamiento de imágenes en `profile_pictures/{userId}.jpg` mediante `image_picker` (cámara y galería). |
| **Cloud Messaging (FCM)** | Escuchador global de notificaciones push en primer plano, segundo plano y app cerrada con suscripción a tópicos (*promociones*, *novedades*, *eventos*). |

---

## 4. Hardware, Sensores y Geolocalización

### 4.1 Acelerómetro y Detección de Agitación (Shake to Reward)
A través del paquete `sensors_plus`, la app captura eventos de aceleración `(x, y, z)` a alta frecuencia. Mediante el cálculo del vector de magnitud $\sqrt{x^2 + y^2 + z^2}$, se calcula el porcentaje de intensidad física del usuario, el cual alimenta el radar interactivo. Cuando el usuario agita su dispositivo superando el umbral de movimiento, se activa el diálogo de recompensa (*ShakeRewardDialog*) otorgando un cupón del 15% de descuento.

### 4.2 Seguridad Biométrica Nativa (`local_auth`)
Para garantizar la autenticidad en transacciones y compras en la tienda, se integró el lector biométrico del dispositivo (huella dactilar o reconocimiento facial), requiriendo la confirmación del atleta previo al cargo de su tarjeta.

### 4.3 Geolocalización y Trazado de Rutas Nativas
Utilizando `geolocator` y `flutter_map`, la aplicación lee las coordenadas GPS reales del teléfono y las proyecta en un mapa nativo. Al seleccionar cualquier sucursal, el motor calcula la distancia en kilómetros, el tiempo estimado en vehículo (a velocidad urbana promedio) y a pie, trazando una polilínea cian neón sobre las avenidas principales.

---

## 5. Módulo Transaccional, Pasarela de Pagos y Rastreo

* **Validación Algorítmica de Tarjetas (Luhn):** La pantalla de pago implementa el algoritmo de Luhn módulo 10 para comprobar la validez matemática del número de tarjeta antes de enviar la transacción.
* **Modelos de Venta:** Soporta venta minorista de suplementos deportivos y sistema de suscripciones recurrentes con 3 planes diferenciados (*Smart Basic*, *Pro Athlete*, *Black VIP Club*).
* **Comprobante Fiscal y Rastreo en Vivo:** Al aprobarse el pago, se genera un ticket digital con folio UUID e impuestos desglosados (IVA 16%), acompañado de una línea de tiempo con el estado de entrega del repartidor en tiempo real.

---

## 6. Innovación en UI / UX (10% de la Calificación)

* **Radar Biométrico Personalizado (`FitnessPulseRadar`):** Diseñado desde cero utilizando `CustomPainter`, dibujando anillos concéntricos graduados, cuadrantes angulares y un arco dinámico de degradado cian-púrpura que oscila en tiempo real según el movimiento del acelerómetro.
* **Credencial Digital Glassmórfica (`GlassMembershipCard`):** Tarjeta de miembro con efecto de desenfoque de fondo (*BackdropFilter*), chip NFC simulado y código QR dinámico.

---

## 7. Conclusiones
La aplicación **FitPulse** demuestra la convergencia exitosa entre la arquitectura móvil moderna, los servicios en la nube de Google Firebase y las capacidades de hardware del teléfono inteligente. Se logró una experiencia de usuario fluida, reactiva y libre de fallos, garantizando el cumplimiento riguroso de cada uno de los lineamientos técnicos y de evaluación establecidos para la práctica.
