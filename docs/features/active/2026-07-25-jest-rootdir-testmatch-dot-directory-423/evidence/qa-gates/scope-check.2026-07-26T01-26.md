# Final QC — Scope Check (file ownership)

Timestamp: 2026-07-26T01-26

Task: [P4-T11]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC17

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

## Invocation 1 — Committed changes since base

Command: `git diff --name-only fb483b84`
EXIT_CODE: 0

Output:
```
docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/issue.md
docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/plan.2026-07-25T21-48.md
docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/research/2026-07-25T22-15-jest-rootdir-testmatch-dot-directory-research.md
docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/spec.md
extensions/drm-copilot/jest.config.cjs
extensions/drm-copilot/run-jest.cjs
jest.config.cjs
run-jest.cjs
```

## Invocation 2 — Working-tree modifications and untracked additions

Command: `git status --porcelain --untracked-files=all`
EXIT_CODE: 0

Output (37 entries):
```
 M docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/plan.2026-07-25T21-48.md
 M extensions/drm-copilot/jest.config.cjs
 M extensions/drm-copilot/run-jest.cjs
 M jest.config.cjs
 M run-jest.cjs
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-extension-coverage.2026-07-26T00-57.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-extension-format.2026-07-26T01-00.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-extension-lint.2026-07-26T01-01.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-extension-typecheck.2026-07-26T01-01.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-git.2026-07-26T00-54.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-root-format.2026-07-26T00-58.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-root-lint.2026-07-26T00-58.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/baseline-root-typecheck.2026-07-26T00-59.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/phase0-instructions-read.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/other/config-diff.2026-07-26T01-03.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/other/regression-test-review.2026-07-26T01-12.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/other/run-jest-diff.2026-07-26T01-05.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/coverage-delta.2026-07-26T01-25.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-extension-coverage.2026-07-26T01-24.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-extension-format.2026-07-26T01-21.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-extension-lint.2026-07-26T01-22.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-extension-test.2026-07-26T01-23.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-extension-typecheck.2026-07-26T01-22.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-root-format.2026-07-26T01-18.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-root-lint.2026-07-26T01-18.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-root-test.2026-07-26T01-20.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/qa-gates/final-root-typecheck.2026-07-26T01-19.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/fail-before-extension-jest.2026-07-26T00-56.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/fail-before-root-jest.2026-07-26T00-55.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/guard-extension.2026-07-26T01-07.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/guard-root.2026-07-26T01-06.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/pass-after-extension-jest.2026-07-26T01-15.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/pass-after-root-jest.2026-07-26T01-14.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/spot-check-readconfig.2026-07-26T01-16.md
?? extensions/drm-copilot/test/jest-config-resolution.test.ts
?? tests/unit/jest-config-resolution.test.ts
```

Both commands are required: this plan performs no commit, so a `HEAD`-only diff would miss the four
uncommitted source modifications and both new test files. Together the two commands enumerate
committed changes since base, uncommitted tracked modifications, and untracked additions.

## Combined Changed-File Inventory

### In-scope source/test files (6 of 6 present)

| # | Path | State | Task |
|---|---|---|---|
| 1 | `jest.config.cjs` | modified (` M`) | [P1-T1] |
| 2 | `run-jest.cjs` | modified (` M`) | [P2-T1] |
| 3 | `extensions/drm-copilot/jest.config.cjs` | modified (` M`) | [P1-T2] |
| 4 | `extensions/drm-copilot/run-jest.cjs` | modified (` M`) | [P2-T2] |
| 5 | `tests/unit/jest-config-resolution.test.ts` | untracked addition (`??`) | [P3-T1] |
| 6 | `extensions/drm-copilot/test/jest-config-resolution.test.ts` | untracked addition (`??`) | [P3-T2] |

Exactly four modified and two untracked additions, as the plan specifies. No seventh source file
appears.

(The four modified files also appear in `git diff --name-only fb483b84` because that command compares
the working tree against base, not `HEAD` against base.)

### Feature-folder documentation and evidence

All remaining entries — 4 committed docs (`issue.md`, `spec.md`, `plan.2026-07-25T21-48.md`,
`research/2026-07-25T22-15-...md`) and 27 untracked evidence artifacts — are under
`docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/**`. Every evidence
artifact is under the canonical `<FEATURE>/evidence/<kind>/` scheme (`baseline/`,
`regression-testing/`, `qa-gates/`, `other/`). No artifact was written to `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical location.

## Forbidden-Path Verification

Each forbidden pattern was checked against the combined 37-entry inventory:

| Forbidden pattern | Matching entries | Verdict |
|---|---|---|
| root `package.json` | none | PASS |
| `tsconfig*.json` (any location) | none | PASS |
| `.vscode-test.*` | none | PASS |
| `.claude/rules/**` | none | PASS |
| `.agents/skills/**` | none | PASS |
| `extensions/drm-copilot/resources/claude-customizations/**` | none | PASS |

Notable: `tsconfig*.json` and `.vscode-test.mjs` are inside the root prettier glob set, and
`tsconfig.json` / `tsconfig.jest.json` / `package.json` / `package-lock.json` are inside the
extension prettier glob set. Neither write-mode formatter run touched any of them —
`npm run format` (root, write mode) was never invoked because `format:check` passed on the first
attempt ([P4-T1]), and `npm --prefix extensions/drm-copilot run format` reported `(unchanged)` for
every file including those four ([P4-T5]). Their absence from both git commands is the confirming
evidence: all are byte-identical to base `fb483b84`.

## Build / Coverage Output

`extensions/drm-copilot/coverage/` (produced by [P4-T9]) does not appear in either command's output.
Confirmed gitignored:

```
$ git check-ignore -v extensions/drm-copilot/coverage
.gitignore:71:extensions/drm-copilot/coverage	extensions/drm-copilot/coverage
```

No scope exception is needed for it.

Output Summary: PASS. The combined inventory from `git diff --name-only fb483b84` and
`git status --porcelain --untracked-files=all` contains 37 entries: the 6 in-scope files (4 modified,
2 untracked additions) plus 31 feature-folder documentation and evidence files, all under
`<FEATURE>/**` with evidence in canonical `evidence/<kind>/` sub-paths. Zero entries match any
forbidden pattern — no root `package.json`, no `tsconfig*.json`, no `.vscode-test.*`, no
`.claude/rules/**`, no `.agents/skills/**`, no
`extensions/drm-copilot/resources/claude-customizations/**`. Gitignored coverage output is absent and
needs no exception. AC17 satisfied.
