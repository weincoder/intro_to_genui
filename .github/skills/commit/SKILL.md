---
name: commit
description: Analiza los cambios en el stage, ejecuta validaciones previas y realiza un commit siguiendo el estándar de Conventional Commits del equipo con emojis.
---

# 🤖 SKILL INSTRUCTIONS: TEAM COMMIT STANDARD

## 🎯 AGENT BEHAVIOR (HOW TO EXECUTE)
When the user asks you to commit the current changes, you MUST follow this exact sequence:
1. **Validate:** Run `dart analyze` to ensure there are no errors or warnings. If issues exist, fix them first.
2. **Test:** Run `flutter test` to ensure no tests are broken.
3. **Stage:** Run `git add .` (or stage the specific files requested).
4. **Analyze Diff:** Review the staged changes to understand WHAT was changed and WHY.
5. **Commit:** Execute the `git commit -m "..."` command using the STRICT template below.

## 🛑 1. COMMIT MESSAGE TEMPLATE
You MUST strictly format the commit message as follows:
```text
<type>(<scope>): <emoji> <Subject line (max 50 chars)>

<Body (MINIMUM 150 characters). Explain in detail WHAT was changed and WHY. Give context to the team.>

Componentes afectados:
- <component_1>
- <component_2>
```

## 🏷️ 2. ALLOWED TYPES AND EMOJIS
You MUST choose exactly ONE type and its corresponding emoji from this list:
- `feat`: 🆕 (New feature)
- `fix`: 🔨 (Bug fix)
- `chore`: 🧹 (Routine tasks, dependencies, etc.)
- `docs`: 📓 (Documentation changes)
- `test`: 🧪 (Adding or fixing tests)
- `style`: 🎨 (Formatting, missing semi colons, etc; no code change)
- `refactor`: 🏗️ (Code change that neither fixes a bug nor adds a feature)
- `perf`: 🛠️ (Code change that improves performance)
- `build`: 🧱 (Changes that affect the build system)
- `ci`: ⚙️ (Changes to our CI configuration files and scripts)
- `revert`: ⚠️ (Reverts a previous commit)

## 📋 3. EXAMPLE OF A VALID COMMIT
```text
feat(auth): 🆕 Implement login screen with Google provider

Se implementó la pantalla de inicio de sesión utilizando la arquitectura limpia previamente definida. Se agregaron los adaptadores para Google SignIn y se conectó el caso de uso principal con la capa de presentación. Esto resuelve el requerimiento del negocio para permitir el acceso rápido de nuevos usuarios sin necesidad de crear contraseñas manuales.

Componentes afectados:
- lib/ui/pages/login_page.dart
- lib/infrastructure/driven_adapters/auth_api.dart
- lib/domain/usecase/auth_use_case.dart
```

## ✅ 4. PRE-OUTPUT CHECKLIST
Before committing, ensure internally:
- [ ] Did I run `dart analyze` and `flutter test`?
- [ ] Is the subject line under 50 characters?
- [ ] Is the body description AT LEAST 150 characters?
- [ ] Did I use the correct `<type>` and `<emoji>`?