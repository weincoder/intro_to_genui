# Documentación Oficial: Intro to GenUI & A2UI (Docusaurus)

Sitio de documentación técnica bilingüe (Español e Inglés) construido con [Docusaurus](https://docusaurus.io/) para el proyecto **Intro to GenUI - Memory Trainer**.

---

## 🌐 Idiomas Soportados / Supported Locales

- **Español (`es`)**: Idioma predeterminado (accesible en `/docs/...`).
- **English (`en`)**: Versión completa en inglés (accesible en `/en/docs/...`).

El sitio cuenta con un selector de idiomas en la barra de navegación superior (`localeDropdown`).

---

## 🚀 Inicio Rápido / Getting Started

### 1. Instalar dependencias / Install dependencies

```bash
cd documentation
npm install
```

### 2. Iniciar servidor local de desarrollo / Start local dev server

Para iniciar en el idioma predeterminado (Español):
```bash
npm run start
```

Para iniciar directamente en Inglés:
```bash
npm run start -- --locale en
```

Abre [http://localhost:3000](http://localhost:3000) en tu navegador.

### 3. Compilar para producción / Build for production

Genera el sitio estático para ambos idiomas (`/` y `/en/`):
```bash
npm run build
```

Para previsualizar la compilación de producción localmente:
```bash
npm run serve
```

---

## 📚 Estructura de la Documentación

```text
documentation/
├── docs/                                          # Documentación en Español (Default)
│   ├── 01-intro/                                  # Bienvenido y Quickstart
│   ├── 02-architecture/                           # Clean Architecture y Ciclo de vida A2UI
│   ├── 03-implementation-guide/                   # Guía paso a paso (1 a 6)
│   ├── 04-deep-dive/                              # Análisis de MemorySessionDisplay y ScoreDisplay
│   └── 05-best-practices/                         # Buenas prácticas y Troubleshooting
├── i18n/
│   └── en/
│       ├── code.json                              # Traducciones de la UI
│       ├── docusaurus-theme-classic/              # Navbar y footer en inglés
│       └── docusaurus-plugin-content-docs/current/# Documentación en Inglés (Symmetric)
└── src/
    ├── pages/index.tsx                            # Página de inicio con Translate
    └── components/HomepageFeatures/               # Pilares de A2UI
```
