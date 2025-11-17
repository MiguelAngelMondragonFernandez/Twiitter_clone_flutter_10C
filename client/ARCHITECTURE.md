# Arquitectura del Frontend - Chirper

## 📊 Diagrama de Arquitectura MVVM

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEWS (UI)                           │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ LoginView   │  │  HomeView    │  │ ProfileView  │       │
│  │RegisterView │  │CreateChirp   │  │              │       │
│  └─────────────┘  └──────────────┘  └──────────────┘       │
│         ↓ Consumer<T>      ↓ Consumer<T>      ↓             │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │     PROVIDER      │
                    │  (State Manager)  │
                    └─────────┬─────────┘
                              │
┌─────────────────────────────▼─────────────────────────────┐
│                     VIEWMODELS (Logic)                     │
│  ┌────────────────────┐      ┌────────────────────┐       │
│  │  AuthViewModel     │      │  ChirpViewModel    │       │
│  │  ─────────────     │      │  ──────────────    │       │
│  │  • currentUser     │      │  • chirps[]        │       │
│  │  • isLoading       │      │  • isLoading       │       │
│  │  • error           │      │  • hasMore         │       │
│  │  • login()         │      │  • loadFeed()      │       │
│  │  • register()      │      │  • createChirp()   │       │
│  │  • logout()        │      │  • toggleLike()    │       │
│  └────────────────────┘      └────────────────────┘       │
│         │                              │                    │
└─────────┼──────────────────────────────┼──────────────────┘
          │                              │
          ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICES (API)                          │
│  ┌────────────────────┐      ┌────────────────────┐        │
│  │  AuthService       │      │  ChirpService      │        │
│  │  ────────────      │      │  ─────────────     │        │
│  │  • login()         │      │  • getFeed()       │        │
│  │  • register()      │      │  • createChirp()   │        │
│  │  • logout()        │      │  • likeChirp()     │        │
│  │  • getToken()      │      │  • deleteChirp()   │        │
│  └────────────────────┘      └────────────────────┘        │
│         │                              │                     │
└─────────┼──────────────────────────────┼───────────────────┘
          │                              │
          ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    HTTP + SharedPreferences                  │
│                                                               │
│         Backend API              Local Storage               │
│      (Spring Boot)              (Auth Token)                 │
└─────────────────────────────────────────────────────────────┘
          │                              
          ▼                              
┌─────────────────────────────────────────────────────────────┐
│                      MODELS (Data)                           │
│  ┌────────────────────┐      ┌────────────────────┐        │
│  │      User          │      │      Chirp         │        │
│  │  ────────────      │      │  ─────────────     │        │
│  │  • id              │      │  • id              │        │
│  │  • username        │      │  • content         │        │
│  │  • email           │      │  • author: User    │        │
│  │  • displayName     │      │  • likesCount      │        │
│  │  • bio             │      │  • createdAt       │        │
│  │  • followersCount  │      │  • isLiked         │        │
│  └────────────────────┘      └────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Datos

### Ejemplo: Crear un Chirp

```
1. User taps "Chirp" button
   │
   ▼
2. CreateChirpView
   │ onPressed: viewModel.createChirp(content)
   ▼
3. ChirpViewModel.createChirp()
   │ Llama al servicio
   ▼
4. ChirpService.createChirp()
   │ HTTP POST al backend
   ▼
5. Backend procesa y devuelve Chirp
   │
   ▼
6. ChirpService parsea respuesta JSON → Chirp object
   │
   ▼
7. ChirpViewModel actualiza estado
   │ _chirps.insert(0, newChirp)
   │ notifyListeners()
   ▼
8. Provider notifica a todos los Consumers
   │
   ▼
9. HomeView se reconstruye automáticamente
   │
   ▼
10. Usuario ve el nuevo chirp en el feed ✅
```

## 🎯 Responsabilidades por Capa

### 📱 Views (Pantallas)
- **Responsabilidad**: Solo UI y gestión de widgets
- **NO debe**: Lógica de negocio, llamadas API directas
- **SÍ debe**: Mostrar datos, capturar input del usuario, navegar

```dart
// ✅ BIEN
Consumer<ChirpViewModel>(
  builder: (context, vm, child) => Text(vm.chirps.length.toString())
)

// ❌ MAL
final chirps = await ChirpService().getFeed(); // No llamar servicios desde la vista
```

### 🧠 ViewModels
- **Responsabilidad**: Lógica de negocio y gestión de estado
- **NO debe**: Importar Flutter widgets (excepto ChangeNotifier)
- **SÍ debe**: Coordinar servicios, transformar datos, notificar cambios

