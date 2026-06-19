<div align="center">
   <a href="README.md">
      <img src="https://img.shields.io/badge/Lang-English-blue" alt="Read in English" />
   </a>
</div>

# Intro to GenUI - Entrenador de Memoria

<div align="center">
   <p>
      <a href="https://flutter.dev/" target="_blank">
         <img src="https://img.shields.io/badge/Flutter-3.12%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
      </a>
      <a href="https://firebase.google.com/" target="_blank">
         <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
      </a>
      <a href="https://cloud.google.com/vertex-ai" target="_blank">
         <img src="https://img.shields.io/badge/Vertex%20AI-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Vertex AI" />
      </a>
   </p>
</div>

**Entrenamiento de memoria con IA usando Flutter + GenUI.**
Ejecuta sesiones con temporizador, evalua el recuerdo y muestra un resultado final con retroalimentacion detallada.

---

## Funcionalidades

| Modulo | Descripcion |
|---|---|
| Agente IA | Ejecuta un flujo guiado de entrenamiento en espanol |
| Sesion de Memoria | Renderiza listas de palabras temporizadas con surfaces de GenUI |
| Comportamiento al Timeout | Oculta palabras automaticamente al finalizar el tiempo |
| Evaluacion de Recuerdo | Puntua respuestas por palabra con credito parcial (1.0, 0.5, 0.0) |
| Tablero de Score | Muestra puntaje final, progreso y feedback por palabra |
| Agente Configurable | Centraliza prompt, modelo e IDs de surface en la capa config |

---

## FASE 2: El Agente de Procesos (Hoy)

```text
-----------------------------------------------------------
|                    FASE 2 (HOY)                         |
|               El Agente de Procesos                     |
-----------------------------------------------------------
| - Ejecuta flujos de trabajo autonomos multi-paso.       |
| - Se conecta con otros sistemas (CRM, ERP, correos).    |
| - Toma decisiones por reglas y reporta resultados.      |
-----------------------------------------------------------
```

---

## Arquitectura

El proyecto sigue un diseno por capas:

```text
UI  ->  Config  ->  Infrastructure  ->  Domain
```

- Domain: modelos puros Dart, gateways y casos de uso.
- Infrastructure: adapters y mappers para parseo y reglas por defecto.
- Config: providers, rutas, opciones de Firebase y configuracion del agente.
- UI: paginas, widgets y painters.

### Estructura de carpetas

```text
lib/
|- config/
|  |- agent/
|  |- firebase/
|  |- providers/
|  |- routes/
|  '- theme/
|- domain/
|  |- models/
|  '- usecase/
|- infrastructure/
|  |- driven_adapters/
|  '- helpers/
'- ui/
   |- pages/
   |- widgets/
   '- painters/
```

---

## Setup

Requisito: Flutter SDK (con Dart 3.12+).

Nota de seguridad:
- No subas archivos de credenciales Firebase al repositorio.
- Usa archivos locales y variables de compilacion.

Crear archivos locales de plataforma:

```bash
cp android/app/google-services.json.example android/app/google-services.json
cp ios/Runner/GoogleService-Info.plist.example ios/Runner/GoogleService-Info.plist
```

Ejecutar con valores Firebase via --dart-define (ejemplo):

```bash
flutter run \
   --dart-define=FIREBASE_WEB_API_KEY=TU_VALOR \
   --dart-define=FIREBASE_WEB_APP_ID=TU_VALOR \
   --dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID=TU_VALOR \
   --dart-define=FIREBASE_WEB_PROJECT_ID=TU_VALOR \
   --dart-define=FIREBASE_WEB_AUTH_DOMAIN=TU_VALOR \
   --dart-define=FIREBASE_WEB_STORAGE_BUCKET=TU_VALOR \
   --dart-define=FIREBASE_ANDROID_API_KEY=TU_VALOR \
   --dart-define=FIREBASE_ANDROID_APP_ID=TU_VALOR \
   --dart-define=FIREBASE_ANDROID_MESSAGING_SENDER_ID=TU_VALOR \
   --dart-define=FIREBASE_ANDROID_PROJECT_ID=TU_VALOR \
   --dart-define=FIREBASE_ANDROID_STORAGE_BUCKET=TU_VALOR \
   --dart-define=FIREBASE_IOS_API_KEY=TU_VALOR \
   --dart-define=FIREBASE_IOS_APP_ID=TU_VALOR \
   --dart-define=FIREBASE_IOS_MESSAGING_SENDER_ID=TU_VALOR \
   --dart-define=FIREBASE_IOS_PROJECT_ID=TU_VALOR \
   --dart-define=FIREBASE_IOS_STORAGE_BUCKET=TU_VALOR \
   --dart-define=FIREBASE_IOS_BUNDLE_ID=com.example.intro_to_genui
```

```bash
flutter pub get
flutter run
```

---

## Validacion

En este repositorio se recomienda usar validaciones enfocadas:

```bash
flutter analyze lib test/widget_test.dart
flutter test test/widget_test.dart
```

---

## Dependencias principales

| Paquete | Uso |
|---|---|
| `firebase_core` | Inicializacion de Firebase |
| `firebase_ai` | Acceso al modelo Gemini |
| `genui` | Protocolo de UI basado en surfaces |
| `json_schema_builder` | Esquemas declarativos para payloads |

---

## Notas de diseno

- Experiencia conversacional en espanol.
- Estetica retro (grid/orb) con estados visuales del buho.
- Objetivo multiplataforma Flutter (Android, iOS, macOS, Linux, Web, Windows).

---

## 🙏 Agradecimientos

- **Google Cloud**: Por Vertex AI y los modelos Gemini
- **Firebase**: Por la integracion fluida de backend
- **Flutter Team**: Por el framework increible
- **Comunidad Open Source**: Por los excelentes paquetes

## 📞 Soporte

- **Issues**: [GitHub Issues](https://github.com/weincoder/intro_to_genui/issues)
- **Email**: danielherresan@gmail.com

---

## 👥 Autores

* **Daniel Herrera (Weincode)** - [LinkedIn](https://www.linkedin.com/in/daniel-herrera-sanchez-a4106a56/) | [YouTube](https://youtube.com/@weincode)

---

<div align="center">
   <sub>Construido con ❤️ por la comunidad Flutter Medellin y Weincode.</sub><br>
   <sub>Llegaste hasta aqui? No olvides dejar tu ⭐</sub>
</div>
