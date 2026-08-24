# Phase 0 Gate-Baseline Escalation (#414)

Timestamp: 2026-07-25T17-18

Trigger: Plan Conventions, "Phase 0 gate-baseline escalation rule" —
> if any Phase 0 gate baseline (P0-T14, P0-T15, P0-T16, P0-T18, P0-T19, P0-T20) records a non-zero exit code, execution stops and the condition is escalated to the planner before Phase 1; the acceptance for the corresponding Phase 4/5 gate remains `EXIT_CODE: 0` and must not be relaxed by the executor.

Status: **TRIGGERED**. `[P0-T14]` recorded `EXIT_CODE: 1`. Execution stopped before `[P1-T1]`. No manifest edit has been made; `package.json`, `package-lock.json`, `extensions/drm-copilot/package.json`, and `extensions/drm-copilot/package-lock.json` are unmodified.

Branch: `bug/npm-audit-brace-expansion` at `fa64e0aded2705823e7b6f7fc20222c3c9b6b884`.
Environment: Node v24.14.0, npm 11.9.0, Windows 11, worktree `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5f77ee3b34398ec5`.

## Phase 0 Baseline Results

| Task | Command | Root | EXIT_CODE | Plan acceptance | Met |
|---|---|---|---|---|---|
| [P0-T6] | `git rev-parse HEAD` / `git status --porcelain` | root | 0 | artifact + SHA | yes |
| [P0-T7] | `npm audit --audit-level=moderate` | root | 1 | non-zero, 22 high | yes (expect-fail) |
| [P0-T8] | `npm audit --audit-level=moderate` | extension | 1 | non-zero, 20 high | yes (expect-fail) |
| [P0-T9] | `npm audit --audit-level=moderate` | mcp-server | 0 | 0, `found 0 vulnerabilities` | yes |
| [P0-T10] | `npm ci` | root | 0 | 0 | yes |
| [P0-T11] | `npm run test:unit:coverage` | root | **1** | `EXIT_CODE: 0` | **NO** |
| [P0-T12] | `npm ci` | extension | 0 | 0 | yes |
| [P0-T13] | `npm run test:coverage` | extension | **1** | `EXIT_CODE: 0` | **NO** |
| [P0-T14] | `npm run format:check` | root | **1** | artifact + recorded code | yes (artifact) — **gate RED** |
| [P0-T15] | `npm run lint` | root | 0 | artifact + counts | yes |
| [P0-T16] | `npm run typecheck` | root | 0 | artifact + count | yes |
| [P0-T17] | `npm run test:integration` | root | 1 | `EXIT_CODE: 1` + verbatim error | yes (expect-fail) |
| [P0-T18] | `npm run lint` | extension | 0 | artifact + counts | yes |
| [P0-T19] | `npm run typecheck` | extension | 0 | artifact + count | yes |
| [P0-T20] | `npm run compile` | extension | 0 | artifact | yes |

`[P0-T11]` and `[P0-T13]` remain unchecked in the plan per the fail-closed evidence rule. All other Phase 0 tasks are checked off with artifacts on disk.

## Condition A — `[P0-T14]` root `format:check` is RED before any #414 edit

Evidence: `evidence/baseline/format-check-root-baseline.2026-07-25T17-09.md`.

```text
[warn] tests/fixtures/discovery_schemas/v1/runtime-characterization-scenario.invalid.json
[warn] tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json
[warn] Code style issues found in 2 files. Run Prettier with --write to fix.
```

Characterization:

- Both files are committed fixtures introduced by `b69a84e1` ("feat(schemas): add versioned legacy-discovery JSON schemas and fixtures (#359)"). `git status --porcelain tests/` is empty, so they are unmodified in the working tree.
- The difference is a real content-level formatting delta, not a line-ending or environment artifact. Diff of `prettier <file>` against the committed file:

```diff
7c7,9
<   "preconditions": ["the covered unit is initialized"],
---
>   "preconditions": [
>     "the covered unit is initialized"
>   ],
15c17,19
<   "evidence_refs": ["evidence-alpha-001"],
---
>   "evidence_refs": [
>     "evidence-alpha-001"
>   ]
```

  Prettier collapses the single-element arrays; the committed fixtures keep them expanded. The same result occurs on any platform.
- No file in the #414 change set can influence this gate. The `format:check` glob set is `src/**`, `tests/**`, `eslint.config.mjs`, `jest.config.cjs`, `.vscode-test.mjs`, `tsconfig*.json`, `run-*.cjs`. Neither `package.json` nor `package-lock.json` is covered.
- No workflow under `.github/workflows/**` invokes root `format:check`, so this is a local policy gate only, not a required CI check. (`grep -n "format:check" .github/workflows` returns no matches.)

Consequence: `[P4-T2]` cannot reach `EXIT_CODE: 0`, and spec acceptance criterion "Root toolchain passes: `npm run format:check` ... exit 0" cannot be satisfied, unless the two fixtures are reformatted. Reformatting them would add two files to the change set and would directly violate the spec acceptance criterion that the change set contains exactly four files.

## Condition B — `[P0-T11]` / `[P0-T13]` coverage commands are RED before any #414 edit