```dart
// ✅ BIEN
class ChirpViewModel extends ChangeNotifier {
  Future<void> loadFeed() async {
    _isLoading = true;
    notifyListeners();
    _chirps = await _service.getFeed();
    _isLoading = false;
    notifyListeners();
  }
}
```

### 🌐 Services
- **Responsabilidad**: Comunicación con API externa
- **NO debe**: Gestionar estado de UI
- **SÍ debe**: Hacer HTTP requests, parsear JSON, manejar tokens

```dart
// ✅ BIEN
class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(url, body: {...});
    return jsonDecode(response.body);
  }
}
```

### 📦 Models
- **Responsabilidad**: Representar entidades de datos
- **NO debe**: Tener lógica de negocio
- **SÍ debe**: Serialización/deserialización JSON

```dart
// ✅ BIEN
class User {
  final String id;
  final String username;
  
  factory User.fromJson(Map<String, dynamic> json) => User(...);
  Map<String, dynamic> toJson() => {...};
}
```

## 🔐 Flujo de Autenticación

```
┌────────────────────────────────────────────────────────────┐
│  1. App inicia → main.dart                                  │
│     └─→ SplashScreen                                        │
│          └─→ AuthViewModel.checkAuthStatus()               │
│               ├─→ Token existe? → HomeView                 │
│               └─→ No token? → LoginView                    │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  2. Usuario hace login                                      │
│     └─→ LoginView                                           │
│          └─→ AuthViewModel.login(email, password)          │
│               └─→ AuthService.login()                      │
│                    └─→ POST /api/auth/login                │
│                         └─→ Backend valida                 │
│                              ├─→ ✅ Token guardado         │
│                              │   SharedPreferences          │
│                              └─→ Navigate to HomeView      │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  3. Requests subsecuentes                                   │
│     └─→ Cualquier API call                                 │
│          └─→ Service.getAuthHeaders()                      │
│               └─→ Headers: {Authorization: Bearer <token>} │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  4. Usuario hace logout                                     │
│     └─→ AuthViewModel.logout()                             │
│          └─→ SharedPreferences.remove(token)               │
│               └─→ Navigate to LoginView                    │
└────────────────────────────────────────────────────────────┘
```

## 📊 Estado y Ciclo de Vida

### Provider + ChangeNotifier Pattern

```dart
// 1. ViewModel extiende ChangeNotifier
class ChirpViewModel extends ChangeNotifier {
  List<Chirp> _chirps = [];
  
  // 2. Cuando el estado cambia, notificar
  Future<void> loadFeed() async {
    _chirps = await _service.getFeed();
    notifyListeners(); // ← Esto triggerea rebuild
  }
}

// 3. En main.dart, registrar con Provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ChirpViewModel()),
  ],
)

// 4. En la vista, escuchar cambios
Consumer<ChirpViewModel>(
  builder: (context, viewModel, child) {
    // Este builder se ejecuta cada vez que notifyListeners() se llama
    return ListView(children: viewModel.chirps.map(...));
  },
)
```

## 🧩 Widgets Reutilizables

```
widgets/
├── custom_button.dart       → Botón con loading state
├── custom_textfield.dart    → Input con validación
└── chirp_card.dart          → Tarjeta de chirp con acciones

Principio: DRY (Don't Repeat Yourself)
- Si un widget se usa 2+ veces → Extraer a /widgets
- Si tiene lógica compleja → Considerar un ViewModel dedicado
```

## 🎨 Temas y Estilos

```dart
// main.dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF1DA1F2), // Twitter blue
  ),
  useMaterial3: true,
)

// Uso en widgets
Theme.of(context).primaryColor
Theme.of(context).textTheme.headlineLarge
```

## 📱 Navegación

```dart
// Push (ir a nueva pantalla)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => NewView()),
);

// Replace (reemplazar pantalla actual)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => HomeView()),
);

// Pop (volver atrás)
Navigator.pop(context);

// Pop con resultado
Navigator.pop(context, result);
```

## ⚡ Performance Tips

1. **Use const constructors**
   ```dart
   const Text('Hello') // No rebuild innecesario
   ```

2. **Provider listen: false**
   ```dart
   Provider.of<T>(context, listen: false).method() // No rebuild
   ```

3. **ListView.builder** para listas largas
   ```dart
   ListView.builder(...) // Lazy loading
   ```

4. **Keys para listas dinámicas**
   ```dart
   ChirpCard(key: ValueKey(chirp.id), ...)
   ```

## 🧪 Testing (Próximo paso)

```dart
// test/viewmodels/auth_viewmodel_test.dart
test('login success updates currentUser', () async {
  final vm = AuthViewModel();
  await vm.login('test@test.com', '123456');
  expect(vm.currentUser, isNotNull);
});
```

## 📚 Recursos

- [Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
- [Material Design 3](https://m3.material.io/)
