# Dorado Exchange — Flutter Challenge

**Diseñado y desarrollado por Oscar Crescente**
`29 Abril 2026 · www.crescente.dev`

---

## Cómo correr el proyecto

**Requisitos:**
- Flutter SDK `>=3.8.1` — [instalar Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.8.1` (incluido con Flutter)
- Android Studio / Xcode según la plataforma objetivo

**Pasos:**

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd doradotest/dorado_challenge

# 2. Instalar dependencias
flutter pub get

# 3. Correr la app (emulador abierto o dispositivo conectado)
flutter run
```

> La app consume un endpoint público — no requiere API keys ni configuración adicional.

**Plataformas verificadas:** iOS Simulator · Android Emulator · iPhone físico

---

## ¿Qué es esto?

Una app de intercambio crypto/fiat construida como challenge de recruiting para El Dorado. La premisa era simple: consumir un endpoint de recomendaciones de ofertas y mostrar el tipo de cambio. La respuesta fue construir algo que escale.

---

## Arquitectura

**Clean Architecture** en tres capas desacopladas:

```
presentation  →  lo que el usuario ve (Flutter, Riverpod)
domain        →  la regla de negocio (Dart puro, sin dependencias)
data          →  de dónde viene el dato (Dio, SharedPreferences)
```

La capa de dominio no importa Flutter. La capa de datos no importa Riverpod. Cambiar Dio por `http`, o Riverpod por BLoC, es una decisión de una capa — no rompe las otras dos.

### Estructura de archivos

```
lib/
├── core/
│   ├── constants/        ← URLs, type constants
│   ├── error/            ← Sealed Failure + Exception classes
│   ├── network/          ← DioClient singleton
│   ├── theme/            ← AppColors, AppTextStyles, AppTheme
│   └── widgets/          ← BorderBeam y widgets compartidos
├── features/exchange/
│   ├── data/
│   │   ├── datasources/  ← HTTP call, manejo de DioException
│   │   ├── models/       ← JSON parsing + cálculo de monto
│   │   └── repositories/ ← Mapeo exception → failure
│   ├── domain/
│   │   ├── entities/     ← ExchangeRate, ExchangeDirection (Dart puro)
│   │   ├── repositories/ ← Interfaz abstracta
│   │   └── usecases/     ← GetExchangeRate
│   └── presentation/
│       ├── pages/        ← ExchangePage
│       ├── providers/    ← ExchangeNotifier, SwapLogNotifier
│       └── widgets/      ← Sistema de diseño Neo*
├── shared/
│   └── models/           ← Currency (fiat + crypto)
└── main.dart             ← ProviderScope + SharedPreferences init
```

---

## Dio — Setup escalable

`DioClient` es un singleton que centraliza toda la configuración HTTP:

```dart
class DioClient {
  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
```

El singleton se expone como provider de Riverpod. Agregar interceptors (auth, logging, retry) es una línea — sin tocar datasources ni repositorios. En producción entraría un `AuthInterceptor` y un `RetryInterceptor` aquí.

Los errores de red se clasifican antes de salir de la capa de datos:

```
DioExceptionType.connectionError   →  NetworkException
DioExceptionType.connectionTimeout →  NetworkException
HTTP error / parse fail            →  ServerException
```

Cada excepción se mapea a un `Failure` sellado en el repositorio. La UI nunca ve un `DioException`.

---

## Estado — Máquina de estados sellada

```dart
sealed class ExchangeState {}
final class ExchangeInitial  extends ExchangeState {}
final class ExchangeLoading  extends ExchangeState {}
final class ExchangeData     extends ExchangeState { final ExchangeRate exchangeRate; }
final class ExchangeError    extends ExchangeState { final String message; }
```

El compilador fuerza exhaustividad en cada `switch`. Es imposible olvidar el estado de error. Es el mismo principio de ACID/Saga aplicado a UI: el sistema siempre está en un estado conocido y válido.

`ExchangeNotifier` agrega debounce inteligente:
- **600ms** al escribir el monto — evita spam al API por cada tecla
- **300ms** al cambiar moneda — refetch rápido pero controlado

---

## Rebranding Neobrutalist

El sistema de diseño tiene nombre propio: **Neo\***.

| Token | Valor |
|---|---|
| `AppColors.yellow` | `#E9FF47` — acento primario |
| `AppColors.black` | `#0A0A0A` — bordes, texto, sombras |
| `AppColors.offWhite` | `#FAFAF5` — fondos de card |
| Tipografía labels | Space Grotesk |
| Tipografía monos | Space Mono |
| Bordes | 2.5–3px sólido |
| Sombras | Hard offset sin blur `(6px, 6px, 0)` |

### Componentes del sistema

- **`NeoCard`** — Card genérica: border, hard shadow, ClipRRect. Sin coupling a features.
- **`NeoButton`** — Tres estados (`idle` → `loading` → `success`) con `AnimatedContainer`. El ciclo de vida de la animación vive en el Page, el botón se mantiene stateless.
- **`NeoAmountInput`** — Input Space Mono 22px con sufijo de moneda.
- **`CurrencyBar`** — Selector TENGO/QUIERO + botón de swap animado.
- **`RateInfoPanel`** — Panel oscuro con tasa, monto a recibir y tiempo estimado.
- **`SwapHeader`** — Logo, título, avatar. El logo abre un modal de créditos.

---

## BorderBeam en el Swap Button

El botón de swap circular lleva un `BorderBeam` — un rayo de luz que orbita el borde en loop continuo. Implementado con `CustomPainter` + `AnimationController` en `repeat()`, sin dependencias externas. Es el tipo de detalle que separa una UI funcional de una UI con carácter y sexy.

---

## Skeletons con gradiente animado

Mientras el API responde, el `RateInfoPanel` reemplaza los valores con skeleton loaders. No son fades — son shimmer gradients que barren de izquierda a derecha usando exactamente los colores del tema:

```
offWhite dim  →  yellow (highlight peak)  →  offWhite dim
```

El sweep está sincronizado con un `AnimationController` en loop de 1.2s. Sin paquetes externos, sin shimmer library — construido directamente con `LinearGradient` + `AnimatedBuilder`.

La lógica de cuándo mostrar skeletons es precisa: solo cuando el loading viene de escribir en el input (silent load). Si el usuario toca **CAMBIAR**, el botón muestra "PROCESANDO..." y luego "CONFIRMADO ✓" — los skeletons no se muestran porque la acción fue explícita.

---

## Swap Log persistente

Cada vez que llega un `ExchangeData` se guarda una entrada en el log:

```
timestamp · from → to · rate
```

El log sobrevive hot reload, hot restart y cierre de app. La persistencia usa `SharedPreferences` con serialización JSON manual — sin ORM, sin overhead. `SharedPreferences` se inicializa en `main()` antes del `runApp` y se inyecta como override en `ProviderScope`:

```dart
final prefs = await SharedPreferences.getInstance();
runApp(
  ProviderScope(
    overrides: [sharedPrefsProvider.overrideWith((_) async => prefs)],
    child: const DoradoApp(),
  ),
);
```

El log se abre desde los tres puntos del header de la card. `Consumer` dentro del sheet hace que las entradas aparezcan en tiempo real sin cerrar y reabrir.

---

## Decisiones que no tomé (y por qué)

| Decisión | Alternativa considerada | Por qué no |
|---|---|---|
| Riverpod | BLoC | Mismo patrón unidireccional, menos boilerplate para 1 feature |
| `sealed class` nativo | `freezed` | Dart 3+ lo soporta nativo, sin codegen |
| SharedPreferences | Hive / SQLite | Zero schema, zero migration para una lista simple |
| Sin interceptors de auth | Con interceptors | No hay endpoints autenticados en el challenge |

---

## API — Quirks encontrados y resueltos

| Problema | Causa | Fix |
|---|---|---|
| `String is not subtype of num` | `fiatToCryptoExchangeRate` llega como String | `raw is num ? raw.toDouble() : double.parse(raw.toString())` |
| `{data: {}}` respuesta vacía | El API exige un monto mínimo de orden | `throw ServerException('No hay ofertas para este monto')` |
| `1 COP = 3640 USDT` (invertido) | `fiatToCryptoExchangeRate` siempre es "fiat por 1 cripto" | CRYPTO→FIAT multiplica, FIAT→CRYPTO divide |
| 0.03 COP por 100 USDT | Condición de dirección invertida en `toEntity()` | Corrección de `typeFiatToCrypto` → `typeCryptoToFiat` |

---

*Flutter · Clean Architecture · Riverpod · Dio · Dart 3 · Neobrutalism*
