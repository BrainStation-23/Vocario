# AGENT.md for AI Audio Summarizer Flutter App

## Project Overview
A cross-platform Flutter app for AI audio summarization, targeting iOS and Android. Features include direct voice input, audio file upload, extract audio from video, summarization, and result display. The app uses Riverpod for state management with Clean Architecture principles.

## Folder Structure
- `lib/`
    - `core/`: Shared utilities, models, and services.
    - `features/`: Feature-specific modules (e.g., `auth/`, `tasks/`).
    - `data/`: API calls, repositories, and local storage.
    - `domain/`: Business logic, use cases, and entities.
    - `presentation/`: Widgets, screens, and Riverpod providers.
- Use snake_case for file names (e.g., `audio_summarizer.dart`).
- Group related files in feature-specific folders (e.g., `lib/features/audio_summarizer/`).

## Coding Standards
- Use package imports: `import 'package:my_app/core/models/audio_summarizer.dart';`.
- Avoid relative imports for `lib/` files.
- Class names: PascalCase (e.g., `AudioSummarizer`).
- Variables/functions: camelCase (e.g., `summarizeAudio`).
- Follow `dart format` for code formatting.
- Use `const` constructors for widgets where possible.
- Use `equatable` for model classes to simplify equality checks.
- Use `logger` package for logging instead of `print`.
- Ensure all widgets are stateless unless state management is explicitly required.
- Avoid hardcoding strings; use constants or localization.
- Start each function name with a verb.
- Avoid hardcoded colors and styles.
- Use [`ThemeExtension`](https://api.flutter.dev/flutter/material/ThemeExtension-class.html) for consistent styling.
- Except data models, all file size should be less than 150 lines.

## Architecture Guidelines
- Follow Clean Architecture with three layers:
    - `data/`: Handles API calls and local storage (e.g., `AudioSummarizerRepositoryImpl`).
    - `domain/`: Contains use cases and business logic (e.g., `SummarizeAudioUseCase`).
    - `presentation/`: Includes UI (widgets/screens) and Riverpod providers (e.g., `AudioSummarizerProvider`).
- Use Riverpod for state management with `riverpod`.
- Example module structure for `audio_summarizer`:
  ```
  lib/features/audio_summarizer/
    ├── data/
    │   ├── models/
    │   │   └── audio_summarizer_model.dart
    │   └── repositories/
    │       └── audio_summarizer_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── audio_summarizer.dart
    │   └── usecases/
    │       └── summarize_audio.dart
    ├── presentation/
    │   ├── providers/
    │   │   └── audio_summarizer_provider.dart
    │   └── screens/
    │       └── widgets/
    │           └── subWidget1.dart 
    │           └── subWidget2.dart
    │       └── audio_summarizer_screen.dart    
  ```

## Preferred Packages
- State management: `riverpod: 2.6.1`.
- Networking: `dio: 5.8.0+1`.
- Database: `flutter_secure_storage 9.2.4`.
- Testing: `flutter_test`, `mockito: 5.5.0`.
- Utilities: `logger: 2.6.1`.
- Use fakes instead of mocks for unit tests (e.g., `FakeAsyncClient` for `dio`).

## AI Behavior
- Generate code without excessive comments unless explicitly requested.
- Include unit tests for repositories and use cases when generating new modules.
- Avoid deprecated Flutter widgets
- Provide a brief overview of generated code only if explicitly asked.
- Prioritize generating UI widgets, repositories, and BLoC files unless specified otherwise.

## Testing Guidelines
- Use `flutter_test` for unit and widget tests.
- Write unit tests for all repository and use case methods.
- Use `mockito` for mocking dependencies.
- Aim for at least 80% test coverage.

## External Integrations
- Use Firebase Crashlytics for crash reporting.
- Use `dio` for API calls to external services.```


https://ai.google.dev/gemini-api/docs/audio#javascript