# Repository Guidelines

本项目基于开源项目<https://gitee.com/yudaocode/yudao-ui-admin-vue3实现>

## Project Structure & Module Organization

- `src/` contains the Vue 3 application: pages in `src/views/`, shared UI in `src/components/`, layouts in `src/layout/`, API clients in `src/api/`, and reusable utilities in `src/utils/`.
- `public/` stores static files served as-is.
- `build/` holds Vite build helpers and optimization scripts.
- `types/` contains shared TypeScript declaration files.
- Environment files live at the repo root (`.env`, `.env.dev`, `.env.prod`, etc.); keep local-only overrides in `.env.local`.

## Build, Test, and Development Commands

- `pnpm dev` runs the app locally with `env.local`.
- `pnpm dev-server` runs Vite with the `dev` mode config.
- `pnpm ts:check` type-checks the project with `vue-tsc --noEmit`.
- `pnpm build:local` builds production assets with the default mode.
- `pnpm build:dev | build:test | build:stage | build:prod` builds for the named environment.
- `pnpm preview` builds and then serves the generated bundle for a quick verification pass.
- `pnpm lint:eslint`, `pnpm lint:format`, and `pnpm lint:style` fix JavaScript/TypeScript/Vue, formatting, and style issues.

## Coding Style & Naming Conventions

- Use 2-space indentation, LF line endings, no semicolons, and single quotes where possible.
- Keep lines near 100 characters when practical; Prettier is configured with `printWidth: 100`.
- Prefer `PascalCase.vue` for components, `camelCase.ts` for utilities, and multi-word names for Vue components.
- Follow existing ESLint and Stylelint rules instead of adding ad hoc exceptions. Run the relevant `lint:*` command before submitting changes.

## Testing Guidelines

- There is no dedicated unit-test runner configured in `package.json`.
- Validate changes with `pnpm ts:check`, `pnpm lint:eslint`, and a relevant build command before opening a PR.
- For UI or routing changes, verify the affected flow in `pnpm dev` or `pnpm preview`.

## Commit & Pull Request Guidelines

- This repo uses commitlint with Conventional Commits. Use messages like `feat: add meeting list filter` or `fix: handle empty response`.
- Keep commits focused and describe user-visible impact when possible.
- PRs should include a short summary, linked issue if applicable, and screenshots or screen recordings for UI changes.
- Note any environment or backend changes needed to verify the update.

## Security & Configuration Tips

- Do not commit secrets or machine-specific values into `.env.local` or other local config files.
- When touching auth, API, or permission code, double-check related files in `src/permission.ts`, `src/config/axios/`, and `src/store/modules/`.
