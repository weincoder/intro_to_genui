---
name: dart-testing
description: Genera unit tests y widget tests siguiendo el estándar del equipo (estructura AAA, groups por método, escenarios de error, convención de nombres y ubicación)
---

# 🤖 SKILL INSTRUCTIONS: TESTING FLUTTER

## 🎯 AGENT BEHAVIOR (HOW TO EXECUTE)
When the user asks you to generate tests for a specific file:
1. **Analyze:** Read the source file to identify all public methods, classes, and external dependencies.
2. **Plan:** Output a brief `/plan` listing the `groups` and `tests` you will create for both success and error scenarios.
3. **Execute:** Write the complete test file following the strict rules below.

## 🛑 1. STRICT CORE PRINCIPLES
- **AAA PATTERN:** You MUST ALWAYS use the Arrange → Act → Assert structure in every single test. Add comments `// Arrange`, `// Act`, `// Assert`.
- **COVERAGE MANDATE:** You MUST test BOTH success scenarios AND error/exception scenarios.
- **GROUP ISOLATION:** Every function, method, or UI component tested MUST have its own dedicated `group()`.
- **MOCKING RULE:** NEVER return `null` from a mock unless `null` is the explicitly expected successful response. Mocks must simulate realistic domain data or throw realistic exceptions.

## 📁 2. FILE LOCATION AND NAMING RULES
Mirror the exact path of the source file inside the `test/` folder and append `_test.dart`.
- `lib/src/domain/foo.dart` ➔ `test/src/domain/foo_test.dart`
- `lib/src/ui/bar.dart` ➔ `test/src/ui/bar_test.dart`

## 🧩 3. UNIT TEST PATTERN
Follow this exact structure:
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('[MethodOrClassName]', () {
    test('should [expected behavior] when [scenario/input]', () {
      // Arrange
      final input = ...;
      final expected = ...;

      // Act
      final result = functionUnderTesting(input);

      // Assert
      expect(result, expected);
    });

    test('should throw [Exception] when [invalid scenario]', () {
      // Arrange
      final input = invalidValue;

      // Act
      final call = () => functionUnderTesting(input);

      // Assert
      expect(call, throwsA(isA<CustomException>()));
    });
  });
}
```

## 🖼️ 4. WIDGET TEST PATTERN
Every screen or complex widget MUST be tested using exactly these three groups:

### Group 1: Find the page widgets
Verify key elements render correctly.
```dart
group('Find the page widgets', () {
  testWidgets('should find title and main button', (tester) async {
    // Arrange
    await tester.pumpWidget(fakeApp);

    // Act & Assert
    expect(find.text('Expected Title'), findsOneWidget);
    expect(find.byKey(const Key('main-button')), findsOneWidget);
  });
});
```

### Group 2: Interaction with page widgets
Verify taps, scrolling, and inputs.
```dart
group('Interaction with page widgets', () {
  testWidgets('should trigger action on button tap', (tester) async {
    // Arrange
    await tester.pumpWidget(fakeApp);
    final btn = find.byType(BcBtn);

    // Act
    await tester.tap(btn);
    await tester.pumpAndSettle();

    // Assert
    // Verify state change or interaction result
  });
});
```

### Group 3: Test Page Experience
Verify complete user flows (success and failure).
```dart
group('Test Page Experience', () {
  testWidgets('should complete successful flow', (tester) async {
    // Arrange
    await tester.pumpWidget(fakeApp);

    // Act
    await tester.enterText(find.byKey(const Key('input')), 'valid_data');
    await tester.pump();
    await tester.tap(find.byType(BcBtn));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Success'), findsOneWidget);
  });
});
```

## 🛠️ 5. MOCKING DEPENDENCIES
Use `mocktail`.
```dart
// DO: Return realistic data
when(() => mockRepo.getUser(any())).thenAnswer((_) async => User(name: 'Test'));

// DO NOT: Return null just to pass coverage
when(() => mockRepo.getUser(any())).thenAnswer((_) async => null);
```

## ✅ 6. PRE-OUTPUT CHECKLIST
Before completing your response, ensure internally:
- [ ] Did I mirror the source file path?
- [ ] Are there distinct `groups` for each method/flow?
- [ ] Are Arrange/Act/Assert comments present?
- [ ] Are error scenarios explicitly tested?
- [ ] Do mocks return realistic values instead of `null`?
````</CustomException>