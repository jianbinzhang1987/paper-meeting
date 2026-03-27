# Repository Guidelines

本项目基于<https://gitee.com/yudaocode/yudao-boot-mini开源项目实现。>

## Project Structure & Module Organization

This is a Maven multi-module backend built on Java 17 and Spring Boot. Root modules are `yudao-dependencies` for BOM/version control, `yudao-framework` for shared starters and utilities, `yudao-module-system` and `yudao-module-infra` for business modules, and `yudao-server` as the runnable application. Backend entry points live under `yudao-server/src/main/java`, shared code under `yudao-framework/**/src/main/java`, and SQL scripts in `sql/`. Deployment helpers live in `script/`, and Docker assets are under `script/docker/`. The `yudao-ui/` directory contains separate front-end workspaces.

## Build, Test, and Development Commands

- `mvn clean install package -Dmaven.test.skip=true`: full backend build, matching the Docker build flow.
- `mvn test`: runs unit tests through Surefire.
- `mvn -pl yudao-server -am package -Dmaven.test.skip=true`: builds the server module and required dependencies only.
- `docker compose --env-file script/docker/docker.env up -d`: starts the documented local stack for the backend services.

## Coding Style & Naming Conventions

Use Java 17, UTF-8, and 4-space indentation. Keep package names under `cn.iocoder.yudao...`. Follow the existing naming patterns: `*Controller`, `*Service`, `*ServiceImpl`, `*Mapper`, `*DO`, `*VO`, `*DTO`, and `*Enum`. Prefer Lombok where the codebase already uses it, and keep MapStruct mappers in the same module as the types they convert. There is no repo-wide formatter or Checkstyle configuration in this tree, so match nearby code closely.

## Testing Guidelines

Tests use JUnit 5 with Mockito dependencies available through the BOM. Place tests in `src/test/java` and name them `*Test.java` or `*Tests.java`. Favor focused unit tests over broad integration tests unless the change crosses module boundaries. The repository does not define a coverage gate, so add tests for changed business logic and utility methods whenever practical.

## Commit & Pull Request Guidelines

No local Git history is available in this workspace, so no commit convention could be verified here. Use short, imperative commit subjects with a module prefix when helpful, for example `system: fix tenant cache invalidation`. Pull requests should summarize the change, list affected modules, note any config or SQL changes, and include screenshots for UI-facing work when applicable.

## Configuration & Safety Notes

Do not commit secrets, local environment files, or generated build outputs. Review `yudao-server/src/main/resources/application*.yaml` and `script/docker/docker.env` before changing runtime behavior. If you touch database logic, update the relevant SQL under `sql/` and document the expected migration steps.
