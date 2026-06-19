---
name: dart-analyze
description: Ejecuta el análisis estático de Dart/Flutter y resuelve los issues y advertencias encontrados siguiendo las reglas de analysis_options.yaml y las prácticas del equipo
---

# 🤖 SKILL INSTRUCTIONS: DART ANALYZE

## 🎯 AGENT BEHAVIOR (HOW TO EXECUTE)
When the user asks you to analyze or fix code:
1. **Analyze:** Run `dart analyze 2>&1` in the terminal to identify all errors, warnings, and infos.
2. **Prioritize:** Group the issues by severity (Error > Warning > Info).
3. **Resolve:** Apply fixes systematically starting with CRITICAL errors.
4. **Verify:** Re-run `dart analyze` until 0 issues are found. 
5. **Test:** Run `flutter test` to ensure your fixes did not break existing logic.

## 🛑 1. STRICT CORE PRINCIPLES
- **ZERO TOLERANCE:** Delivered code MUST be completely free of errors, warnings, and infos.
- **NO IGNORING:** You are FORBIDDEN from adding `// ignore:` or `// ignore_for_file:` comments unless there is absolutely no other technical solution, and you MUST add a clear comment explaining why.
- **NO CONFIG TAMPERING:** You MUST NOT modify `analysis_options.yaml` to hide or silence issues.

## 🛠️ 2. EXECUTION COMMANDS
Use these commands to perform your tasks:
```bash
# Full project analysis
dart analyze

# Strict analysis (fails even with infos)
dart analyze --fatal-infos

# Auto-apply safe fixes before manual review
dart fix --apply
```

## 🚨 3. RESOLUTION RULES BY CATEGORY

### 3.1. Errors (CRITICAL)
MUST be resolved immediately. NEVER ignore.
- `missing_required_param`: Add the required parameter.
- `missing_return`: Add the missing return statement or change the return type.
- `parameter_assignments`: Do NOT reassign parameters; create a local `final` variable.
- `unawaited_futures`: Add `await` or wrap in `unawaited()`.

### 3.2. Warnings
MUST be resolved before task completion.
- `deprecated_member_use`: Migrate to the recommended API immediately.
- `unused_import`: Remove the import.
- `avoid_print`: Replace `print` with `debugPrint` or the project's custom logger.
- `prefer_const_constructors` / `prefer_const_literals_to_create_immutables`: Add `const`.
- `prefer_final_locals`: Change `var` to `final`.
- `annotate_overrides`: Add the `@override` annotation.

### 3.3. Infos (Linter Rules)
- `prefer_single_quotes`: Change `"..."` to `'...'`.
- `prefer_relative_imports`: Use relative imports for files within `lib/`.
- `unnecessary_string_interpolations`: Replace `'$var'` with `var` when no other text is present.
- `cascade_invocations`: Use `..` when invoking multiple methods on the same object.

## 📊 4. CODE METRICS RULES (dart_code_linter)
If the project uses custom metrics, you MUST refactor the code if it exceeds these limits:
| Metric | Limit | Fix Strategy |
|---|---|---|
| `cyclomatic-complexity` | 20 | Extract complex logic into private methods. |
| `maximum-nesting-level` | 5 | Invert `if` conditions (guard clauses), use early returns. |
| `number-of-methods` | 10 | Apply SRP, extract logic into a new class. |
| `number-of-parameters` | 4 | Group parameters into a configuration Object or a Dart Record. |
| `source-lines-of-code` | 250 | Split into multiple files or smaller classes. |

## ✅ 5. PRE-OUTPUT CHECKLIST
Before completing your response, ensure internally:
- [ ] Does `dart analyze` return 0 issues?
- [ ] Does `flutter test` still pass successfully?
- [ ] Did I avoid adding unjustified `// ignore:` comments?