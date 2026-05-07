# Phase 0 Policy Read Evidence

Timestamp: 2026-05-06T21:40:00Z
Policy Order:
1. `.github/instructions/general-code-change.instructions.md`
2. `.github/instructions/typescript-code-change.instructions.md`
3. `.github/instructions/general-unit-test.instructions.md`
4. `.github/instructions/typescript-unit-test.instructions.md`
5. `.github/instructions/github-actions.instructions.md`

## Files Read

- `.github/instructions/general-code-change.instructions.md` — General code change policy. Establishes design principles, toolchain loop (format → lint → type-check → test), file size limit (500 lines), error handling rules, naming conventions, and dependency constraints.
- `.github/instructions/typescript-code-change.instructions.md` — TypeScript-specific rules: Prettier formatting, ESLint linting, TSC type checking, Jest testing. Strong typing by default; avoid `any`.
- `.github/instructions/general-unit-test.instructions.md` — Unit test policy: independence, isolation, fast execution, determinism, readability. Coverage >= 80% repository-wide; >= 90% for new modules.
- `.github/instructions/typescript-unit-test.instructions.md` — TypeScript unit test rules: Jest framework, `.test.ts` naming, Arrange-Act-Assert pattern, mock external dependencies.
- `.github/instructions/github-actions.instructions.md` — GitHub Actions policy: workflows must pass `actionlint`, preserve existing job structure unless explicitly requested, use accurate GitHub Actions expression syntax.

## Status

All five required policy files have been read and their constraints are understood. Implementation will comply with all policies.
