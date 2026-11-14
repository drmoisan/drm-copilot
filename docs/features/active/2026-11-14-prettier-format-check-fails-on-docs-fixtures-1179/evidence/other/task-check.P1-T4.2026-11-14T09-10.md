# Task check P1-T4: add the "Check root formatting" step

Timestamp: 2026-11-14T09-10
Command: git -C <worktree> status --porcelain ; grep -c "Check root formatting" .github/workflows/_root-typescript-tests.yml
EXIT_CODE: 0
Output Summary: Changed file: .github/workflows/_root-typescript-tests.yml (modified; step "Check root formatting" running `npm run format:check` inserted after "Install root dependencies" and before "Run root TypeScript toolchain and jest suite", no if: condition, so both matrix legs run it). Step count is exactly 1. .github/workflows/ci.yml is not in the porcelain list. YAML is not a Prettier-checked glob of format:check. Selection: contract tests run in P1-T5 and P1-T6.
