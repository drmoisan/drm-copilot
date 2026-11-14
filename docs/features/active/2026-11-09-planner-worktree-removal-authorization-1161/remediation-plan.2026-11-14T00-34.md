# 2026-11-09-planner-worktree-removal-authorization - Remediation Plan (cycle 1)

- **Issue:** #1161
- **Branch:** `feature/planner-worktree-removal-authorization-1161` (PR #1176)
- **Remediation-Mode:** proportionate (preflight and execution run in one executor delegation)
- **Requirement source:** `remediation-inputs.2026-11-14T00-34.md` (finding PA-1 only)
- **Context:** `spec.md` (D11, `### Field shape`, `### Validator error strings`), `user-story.md` (`## Acceptance Criteria`, operator story criterion 1), approved plan `plan.2026-11-09T16-33.md`, review artifacts stamped `2026-11-14T00-34`.
- **Work Mode:** full-feature

## Required References

- Policies: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/typescript.md`, `.claude/rules/plan-acceptance-gates.md`.
- Tool routes, launchers, sibling-worktree command shapes, the batch budget, hook context, and CI shape are owned by `.claude/skills/execution-environment/SKILL.md` and are not restated here.
- Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task (evidence `FEATURE/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`), the full loop at the phase gate and in the final QA loop.

## Terms and Standing Rules

- `FEATURE` is `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161`. Evidence goes to `FEATURE/evidence/<kind>/<name>.<timestamp>.md`, stamped with the UTC write time read from the clock; a consumer selects the lexicographically greatest match. Evidence is append-only: no file is back-dated, edited, or deleted, and no receipt id or timestamp is invented.
- `SCRATCH` resolves to `<session scratchpad>/issue-1161/`; scratch file names start with `issue-1161-`. Artifacts record the token `SCRATCH`, never a host path, host name, or absolute path.
- The worktree is the existing sibling worktree of this branch; no worktree or branch is created. Scope diffs anchor on the merge base of `origin/main` and `HEAD`. If `origin/main` advances, the orchestrator merges it into the branch before the final QA phase.
- Shared blank set (decision RB-1): a `recorded_at` value is blank when every character is one of exactly six ASCII characters: U+0020 space, U+0009 tab, U+000A line feed, U+000D carriage return, U+000B vertical tab, U+000C form feed. The empty string is blank. No other character is blank, including U+00A0, U+0085, U+001F, U+200B, and U+FEFF. Python states the set once as the module constant `_RECORDED_AT_BLANK_CHARS` (the six characters, written with the escapes for tab, line feed, carriage return, `\x0b`, and `\x0c`) and tests `recorded.strip(_RECORDED_AT_BLANK_CHARS)`; TypeScript states it once as the module constant `RECORDED_AT_BLANK`, the anchored regular expression whose class holds the same six characters (space, `\t`, `\n`, `\r`, `\v`, `\f`), and tests `RECORDED_AT_BLANK.test(recordedAt)`. Neither runtime calls its native `strip()` or `trim()` for this rule. Reason: native whitespace sets differ between Python and ECMAScript (the PA-1 probe), and an explicit ASCII class is identical by construction.
- Consequence recorded for review: U+00A0 alone, previously rejected by both runtimes, is accepted by both after this change; both runtimes still agree, which is what D11 requires.
- No new Python module; `scripts/dev_tools/validate_epic_planner_state.py` is edited in place. No error string, public signature, `coverageThreshold` entry, CLI, or MCP artifact type changes. No spec acceptance criterion changes. No PowerShell file changes, so the Pester gate is not run.
- Test gates are parallel only: one `pytest -n auto` run with coverage and one Jest coverage run in `extensions/drm-copilot` through its normal workers, each re-run only after a fix, one suite at a time on this machine. Integration and golden suites run in CI only.

## Existing Test Dispositions (recorded_at behavior)

Found by searching the test tree for `recorded_at`, `recordedAt`, the two symbols `_validate_planner_worktrees` and `validateEntryFields`, the corpus directory name, and the error string `recorded_at must be a non-empty string when present`.

- `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py` `test_corpus_holds_the_planned_file_count`: updated; `EXPECTED_CORPUS_COUNT` moves from 17 to 21 because four fixtures are added (P1-T1). The module docstring and the count comment are updated to match.
- Same file, `test_validator_reproduces_the_corpus_errors` and `test_removing_the_key_removes_every_planner_error`: unchanged code; gain four parametrized rows from the new fixtures.
- Same file, `test_corpus_exercises_accepting_and_rejecting_rows`, `test_key_absent_checkpoint_keeps_its_existing_error_list`, `test_planner_errors_follow_the_existing_checks`: unchanged; unaffected.
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts` `holds exactly the planned number of files`: updated; `EXPECTED_CORPUS_COUNT` moves from 17 to 21 (P1-T1).
- Same file, `reproduces the expected errors for $name` and `reports no error for $name once the key is removed`: unchanged code; gain four rows.
- Same file, `exercises both an empty and a non-empty expected error list`, `appends planner errors after the max_parallel_features error`, `returns no error from the module when the key is absent`: unchanged; unaffected.
- Corpus `tests/fixtures/epic_planner_state_planner_worktrees/blank-recorded-at.json` (three spaces) and `multiple-errors-in-order.json` (empty string and the integer 5): unchanged; both values remain blank or non-string under RB-1, so their `expected_errors` hold.
- `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py`, `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts`, `tests/scripts/claude-runtime/planner-worktree-removal-contract.Tests.ps1` (token presence of `recorded_at` in skill sections), and the owner-directive and parallel-admission suites: unchanged; they assert other `recorded_at` fields or wording and do not reach either changed function.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Remediation baseline

- [x] [P0-T1] Record the cycle start and the Python static baseline. Write `FEATURE/evidence/remediation-baseline/python-static.<timestamp>.md` with `CycleStartHead:` (the branch head commit at cycle start, read with git) and Black check, Ruff, and Pyright over `scripts/dev_tools/validate_epic_planner_state.py` and `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py`.
  - Acceptance: artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, each step's exit code and finding count, and the physical line count of the Python validator; Black runs in check mode, so the tree is unchanged.
- [x] [P0-T2] Capture the TypeScript static baseline in `extensions/drm-copilot`: Prettier check, ESLint, and the type check over `src/lib/validate/epic-planner-state-planner-worktrees.ts` and `test/lib/validate/epic-planner-state-planner-worktrees.test.ts`. Write `FEATURE/evidence/remediation-baseline/typescript-static.<timestamp>.md`.
  - Acceptance: required fields present with each step's exit code and finding count; Prettier runs in check mode.
- [x] [P0-T3] Run the `Phase 0 baseline` pytest gate: one `pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1161-pytest-baseline.json --cov` run (bare `--cov` last). Write `FEATURE/evidence/remediation-baseline/pytest-gate.<timestamp>.md`.
  - Acceptance: `Output Summary:` records pass and fail counts, repo-wide line and branch coverage, and the line and branch figures of `scripts/dev_tools/validate_epic_planner_state.py` read from the JSON report, with that file's missing-branch list.
- [x] [P0-T4] Run the `Phase 0 baseline` Jest gate: one coverage run in `extensions/drm-copilot` through its normal workers. Write `FEATURE/evidence/remediation-baseline/jest-gate.<timestamp>.md`.
  - Acceptance: `Output Summary:` records pass and fail counts and the line and branch figures of `src/lib/validate/epic-planner-state-planner-worktrees.ts`, read from `extensions/drm-copilot/coverage/lcov.info`.

### Phase 1 — Shared blank set and corpus rows (PA-1)

- [ ] [P1-T1] Add four corpus files under `tests/fixtures/epic_planner_state_planner_worktrees/`, each a copy of `blank-recorded-at.json` with its own `name` (equal to the stem) and `notes`, and only the entry's `recorded_at` changed, written with JSON `\u` escapes: `recorded-at-byte-order-mark.json` (`\ufeff`, `expected_errors` empty), `recorded-at-unit-separator.json` (`\u001f`, empty), `recorded-at-next-line.json` (`\u0085`, empty), and `blank-recorded-at-ascii-controls.json` (space, tab, line feed, carriage return, `\u000b`, `\u000c`; `expected_errors` holds the single string `Epic planner checkpoint planner_worktrees[0].recorded_at must be a non-empty string when present.`). Set `EXPECTED_CORPUS_COUNT` to 21 in `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts`, and update the Python docstring and count comment.
  - Acceptance: each new file parses as JSON, its raw bytes hold the `\u` escape rather than the literal character, and it holds no absolute host path (AC-27); the two count tests pass in the task check.
- [ ] [P1-T2] [expect-fail] Record the fail-before run of the two corpus suites at the unchanged validators: the Python corpus module through pytest with `-n auto`, and the TypeScript corpus file through Jest. Write `FEATURE/evidence/regression-testing/recorded-at-fail-before.<timestamp>.md`.
  - Acceptance: exactly three rows fail, each named in the artifact: `test_validator_reproduces_the_corpus_errors[recorded-at-unit-separator]` and `test_validator_reproduces_the_corpus_errors[recorded-at-next-line]` (Python reports an error the fixture does not expect) and `reproduces the expected errors for recorded-at-byte-order-mark` (TypeScript reports an error the fixture does not expect); every other row passes. This shows each runtime's current set disagrees with RB-1, so a one-sided revert fails that side's parity suite. Tree unchanged by the task.
- [ ] [P1-T3] In `scripts/dev_tools/validate_epic_planner_state.py`, add the module constant `_RECORDED_AT_BLANK_CHARS` (RB-1) with a comment that names the six characters and states that the TypeScript twin uses the same set, and change the `recorded_at` test in `_validate_planner_worktrees` to strip with that constant; update the function docstring to state the blank rule.
  - Acceptance: task check passes the Python corpus module with zero failures, including the two Python rows that P1-T2 recorded failing; the error string is unchanged.
- [ ] [P1-T4] In `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`, add the module constant `RECORDED_AT_BLANK` (RB-1) with a TSDoc comment naming the six characters and the Python twin, and change the `recorded_at` test in `validateEntryFields` to use it instead of `trim()`.
  - Acceptance: task check passes the TypeScript corpus file with zero failures, including `reproduces the expected errors for recorded-at-byte-order-mark`; the error string and the export surface are unchanged.
- [ ] [P1-T5] In `FEATURE/spec.md` `### Field shape (planner_worktrees[] entry)`, replace the rule text of the `recorded_at` row in place (one row, no line added or removed) with: a string holding at least one character outside the blank set U+0020, U+0009, U+000A, U+000B, U+000C, U+000D, followed by the unchanged parenthetical. No acceptance criterion, decision row, or error string is edited.
  - Acceptance: the row names all six code points; the git diff from the `CycleStartHead` commit (P0-T1) to the worktree for `FEATURE/spec.md` shows exactly one removed and one added line, both the `recorded_at` row.
- [ ] [P1-T6] [phase-gate] Run stages 1 to 6 of the toolchain loop for Python and TypeScript: format, lint, type check, architecture boundary, the unit stage as one `pytest -n auto` run and one Jest run in `extensions/drm-copilot`, and contract checks. Write `FEATURE/evidence/qa-gates/phase-gate.P1.<timestamp>.md`.
  - Acceptance: one clean pass with zero failing tests in both runs; a failure or auto-fix restarts the loop from formatting and the artifact records the clean pass.

### Phase 2 — Final QA, verification, and self-review

- [ ] [P2-T1] Final-QC Python static artifact: Black check, Ruff, and Pyright over the two Python files of P0-T1. Write `FEATURE/evidence/qa-gates/python-static.<timestamp>.md`.
  - Acceptance: each step exit 0 with zero findings; Black prints its "would be left unchanged" summary; a change or failure restarts the loop.
- [ ] [P2-T2] Final-QC TypeScript static artifact: Prettier check, ESLint, and the type check over the two TypeScript files of P0-T2. Write `FEATURE/evidence/qa-gates/typescript-static.<timestamp>.md`.
  - Acceptance: each step exit 0 with zero findings.
- [ ] [P2-T3] Final pytest gate: one `pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1161-pytest-final.json --cov` run. Write `FEATURE/evidence/qa-gates/pytest-gate.<timestamp>.md`.
  - Acceptance: zero failures; no new failing test against the P0-T3 artifact; `scripts/dev_tools/validate_epic_planner_state.py` line coverage 100% and branch coverage not below the `Phase 0 baseline`, with no missing branch inside `_validate_planner_worktrees`.
- [ ] [P2-T4] Final Jest gate: one coverage run in `extensions/drm-copilot` through its normal workers. Write `FEATURE/evidence/qa-gates/jest-gate.<timestamp>.md`.
  - Acceptance: zero failures; `src/lib/validate/epic-planner-state-planner-worktrees.ts` at 100% lines and 100% branches from `lcov.info`; its `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` is unchanged.
- [ ] [P2-T5] Coverage delta verification. Write `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md` comparing P0-T3 with P2-T3 and P0-T4 with P2-T4.
  - Acceptance: records baseline, post-change, and changed-line coverage for both files and repo-wide figures for each gate; every changed line is covered; no per-file or repo-wide drop.
- [ ] [P2-T6] Scope check. Write `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md` listing the paths changed since `CycleStartHead` (from P0-T1) with `git diff --name-only` against that commit and `git status --porcelain`.
  - Acceptance: every path is one of the two validators, the two corpus test files, the four new fixtures, `FEATURE/spec.md`, `FEATURE/user-story.md`, this plan, or a file under `FEATURE/evidence/`; no PowerShell file, mirror, manifest, or `jest.config.cjs` change.
- [ ] [P2-T7] Re-check user-story criterion 1 (operator story, `planner_worktrees` accepted and malformed entries rejected with byte-identical strings) against P1-T2, P2-T3, and P2-T4, and check its box in `FEATURE/user-story.md` when that evidence passes. Write `FEATURE/evidence/other/user-story-recheck.<timestamp>.md` naming the evidence files.
  - Acceptance: the criterion's checkbox is checked only if P2-T3 and P2-T4 both show zero failures over the 21-file corpus; no other criterion text changes.
- [ ] [P2-T8] Self-review: walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and confirm PA-1 is closed. Write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Acceptance: no FAIL row; a FAIL is fixed, the QA loop re-run, and a new self-review file written.

## Pre-Mortem

- Review checklists: P2-T8 walks all three templates against the merge-base diff; PA-1's required changes (shared class, spec wording, three named fixtures, test dispositions, criterion 1 re-check) map to P1-T1 to P1-T5 and P2-T7.
- Coverage: per-file figures come from the single gate runs P2-T3 and P2-T4 and are compared with P0-T3 and P0-T4 in P2-T5; the TypeScript threshold entry is not touched; the new constant branches are exercised by both accepting and rejecting corpus rows.
- Mirror parity: not applicable for bundles; neither validator nor any fixture has a bundled or Codex mirror, and no fact of the execution-environment brief changes, so no brief-update task is needed. Cross-runtime parity is the subject of the change and is pinned by the shared corpus (P1-T1, P1-T2).
- File size: the Python validator grows by about three lines from just under 500, which is the guidance tier only and far below the 800 hard block; the TypeScript module and both test files stay well below 500.
- Test isolation: gates are one `pytest -n auto` run and Jest through its normal parallel workers, each re-run only after a fix; no `Invoke-PoshQCParallelTest` run because no PowerShell file changes. Tests read committed fixtures only and write no file.
- CI-only behavior: fixtures are LF JSON with `\u` escapes, so `.gitattributes` normalization and Linux runners read identical bytes; no drive-rooted path or gitignored state is read.
- Evidence: every artifact is new, append-only, stamped from the clock in UTC, carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and records `SCRATCH` instead of any host path.
