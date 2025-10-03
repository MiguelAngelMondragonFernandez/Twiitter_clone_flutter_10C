# Chirper - Proyecto Integrador DMI

Chirper es una aplicación móvil de microblogging, desarrollada como proyecto final para la materia de Desarrollo Móvil Integrador. La aplicación permite a los usuarios publicar mensajes cortos, seguir a otros usuarios y interactuar con sus publicaciones.

## 🎯 Objetivo del Producto

Crear un clon funcional de Twitter, implementando las funcionalidades más esenciales de una red social. El proyecto se desarrollará utilizando **Flutter** para el frontend y **Spring Boot** para el backend, siguiendo una arquitectura **MVVM** y desplegando los servicios en la nube.

## 🗺️ Sprint 1: Planificación y Arquitectura - Alcance

El alcance de este sprint inicial se centra exclusivamente en la planificación y la configuración de la estructura del proyecto. Los entregables clave incluyen:
- Configuración del repositorio en GitHub y el tablero de proyecto.
- Definición de la arquitectura de software (MVVM).
- Creación de la estructura base de carpetas y archivos.
- Elaboración del backlog inicial con épicas e historias de usuario priorizadas.
- Definición de convenciones de desarrollo (ramas y commits).

## 🚀 Instrucciones de Setup Local

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/](https://github.com/)[tu-organizacion]/[nombre-del-proyecto].git
    ```
2.  **Navegar al directorio del proyecto:**
    ```bash
    cd [nombre-del-proyecto]
    ```
3.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```
4.  **Ejecutar la aplicación:**
    ```bash
    flutter run
    ```

## 🛠️ Convenciones de Desarrollo

### Ramas (Git Flow)
-   `main`: Rama principal que contiene el código en producción. Solo se fusiona desde `develop`.
-   `develop`: Rama de integración para las funcionalidades terminadas.
-   `feature/<nombre-feature>`: Ramas para el desarrollo de nuevas funcionalidades (ej. `feature/user-login`).
-   `fix/<nombre-fix>`: Ramas para la corrección de errores (ej. `fix/login-button-bug`).

### Mensajes de Commits
Se utilizará el estándar de [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

**Formato:** `<tipo>[ámbito opcional]: <descripción>`
-   **`feat`**: Para nuevas funcionalidades.
-   **`fix`**: Para corrección de errores.
-   **`docs`**: Para cambios en la documentación.
-   **`style`**: Para cambios de formato (linting, espacios, etc.).
-   **`refactor`**: Para cambios en el código que no añaden funcionalidad ni corrigen errores.
-   **`chore`**: Para tareas de mantenimiento (actualizar dependencias, etc.).
