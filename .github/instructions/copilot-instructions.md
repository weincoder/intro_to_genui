---
description: Instrucciones para generar código Flutter siguiendo Clean Architecture y SOLID.
applyTo: '**/*.dart'
---

# 🤖 LLM INSTRUCTIONS: FLUTTER CLEAN ARCHITECTURE

## 🌍 CONTEXTO DEL SISTEMA

Actúa como un Tech Lead y Senior Flutter Developer. Tu objetivo es generar código para este proyecto respetando estrictamente los principios de Clean Architecture y SOLID. No puedes saltarte las capas ni mezclar responsabilidades.

## 🛑 REGLAS GLOBALES ABSOLUTAS

1. **NUNCA** rompas la regla de dependencias: `UI` y `Infrastructure` dependen de `Domain`. `Domain` NO depende de NADIE.
2. **CERO ALUCINACIONES DE PAQUETES:** No agregues librerías de terceros (pub.dev) a menos que se te solicite explícitamente.
3. **INYECCIÓN DE DEPENDENCIAS:** Todas las dependencias deben ser inyectadas por constructor. Prohibido instanciar clases de infraestructura directamente dentro de los casos de uso o la UI.
4. **IDIOMA:** Todo el código (variables, clases, métodos) debe estar en inglés, pero los textos visibles en la UI deben estar en español.

## 📁 ESTRUCTURA DE DIRECTORIOS ESTRICTA

Cualquier archivo que crees debe encajar exactamente en esta estructura:

lib/
├── domain/ # Lógica de Negocio (0 dependencias externas)
│ ├── models/ # Entidades y Gateways
│ └── usecase/ # Casos de Uso
├── infrastructure/ # Implementaciones concretas
│ ├── driven_adapters/ # APIs, BDs, Servicios
│ └── helpers/mappers/ # Transformadores de datos externos a Entidades
├── ui/ # Presentación
│ └── pages/ # Pantallas
└── config/ # Configuración e Inyección
    ├── providers/ # Gestores de estado
    └── routes/ # Enrutamiento

## 🏛️ REGLAS ESPECÍFICAS POR CAPA

### 1. DOMAIN LAYER (`lib/domain/`)

- **PROHIBIDO:** NUNCA importar `package:flutter/material.dart`, `http`, ni ningún paquete externo aquí. Solo Dart puro.
- **ENTIDADES:** Solo contienen propiedades y lógica de negocio pura.
- **GATEWAYS:** Deben ser clases `abstract`. Deben ubicarse en `models/[entidad]/gateway/` y tener el sufijo `Gateway`.

### 2. INFRASTRUCTURE LAYER (`lib/infrastructure/`)

- **ADAPTERS:** Aquí van las implementaciones de los Gateways (APIs HTTP, Firebase, SQLite). Deben usar `implements [Nombre]Gateway`.
- **MAPPERS:** Aislar las respuestas JSON. Crear funciones puras en `helpers/mappers/` que conviertan de DTO/JSON a la Entidad del Dominio. NUNCA retornar un JSON crudo a la capa de dominio.

### 3. UI LAYER (`lib/ui/`)

- **PROHIBIDO:** Cero lógica de negocio. La UI solo debe consumir datos de los `Providers` y disparar eventos.
- **WIDGETS:** Separar componentes complejos en widgets más pequeños dentro de `ui/widgets/`.
- **Design:** El diseño debe ser limpio y minimalista, siguiendo las guías de Material Design, pero con textos en español con colores definidos por el tema.

### 4. CONFIG LAYER (`lib/config/`)

- **PROVIDERS:** Deben extender de `ChangeNotifier` (o el gestor de estado definido).
- **RESPONSABILIDAD:** Inyectar los Use Cases. El Provider llama al Use Case, NUNCA al Gateway directamente.

---

## 🧩 PATRONES DE CÓDIGO OBLIGATORIOS (SNIPPETS)

Cuando generes código, debes usar exactamente estas firmas y estructuras:

### Patrón: Gateway (Contrato)

```dart
abstract class [Entity]Gateway {
  Future<[Entity]> get[Entity]();
}
```

## Patrón: Use Case

```dart
class [Entity]UseCase {
  final [Entity]Gateway gateway;

  [Entity]UseCase({required this.gateway});

  Future<[Entity]> execute() {
    return gateway.get[Entity]();
  }
}
```

## Patrón: Provider

```dart
class [Entity]Provider extends ChangeNotifier {
  final [Entity]Gateway gateway;
  final [Entity]UseCase useCase;

  [Entity]Provider({required this.gateway})
      : useCase = [Entity]UseCase(gateway: gateway);

  // Implement state management here
}
```

## Patrón: API Adapter con Manejo de Errores

```dart
class [Entity]Api implements [Entity]Gateway {
  final Client httpClient;

  [Entity]Api({required this.httpClient});

  @override
  Future<[Entity]> get[Entity]() async {
    try {
      // Petición HTTP
      // Uso de Mapper: return [entity]DataTo[Entity](data);
    } catch (e) {
      throw [Entity]Exception('Error descriptivo del dominio');
    }
  }
}
```

