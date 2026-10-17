# Remediation Cycle 1 — Executor Preflight, Round 1 (issue #647)

Timestamp: 2026-10-02T00-27
Directive: PREFLIGHT VALIDATION ONLY
Plan: `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/remediation-plan.2026-10-02T00-06.md`
Worktree HEAD: `40a20ac05f7df3c64acc19bc185584aebea0e827` (branch `bug/test-tree-typecheck-not-gated-647`; remote branch at the same SHA)
Result: PREFLIGHT: REVISIONS REQUIRED
Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED

## Verification performed (read-only; no repository file other than this record was written)

Scratch work was confined to the session scratchpad and is not persisted here.

| Check | Command or method | Result |
|---|---|---|
| Cited lines | Read `TEST_FILE` | 163 lines; test title at line 82; line 83 begins `// Arrange: optional fields omitted;`; `input` at 84-88; `// Act` at 90; five `in result` assertions at 97-101. All plan citations match. |
| Base SHA | `git merge-base origin/main HEAD` | `1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9`, equal to the audit base. |
| No extension change since the audited head | `git diff --name-only 8a40275c HEAD -- extensions` | no line; the 3786 baseline expectation remains valid. |
| Type-check, P1-T1 state (guard, no loop) and final state | TypeScript compiler API over `tsconfig.jest.json` with `TEST_FILE` replaced in memory | 0 diagnostics in the file and 0 in the program for both states (`exactOptionalPropertyTypes`, `noUnusedLocals`, `noUncheckedIndexedAccess` all active). No cast, `any`, or suppression needed. |
| Lint, both states | ESLint via `--stdin --stdin-filename TEST_FILE --config extensions/drm-copilot/eslint.config.mjs` | exit 0 for both. |
| Prettier, final state | Prettier via `--stdin-filepath TEST_FILE`, output compared with input | identical; section 2 body is already Prettier-stable. Final file is 182 lines. |
| Expected P1-T6 diff | `diff -U0` original vs formatted final state | exactly one removed line (`-    // Arrange: optional fields omitted; ...`); title and five assertions untouched. |
| Guard discrimination | `expect` 30.5.2 from the extension, guard evaluated on key-less and keyed inputs | key-less: fails, message contains `Expected: ArrayContaining [...]`; keyed via `Object.defineProperty`: passes. |
| Baseline P0-T14 | planned tsc command | `TSC_EXIT=0`, `error TS` count 0. |
| Baseline P0-T15 | planned Jest command | `EXIT=0`; `Tests:       5 passed, 5 total`. |
| P2-T8 scans | planned commands against the current tree | AC-12 count 0; skip/only count 0; positive control 1. |
| P2-T9 filter | planned `xargs` pipeline | accepted by the worktree guard; 64 `.ts` paths, so `grep -c` prints `path:count`; filter prints no line. |
| P2-T9 numstat | planned `git diff --numstat` command | prints no line (file unchanged since base). See D2. |
| Guard-denied substrings | search of the plan text | `bash`, `pwsh`, `wsl`, `PIPESTATUS` appear only in the rule 4 prose; no command contains them, no `cd`, no heredoc. |
| Policy files P0-T1 to P0-T11 | `ls` | all 11 exist. |

## G6 warning on P2-T9

Confirmed false positive. The `grep -c ''` span uses an empty pattern to count physical lines; it asserts no search literal, so the wrap-fragility G6 reports cannot apply. The count is the value the AC-13 line-limit condition needs (163 at HEAD; 182 expected after the change).

## Defects

### D1 — Rule 11 does not clearly permit `TEST_FILE` as a dirty path during Phase 1

[P1-T4] requires `git status --porcelain` to list "only permitted dirty paths (rule 11)". At that point `TEST_FILE` is modified and uncommitted. Rule 11 names `TEST_FILE` only with the qualifier "(in Phase 2, only after a loop-restart repair)", and [P1-T6] separately says "lists `TEST_FILE` as modified and otherwise only permitted dirty paths", which implies `TEST_FILE` is not otherwise permitted. Under rule 12 an executor reading rule 11 strictly would stop [P1-T4] as BLOCKED.

Delta (rule 11, replace the final clause):
- Old: `; or `TEST_FILE` (in Phase 2, only after a loop-restart repair).`
- New: `; or `TEST_FILE` (in Phase 1, from [P1-T1] until the [P1-T8] commit; in Phase 2, only after a loop-restart repair).`

### D2 — [P2-T9] numstat condition names a value that the success case does not print

`git diff --numstat 1b1e349f... -- extensions/drm-copilot/test/extension.workflow-commands.test.ts` prints no line, because the file is unchanged since the base (verified at HEAD; also recorded in `qa-gates/ac13-line-limits.2026-10-01T23-18.md`). The acceptance condition "the numstat added count is at most its deleted count" therefore refers to a count that is never printed. The parent plan ([P5-T11], [P5-T13]) carried the empty-output branch; this plan dropped it.

Delta ([P2-T9] Acceptance, replace the second clause):
- Old: `the numstat added count is at most its deleted count;`
- New: `the numstat command prints no line (the file is unchanged since `BASE_SHA`), or prints one line whose added count is at most its deleted count;`

## Delta self-check

Both deltas are wording changes to acceptance prose. Neither adds a command, a write path, a shell construct the worktree guard refuses, or a placeholder in an asserted token. Each keeps the condition able to fail: D1 still rejects any dirty path outside the named set, and D2 still fails on a numstat row whose added count exceeds its deleted count. The delta text uses neutral wording consistent with `.claude/rules/tonality.md`.
