# Committed Change-Set Assertion — `main...HEAD` (#414, [P6-T2])

Timestamp: 2026-07-25T22-18

Verified against the pushed head `478f40b83be80d660e6443fa7756e9729f9f9b36` ([P6-T1]). This is the committed-range form of the assertion that [P3-T3] performed against the working tree, and it is the form the `spec.md` acceptance criteria are worded against.

## Command 1 — full committed file list

Command: `git diff --name-only main...HEAD` (working directory: repository root)
EXIT_CODE: 0

```text
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/compile-extension-baseline.2026-07-25T17-15.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/format-check-root-baseline.2026-07-25T17-09.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/git-baseline.2026-07-25T17-00.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/lint-extension-baseline.2026-07-25T17-13.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/lint-root-baseline.2026-07-25T17-10.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/npm-audit-baseline-mcp-server.2026-07-25T17-02.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/npm-audit-fail-before-extension.2026-07-25T17-02.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/npm-audit-fail-before-root.2026-07-25T17-01.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/npm-ci-extension.2026-07-25T17-06.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/npm-ci-root.2026-07-25T17-03.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-coverage-extension.2026-07-25T17-08.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-unit-coverage-root.2026-07-25T17-05.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/typecheck-extension-baseline.2026-07-25T17-14.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/typecheck-root-baseline.2026-07-25T17-11.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/change-set-assertion.2026-07-25T21-52.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/lockfile-assertions.2026-07-25T21-48.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/manifest-assertions.2026-07-25T21-50.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/phase0-gate-baseline-escalation.2026-07-25T17-18.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/phase0-instructions-read.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/coverage-comparison-extension.2026-07-25T22-12.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/coverage-comparison-root.2026-07-25T22-05.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-compile-extension.2026-07-25T22-09.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-format-check-root.2026-07-25T21-58.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-lint-extension.2026-07-25T22-07.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-lint-root.2026-07-25T21-59.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-npm-ci-extension.2026-07-25T22-06.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-npm-ci-root.2026-07-25T21-56.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-coverage-extension.2026-07-25T22-11.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-test-unit-coverage-root.2026-07-25T22-02.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-typecheck-extension.2026-07-25T22-08.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/final-typecheck-root.2026-07-25T22-00.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/mcp-server-install-build.2026-07-25T22-14.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/npm-install-extension.2026-07-25T21-44.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/qa-gates/npm-install-root.2026-07-25T21-40.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/regression-testing/npm-audit-pass-after-extension.2026-07-25T21-45.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/regression-testing/npm-audit-pass-after-root.2026-07-25T21-42.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/regression-testing/npm-audit-post-change-mcp-server.2026-07-25T21-54.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/issue.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/plan.2026-07-25T15-42.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/research/2026-07-25T10-45-brace-expansion-ghsa-mh99-remediation-research.md
docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/spec.md
extensions/drm-copilot/package-lock.json
extensions/drm-copilot/package.json
package-lock.json
package.json
```

47 paths total: 43 under `docs/features/` (the feature's `issue.md`, `spec.md`, `plan`, `research/`, and 39 evidence artifacts, of which the `issue.md`, `research/`, and part of the plan/spec content were committed at branch creation) plus the 4 dependency files.

## Assertion (a) — no listed path starts with `packages/mcp-server`

Command: `git diff --name-only main...HEAD | grep -c '^packages/mcp-server'` (working directory: repository root)
EXIT_CODE: 1 (grep no-match)

```text
0
```

Result: PASS. Zero matches. `packages/mcp-server/package.json` and `packages/mcp-server/package-lock.json` are unmodified on the pushed head, satisfying the `spec.md` acceptance criterion "`packages/mcp-server/package.json` and `packages/mcp-server/package-lock.json` are unmodified (`git diff --name-only main...HEAD` lists no `packages/mcp-server` paths)".

## Assertion (b) — remaining set after exclusions is exactly the four dependency files

Command: `git diff --name-only main...HEAD | grep -v '^docs/features/' | grep -v '^artifacts/orchestration/'` (working directory: repository root)
EXIT_CODE: 0

```text
extensions/drm-copilot/package-lock.json
extensions/drm-copilot/package.json
package-lock.json
package.json
```

Result: PASS. After excluding paths under `docs/features/` (feature documentation) and `artifacts/orchestration/` (the orchestration checkpoint; none present in this range), the remaining set is exactly the four files `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json` — no more and no fewer. No source file, workflow file, or configuration file is included.

Output Summary: Both assertions PASS on the pushed head `478f40b83be80d660e6443fa7756e9729f9f9b36`. `git diff --name-only main...HEAD` lists 47 paths and none begins with `packages/mcp-server` (grep exit 1, zero matches). After excluding `docs/features/` and `artifacts/orchestration/`, the remaining set is exactly the four authorized dependency files. This satisfies the `spec.md` acceptance criteria on the four-file change set and on `packages/mcp-server` being untouched.
