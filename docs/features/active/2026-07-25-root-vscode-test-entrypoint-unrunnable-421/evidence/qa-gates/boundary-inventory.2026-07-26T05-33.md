# QA Gate — Boundary Inventory (#421)

Timestamp: 2026-07-26T05-33

Task: [P4-T7] — AC9 evidence.

Command:

```
git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede
git status --porcelain
git status --porcelain run-jest.cjs jest.config.cjs package-lock.json .claude/rules .agents/skills extensions/drm-copilot/resources/claude-customizations
git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede -- run-jest.cjs jest.config.cjs package-lock.json .claude/rules .agents/skills extensions/drm-copilot/resources/claude-customizations
node -e '(per-key comparison of package.json against the base commit)'
```

EXIT_CODE: 0

## 1. Committed Change Set Since Base `fb483b84`

```
$ git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede
.github/workflows/README.md
.github/workflows/ci.yml
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-ci-inventory.2026-07-26T05-11.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-format-check-root.2026-07-26T05-08.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-lint-root.2026-07-26T05-08.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-npm-ci-root.2026-07-26T05-05.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-test-coverage-root.2026-07-26T05-10.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/baseline-typecheck-root.2026-07-26T05-09.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/phase0-branch-baseline.2026-07-26T05-04.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/other/prior-art-vscode-test-removal-2f67b888.2026-07-26T05-12.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/guard-test-local-run.2026-07-26T05-22.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/scripts-block-verification.2026-07-26T05-16.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/regression-testing/fail-before-npm-test-integration.2026-07-26T05-07.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/regression-testing/fail-before-npm-test.2026-07-26T05-06.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/issue.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/plan.2026-07-25T21-43.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/research/2026-07-25T23-45-root-vscode-test-entrypoint-scope-research.md
docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/spec.md
package.json
tests/unit/vscode-test-removal.test.ts
```

## 2. Uncommitted State at Inventory Time

```
$ git status --porcelain
 M .github/workflows/README.md
 M .github/workflows/ci.yml
 M docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/plan.2026-07-25T21-43.md
?? .github/workflows/_root-typescript-tests.yml
?? docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/coverage-comparison-root.2026-07-26T05-31.md
?? docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-format-check-root.2026-07-26T05-26.md
?? docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-lint-root.2026-07-26T05-26.md
?? docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-stages-4-6-7-na-root.2026-07-26T05-28.md
?? docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-test-coverage-root.2026-07-26T05-29.md
?? docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/final-typecheck-root.2026-07-26T05-27.md
```

`.github/workflows/_root-typescript-tests.yml` is the new reusable workflow (untracked at inventory time, committed in [P5-T1]). All other uncommitted entries are Phase 4 evidence artifacts and the plan checklist.

## 3. Union of Changed Paths, Classified Against the Allowed Set

| Path | Allowed-set member | Verdict |
|---|---|---|
| `package.json` | yes (scripts block only) | ALLOWED |
| `tests/unit/vscode-test-removal.test.ts` | yes | ALLOWED |
| `.github/workflows/_root-typescript-tests.yml` | yes | ALLOWED |
| `.github/workflows/ci.yml` | yes | ALLOWED |
| `.github/workflows/README.md` | yes | ALLOWED |
| `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/**` (17 files: `issue.md`, `spec.md`, plan, research, and 13 evidence artifacts) | yes | ALLOWED |

**The changed-path set is exactly the allowed set. There is no path outside it.**

## 4. Forbidden-Path Verification (Explicit Negative Checks)

```
$ git status --porcelain run-jest.cjs jest.config.cjs package-lock.json .claude/rules .agents/skills extensions/drm-copilot/resources/claude-customizations
(no output)

$ git diff --name-only fb483b8468204e4385b5583c3b3ec4c0a987eede -- run-jest.cjs jest.config.cjs package-lock.json .claude/rules .agents/skills extensions/drm-copilot/resources/claude-customizations
(no output)
```

Both commands returned empty, checked both against the base commit and against the working tree.

| Forbidden path | Modified? | Evidence |
|---|---|---|
| `run-jest.cjs` | No | empty `git diff --name-only` vs base; empty `git status --porcelain` |
| `jest.config.cjs` | No | same |
| `package-lock.json` | No | same (also re-verified after `npm ci` in [P0-T3]) |
| `.claude/rules/**` | No | same |
| `.agents/skills/**` | No | same |
| `extensions/drm-copilot/resources/claude-customizations/**` | No | same |

## 5. `package.json` Per-Key Verification (Non-`scripts` Keys Untouched)

Every top-level key of the current `package.json` was compared by value against `git show fb483b84:package.json`:

```
UNCHANGED  name
UNCHANGED  publisher
UNCHANGED  displayName
UNCHANGED  description
UNCHANGED  version
UNCHANGED  engines
UNCHANGED  overrides
CHANGED     scripts
UNCHANGED  devDependencies
UNCHANGED  dependencies
```

**`scripts` is the only changed top-level key.** `devDependencies` (including `@vscode/test-cli`, `@vscode/test-electron`, and `@types/mocha`, whose removal is the deferred follow-up owned by the sibling orchestration), `dependencies`, `overrides`, and every manifest field are byte-identical to the base commit. No key was added or removed.

## AC9 Conclusion

The change set contains no modification to `run-jest.cjs`, `jest.config.cjs`, `.claude/rules/**`, `.agents/skills/**`, or `extensions/drm-copilot/resources/claude-customizations/**`, and no change to `devDependencies` or `package-lock.json`. AC9 is satisfied.

Output Summary: The union of committed and uncommitted changed paths is exactly the allowed set — `package.json`, `tests/unit/vscode-test-removal.test.ts`, `.github/workflows/_root-typescript-tests.yml`, `.github/workflows/ci.yml`, `.github/workflows/README.md`, and 17 files under the issue-421 feature folder. All six forbidden paths returned empty from both `git diff --name-only` against base `fb483b84` and `git status --porcelain`. A per-key comparison of `package.json` against the base commit shows `scripts` as the **only** changed top-level key; `devDependencies`, `dependencies`, `overrides`, and all manifest fields are unchanged. AC9 evidence established.
