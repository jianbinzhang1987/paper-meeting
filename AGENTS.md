# Repository Guidelines

## Project Structure & Module Organization
This workspace contains three active projects plus shared documentation and scripts:

- `paper-meeting-server/`: Maven backend. Main modules are `yudao-server/`, `yudao-module-system/`, `yudao-module-infra/`, and `yudao-module-meeting/`.
- `paper-meeting-vue3/`: Vue 3 admin web app. Source code lives in `src/`, static files in `public/`, and shared types in `types/`.
- `paper-meeting-client/`: Flutter client. App code is under `lib/`, tests in `test/`, and platform folders include `android/`, `web/`, and `windows/`.
- `scripts/`: local start/stop helpers and log files.
- `系统文档/` and `参考资料/`: design docs, requirements, and reference materials.

## Build, Test, and Development Commands
Run commands from the relevant subproject directory.

- Backend: `mvn test` runs unit tests; `mvn -pl yudao-server -am package -Dmaven.test.skip=true` builds the runnable server.
- Web app: `pnpm dev` starts the Vue app, `pnpm ts:check` type-checks, and `pnpm build:prod` creates a production build.
- Client: `flutter test` runs widget tests, and `flutter run` starts the app on a connected device or emulator.
- Workspace scripts: `scripts/startup.bat` starts the local stack, while `scripts/stop.bat` stops it.

## Coding Style & Naming Conventions
- Java uses 4-space indentation, UTF-8, Java 17, and the existing `*Controller`, `*Service`, `*Mapper`, `*VO`, `*DTO`, and `*DO` naming patterns.
- Vue/TypeScript uses 2-space indentation, single quotes, and no semicolons where the local style already follows that rule.
- Flutter code should follow Dart formatter defaults; keep widget, screen, and service names descriptive and multi-word.
- Match nearby code before introducing new patterns; do not add format exceptions unless the module already uses them.

## Testing Guidelines
- Place Java tests under `src/test/java` and name them `*Test.java` or `*Tests.java`.
- For the Vue app, validate changes with `pnpm ts:check` and the relevant build command; there is no separate unit-test runner configured here.
- For Flutter, keep tests in `paper-meeting-client/test/` and use `flutter test`.

## Commit & Pull Request Guidelines
Use short, imperative commit subjects. The Vue app already uses Conventional Commits, so prefer messages like `feat: add meeting filter` or `fix: handle empty room list`.
PRs should describe the change, list affected subprojects, and include screenshots or screen recordings for UI work. Note any database, environment, or startup-script changes explicitly.

## Security & Configuration Tips
Do not commit secrets, local environment overrides, generated build outputs, or runtime logs. Review backend YAML files, Vue `.env*` files, and Flutter platform config before changing deployment or authentication behavior.
