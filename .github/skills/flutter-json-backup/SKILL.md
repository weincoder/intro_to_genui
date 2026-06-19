---
name: flutter-json-backup
description: Implementa un sistema de respaldo y restauración en formato JSON local, siguiendo principios de Clean Architecture, serialización pura, compatibilidad cruzada e inmutabilidad.
---

# 🤖 SKILL INSTRUCTIONS: FLUTTER JSON BACKUP SYSTEM

## 🎯 AGENT BEHAVIOR (HOW TO EXECUTE)
When requested to implement or update the backup system:
1. **Analyze:** Read ALL existing domain models in the project to understand every entity that must be backed up.
2. **Plan:** Identify dependencies between entities (e.g., `Product` depends on `Material`).
3. **Execute:** Generate the backup architecture strictly following the layers and rules below.

## 🛑 1. STRICT CORE PRINCIPLES
- **PURE SERIALIZATION:** The `BackupSerializer` MUST be a pure utility class. It NEVER performs I/O operations, NEVER accesses Hive, and NEVER reads files. It only maps Data ↔ JSON Strings.
- **TOLERANT DESERIALIZATION:** You MUST use fallback values (`??`) for EVERY field to ensure retrocompatibility. Assume any field might be missing in older backup files.
- **WIPE BEFORE RESTORE:** When importing, the `BackupLocalAdapter` MUST completely clear the existing database BEFORE inserting the new backup data.
- **BASE64 IMAGES:** Never save file paths for images. Images MUST be encoded/decoded as Base64 strings to guarantee portability across devices.
- **UI RELOAD:** After a successful import, you MUST call the `load()` methods of ALL providers to refresh the UI state.

## 📁 2. MANDATORY ARCHITECTURE
All generated files MUST follow this structure exactly:
```text
lib/
├── domain/models/backup/backup_data.dart            # Complete state + Metadata
├── domain/models/backup/gateway/backup_gateway.dart # Abstract contract
├── domain/usecase/backup/backup_use_case.dart       # Validation logic
├── infrastructure/helpers/backup_serializer.dart    # Pure JSON conversion
├── infrastructure/driven_adapters/backup/backup_local_adapter.dart # Hive I/O & Orchestration
├── config/providers/backup_provider.dart            # State, FilePicker, Share
└── ui/pages/backup_page.dart                        # Export/Import UI
```

## 🧩 3. ENFORCED CODE PATTERNS

### Pattern 1: Tolerant Deserialization (Serializer)
When converting JSON to Domain Models, use this exact syntax to prevent crashes:
```dart
// Numbers: JSON might send int or double. ALWAYS cast to num first.
price: (map['price'] as num?)?.toDouble() ?? 0.0,

// Strings & Nullables
name: map['name'] as String? ?? 'Desconocido',
notes: map['notes'] as String?,

// Dates
date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),

// Lists
items: _deserializeItems(map['items'] as List<dynamic>? ?? []),
```

### Pattern 2: Restoration Order (Adapter)
When importing data in the `BackupLocalAdapter`, respect entity dependencies.
```dart
@override
Future<void> importBackupFromJson(String jsonContent) async {
  final data = BackupSerializer.deserialize(jsonContent);

  // 1. CRITICAL: Clear all existing data first
  await _clearAllData();

  // 2. Restore independent entities FIRST
  for (final m in data.materials) {
    await _materialGateway.save(m);
  }

  // 3. Restore dependent entities LAST (e.g., Products need Materials)
  for (final p in data.products) {
    await _productGateway.save(p);
  }
}
```

### Pattern 3: iOS Cross-Platform Sharing (Provider/UI)
When using `share_plus` to export, you MUST request and provide the `sharePositionOrigin` to prevent crashes on iPads/iOS.
```dart
// In UI (Button trigger):
final box = context.findRenderObject() as RenderBox?;
final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
await provider.exportAndShare(sharePositionOrigin: origin);

// In Provider:
await Share.shareXFiles(
  [XFile(file.path)],
  sharePositionOrigin: sharePositionOrigin, // MANDATORY for iOS
);
```

## 🖼️ 4. IMAGE HANDLING RULES
- **Export:** Encode bytes to Base64 using `base64Encode(bytes)`.
- **Import/UI:** Decode Base64 using `base64Decode()`. Use `Image.memory()` to display.
- **Legacy Migration:** If a Base64 string starts with `/` and its `length < 500`, treat it as an old file path and ignore/migrate it (JPEGs in Base64 start with `/9j/` but are thousands of chars long).

## ✅ 5. PRE-OUTPUT CHECKLIST
Before completing your response, ensure internally:
- [ ] Is the Serializer 100% free of I/O operations?
- [ ] Did I use `(map['key'] as num?)?.toDouble()` for all doubles?
- [ ] Does the Adapter clear the database before importing?
- [ ] Does the UI trigger a reload of all relevant Providers after a successful import?
- [ ] Did I include the `sharePositionOrigin` parameter for iOS compatibility?
```