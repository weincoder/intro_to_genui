---
title: "Inicio Rápido (Quickstart)"
sidebar_label: "Inicio Rápido"
sidebar_position: 2
---

# Inicio Rápido: Ejecutar el Proyecto

Sigue estos pasos para clonar, configurar y ejecutar el proyecto **Intro to GenUI - Memory Trainer** en tu entorno local.

---

## 📋 Requisitos del sistema

- **Flutter SDK**: 3.12+ (Dart 3.12+).
- **Cuenta de Firebase / Google Cloud**: Con el servicio **Vertex AI in Firebase** habilitado.
- Navegador Web (Chrome) o emulador/dispositivo Android o iOS.

---

## 1. Clonar el repositorio e instalar paquetes

Clona el repositorio e instala las dependencias de Flutter:

```bash
git clone https://github.com/weincoder/intro_to_genui.git
cd intro_to_genui
flutter pub get
```

---

## 2. Configuración de credenciales de Firebase

Por motivos de seguridad, las credenciales de Firebase no se almacenan en el repositorio. Debes configurar tus propios archivos locales según la plataforma que desees probar:

### Opción A: Ejecución en Web (Recomendada para pruebas rápidas)

1. Copia la plantilla de configuración de variables de entorno para Web:

```bash
cp firebase_web.env.example.json firebase_web.env.json
```

2. Abre `firebase_web.env.json` y completa tus valores de Firebase Web:

```json
{
  "FIREBASE_WEB_API_KEY": "AIzaSy...",
  "FIREBASE_WEB_APP_ID": "1:...:web:...",
  "FIREBASE_WEB_MESSAGING_SENDER_ID": "...",
  "FIREBASE_WEB_PROJECT_ID": "tu-proyecto-firebase",
  "FIREBASE_WEB_AUTH_DOMAIN": "tu-proyecto-firebase.firebaseapp.com",
  "FIREBASE_WEB_STORAGE_BUCKET": "tu-proyecto-firebase.appspot.com"
}
```

3. Ejecuta la aplicación en Chrome apuntando al archivo de entorno:

```bash
flutter run -d chrome --dart-define-from-file=firebase_web.env.json
```

### Opción B: Ejecución en Android / iOS

1. Para Android, crea el archivo de configuración a partir del ejemplo:
   ```bash
   cp android/app/google-services.json.example android/app/google-services.json
   ```
2. Para iOS, crea el archivo de configuración a partir del ejemplo:
   ```bash
   cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
   cp firebase_ios.env.example.json firebase_ios.env.json
   ```
3. Ejecuta la aplicación en tu simulador o dispositivo:
   ```bash
   flutter run
   ```

---

## 3. Verificación y Pruebas

Para garantizar que el entorno de desarrollo y los contratos de configuración del agente estén íntegros, ejecuta el analizador y las pruebas unitarias:

```bash
# Analizar código con linter estricto
flutter analyze lib test/widget_test.dart

# Ejecutar suite de pruebas
flutter test test/widget_test.dart
```

Las pruebas validan que:
* Las constantes requeridas por el protocolo A2UI (`memorySessionSurfaceId`, `scoreDisplaySurfaceId`, `memoryTrainerModelName`) no estén vacías.
* La instrucción del sistema (`memoryTrainerSystemInstruction`) contenga las especificaciones obligatorias para la generación de las superficies de UI.