Evidence: `evidence/baseline/test-unit-coverage-root.2026-07-25T17-05.md`, `evidence/baseline/test-coverage-extension.2026-07-25T17-08.md`.

Both `npm run test:unit:coverage` (root) and `npm run test:coverage` (extension) exit 1 with `No tests found`. Cause: this execution runs from a worktree whose absolute path contains the `.claude` dot-directory component. After `<rootDir>` substitution, jest resolves `testMatch` to

```text
C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a5f77ee3b34398ec5/tests/unit/**/*.test.ts
```

The separator preceding `.claude` is emitted as a backslash, which the glob matcher consumes as an escape rather than a path separator, so the pattern reports `0 matches` while jest confirms it walked 434 files (root) / 368 files (extension).

The suites themselves are green against the pre-edit dependency tree. The identical invocations with rootDir-free patterns exit 0:

| Root | Suites | Tests | Line | Branch | Statements | Functions |
|---|---|---|---|---|---|---|
| repository root | 169/169 passed | 2032/2032 passed | 97.00% | 89.06% | 97.00% | 89.28% |
| `extensions/drm-copilot` | 168/168 passed | 2031/2031 passed | 96.33% (37643/39074) | 89.21% (5201/5830) | 96.33% | 89.50% (1100/1229) |

Both exceed the policy thresholds (line >= 85%, branch >= 75%).

Characterization: environment-scoped to this worktree location. It is not a repository defect, does not occur in a checkout whose path has no dot-directory component, and does not occur on CI. Remediation would require editing `jest.config.cjs` (root) and the extension jest config, both outside the four-file change set.

Consequence: `[P4-T5]`, `[P4-T7]`, `[P5-T5]`, and `[P5-T6]` cannot record `EXIT_CODE: 0` for the plan's literal commands from this worktree, and the spec acceptance criteria naming `npm run test:unit:coverage` and `npm run test:coverage` cannot be checked off on that literal basis.

## Unaffected By Either Condition

The core remediation and its verification are unblocked. `npm audit` reads only the lockfile and is independent of both conditions; `lint`, `typecheck`, and `compile` are green at baseline in both affected roots; `[P6-T3]` (dispatched `NPM Audit Gate` CI run) and `[P6-T4]` (mocha `minimatch` substitute verification) are unaffected.

## Requested Plan Delta

The executor does not relax any acceptance criterion. The following options are presented for the planner to choose:

### Option 1 — Accept both conditions as pre-existing and out of scope (no scope change)

Amend the Plan Conventions escalation rule and the affected task acceptances to a baseline-parity form, matching the treatment already given to `[P4-T6]`:

- `[P4-T2]` acceptance becomes: `EXIT_CODE: 0`, or the post-change output is byte-identical to the `[P0-T14]` pre-edit baseline (same two fixture warnings, same exit code), proving this change introduced no new formatting failure. The artifact must state that the two unformatted committed fixtures are a separate pre-existing defect, out of scope for #414.
- `[P4-T5]` / `[P5-T5]` acceptance becomes: `EXIT_CODE: 0`, or the post-change output matches the `[P0-T11]` / `[P0-T13]` pre-edit baseline failure mode, with numeric post-change coverage captured by the rootDir-free equivalent invocation and compared against the recorded baseline values.
- `[P4-T7]` / `[P5-T6]` compare the rootDir-free numeric values on both sides of the change.
- Add a task to report the two pre-existing defects (unformatted fixtures; `<rootDir>` glob artifact under dot-directory paths) as potential issues, alongside the existing `test:integration` follow-up.

Spec acceptance criteria 7 and 8 would then need either the same baseline-parity wording, or would be left unchecked with the gap documented.

### Option 2 — Expand scope to fix the two fixtures (changes the change set)

Add a Phase 1 task to run `npx prettier --write` on the two fixture files and update the spec's four-file change-set criterion to six files. This conflicts with the spec's current Scope & Non-Goals ("In scope: exactly 4 files") and with acceptance criteria 10 and 11, so it requires an explicit spec revision, not an executor decision.

### Option 3 — Re-run execution from a checkout whose path contains no dot-directory

This resolves Condition B only. Condition A is a repository-content condition and would persist.

## Executor Position

Phase 0 is complete and fully evidenced. Phases 1 through 6 are not started. No dependency manifest or lockfile has been touched. Execution resumes on receipt of a revised plan or an explicit instruction to proceed under a stated disposition of Conditions A and B.

Output Summary: The Phase 0 gate-baseline escalation rule fired. `[P0-T14]` (root `npm run format:check`) exits 1 before any #414 edit because of two committed, unformatted JSON fixtures outside the authorized change set. Separately, `[P0-T11]` and `[P0-T13]` exit 1 because of a `<rootDir>` glob artifact caused by the worktree path containing `.claude`; both suites are green (2032 and 2031 tests passing) with coverage above policy thresholds when invoked without the `<rootDir>` prefix. Neither condition is caused by the #414 change, and neither is remediable within the four-file change set the spec authorizes. Execution stopped before Phase 1 as the plan requires.
