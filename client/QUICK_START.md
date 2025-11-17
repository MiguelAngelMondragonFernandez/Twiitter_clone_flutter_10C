# Guía Rápida de Desarrollo - Chirper Frontend

## 🚀 Inicio Rápido

### 1. Configurar el Backend
```dart
// En lib/utils/api_constants.dart
static const String baseUrl = 'http://localhost:8080/api';

// Para emulador Android usa:
// static const String baseUrl = 'http://10.0.2.2:8080/api';
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar la aplicación
```bash
flutter run
```

## 🧪 Datos de Prueba

Para probar la aplicación sin backend, puedes modificar temporalmente los servicios para retornar datos mock:

### Usuario de Prueba
```dart
{
  "email": "test@chirper.com",
  "password": "123456"
}
```
test
## 📱 Flujo de la Aplicación

1. **Splash Screen** → Verifica si hay sesión guardada
2. **Login/Register** → Autenticación del usuario
3. **Home** → Feed principal con chirps
4. **Profile** → Perfil y chirps del usuario
5. **Create Chirp** → Crear nuevo chirp

## 🔄 Estados de la Aplicación

### AuthViewModel
```dart
currentUser    // Usuario autenticado
isLoading      // Cargando operación
error          // Mensaje de error
isAuthenticated // Si hay usuario autenticado
```

### ChirpViewModel
```dart
chirps         // Lista de chirps
isLoading      // Cargando operación
error          // Mensaje de error
hasMore        // Hay más chirps para cargar
```

## 🎨 Widgets Disponibles

### CustomButton
```dart
CustomButton(
  text: 'Botón',
  onPressed: () {},
  isLoading: false,
  isOutlined: false, // Para botón con borde
)
```

### CustomTextField
```dart
CustomTextField(
  controller: _controller,
  hintText: 'Placeholder',
  prefixIcon: Icon(Icons.email),
  validator: (value) => value?.isEmpty ?? true ? 'Error' : null,
)
```

### ChirpCard
```dart
ChirpCard(chirp: chirpObject)
```

## 🔧 Añadir Nuevas Funcionalidades

### 1. Crear un nuevo servicio
```dart
// lib/services/mi_servicio.dart
class MiServicio {
  Future<Resultado> hacerAlgo() async {
    // Implementación
  }
}
```

### 2. Crear un ViewModel
```dart
// lib/viewmodels/mi_viewmodel.dart
class MiViewModel extends ChangeNotifier {
  // Estado y lógica
}
```

### 3. Registrar el Provider
```dart
// En main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MiViewModel()),
    // otros providers...
  ],
)
```

### 4. Usar el ViewModel en una Vista
```dart
Consumer<MiViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.dato);
  },
)
```

## 🐛 Debugging

### Ver logs
```bash
flutter logs
```

### Limpiar build
```bash
flutter clean
flutter pub get
```

### Analizar código
```bash
flutter analyze
```

### Formatear código
```bash
flutter format .
```

## 📦 Añadir Dependencias

1. Añadir al `pubspec.yaml`:
```yaml
dependencies:
  nueva_dependencia: ^version
```

2. Instalar:
```bash
flutter pub get
```

3. Importar en el código:
```dart
import 'package:nueva_dependencia/nueva_dependencia.dart';
```

## 🎯 Tips de Desarrollo

1. **Hot Reload**: Presiona `r` en la terminal
2. **Hot Restart**: Presiona `R` en la terminal
3. **Quit**: Presiona `q` en la terminal

4. **Usar const**: Mejora el rendimiento
```dart
const Text('Hola') // Mejor que Text('Hola')
```

5. **Extractar Widgets**: Mantén los widgets pequeños
```dart
// Mal
build() => Container(child: Column(children: [...]));

// Bien
build() => _MiWidget();
Widget _MiWidget() => Container(...);
```

6. **Provider sin rebuild**: Usa `listen: false`
```dart
Provider.of<AuthViewModel>(context, listen: false).metodo();
```

## 🔐 Manejo de Autenticación

El token se guarda automáticamente en SharedPreferences:
```dart
// Login exitoso → Token guardado
// App cerrada → Token persiste
// App abierta → SplashScreen verifica token → Redirige a Home o Login
```

## 📸 Screenshots para el README

Para documentar el proyecto, toma screenshots de:
- [ ] Pantalla de Login
- [ ] Pantalla de Registro
- [ ] Feed principal
- [ ] Perfil de usuario
- [ ] Crear chirp

## ✅ Checklist antes de Commit

- [ ] `flutter analyze` sin errores
- [ ] `flutter test` todos los tests pasan
- [ ] Código formateado con `flutter format`
- [ ] README actualizado si añadiste features
- [ ] Commit message sigue convenciones (feat:, fix:, etc.)

## 🆘 Comandos Útiles

```bash
# Ver información del dispositivo
flutter doctor -v

# Ver todos los dispositivos
flutter devices

# Ejecutar en dispositivo específico
flutter run -d chrome

# Build para producción
flutter build apk --split-per-abi  # APKs por arquitectura

# Generar iconos
flutter pub run flutter_launcher_icons:main

# Actualizar dependencias
flutter pub upgrade
```
