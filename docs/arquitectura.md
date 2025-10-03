# Arquitectura del Proyecto

## 🏗️ Patrón de Arquitectura: MVVM (Model-View-ViewModel)

Para este proyecto, se ha seleccionado el patrón de arquitectura **MVVM (Model-View-ViewModel)**. Esta elección se basa en su capacidad para separar de manera clara y efectiva la lógica de la interfaz de usuario (UI) de la lógica de negocio y el estado, facilitando las pruebas, el mantenimiento y la escalabilidad del código.

### Diagrama de Arquitectura

El flujo de datos y dependencias sigue el siguiente esquema:

Acciones del Usuario      Notifica Cambios de Estado
(Eventos: onPressed)      (Listeners/Streams)
|                           ^
|                           |
+------------------+         +--------------------+
|       View       | <-----> |     ViewModel      |
| (Widgets/Pantallas)|         | (Estado y Lógica UI) |
+------------------+         +--------------------+
|
| Pide/Envía Datos
v
+--------------------+
|     Repository     |
| (Abstracción Datos)  |
+--------------------+
/

/

/ Pide/Envía Datos        \  Pide/Envía Datos Locales
v   Remotos                 v
+-------------------+    +----------------------+
|   API Service     |    |   Local Service      |
|      (Dio)        |    | (SharedPreferences)  |
+-------------------+    +----------------------+


### Responsabilidades de las Capas

1.  **View (Vista):**
    * **Responsabilidad:** Renderizar la interfaz de usuario y delegar las interacciones del usuario al ViewModel.
    * **Componentes:** Widgets de Flutter (`StatelessWidget`, `StatefulWidget`).
    * **Reglas:** No contiene lógica de negocio ni de estado. Solo "dibuja" lo que el ViewModel le indica y le notifica eventos (ej. `loginViewModel.login()`).

2.  **ViewModel (Modelo de Vista):**
    * **Responsabilidad:** Contener el estado de la UI y la lógica de presentación. Actúa como intermediario entre la Vista y el Repositorio.
    * **Componentes:** Clases de Dart que usan un manejador de estado (como `ChangeNotifier` o `BLoC`).
    * **Reglas:** Expone propiedades y comandos que la Vista puede enlazar. No tiene conocimiento directo de los Widgets de la UI. Solicita datos al Repositorio.

3.  **Model (Modelo):**
    * **Responsabilidad:** Representar los objetos de datos de la aplicación.
    * **Componentes:** Clases simples de Dart (POJOs/PODOs) con métodos de serialización (ej. `fromJson`, `toJson`).
    * **Ejemplos:** `User`, `Post`, `Comment`.

4.  **Repository (Repositorio):**
    * **Responsabilidad:** Abstraer las fuentes de datos. Centraliza la lógica para decidir de dónde obtener los datos (API remota, caché local, base de datos).
    * **Componentes:** Clases que coordinan uno o más `Services`.
    * **Reglas:** Es la única capa que se comunica con los `Services`. El ViewModel solo habla con el Repositorio.

5.  **Service (Servicio):**
    * **Responsabilidad:** Realizar una tarea específica y concreta.
    * **Componentes:** Clases enfocadas, como `ApiService` (para llamadas de red con Dio) o `LocalStorageService` (para `SharedPreferences`).
