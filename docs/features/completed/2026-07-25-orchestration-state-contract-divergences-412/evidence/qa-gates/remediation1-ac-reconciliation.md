# Acceptance-Criteria Reconciliation (Issue #412, Cycle 1)

Timestamp: 2026-07-25T20-25

Work mode: **full-bug**. AC source is
`docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/spec.md`, section
`## Acceptance Criteria` (lines 237-273). `user-story.md` is not required in full-bug mode.

Command: no command executed for this task. Reconciliation is a review of `spec.md` against the
evidence artifacts listed below.

Reviewed artifacts (all under
`docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/`):

- `remediation-baseline/pester-direct-baseline.md` ([P0-T6])
- `remediation-baseline/poshqc-test-baseline.md` ([P0-T5])
- `regression-testing/remediation1-fail-open-probe-before.md` ([P0-T7])
- `regression-testing/remediation1-new-test-expect-fail.md` ([P1-T2])
- `qa-gates/remediation1-constants-unchanged.md` ([P1-T5])
- `qa-gates/remediation1-byte-mirror.md` ([P1-T6])
- `qa-gates/remediation1-mirror-parity.md` ([P1-T11])
- `regression-testing/remediation1-new-test-pass-after.md` ([P1-T10])
- `regression-testing/remediation1-fail-open-probe-after.md` ([P2-T1])
- `qa-gates/remediation1-phase2-poshqc-format.md` / `-analyze.md` / `-test.md` / `-pester-direct.md` ([P2-T2]..[P2-T5])
- `qa-gates/remediation1-pytest-guard.md` ([P2-T6])
- `qa-gates/remediation1-coverage-comparison.md` ([P2-T7])
- `qa-gates/remediation1-scope-verification.md` ([P2-T8])

EXIT_CODE: 0

## Per-AC result table

### Divergence 1 — step-status vocabulary

| # | Acceptance criterion (abbreviated) | Result | Supporting evidence |
|---|---|---|---|
| 1 | Python validator accepts `step9_status` `passed` / `failed_remediation_required` / `blocked_ci_loop_limit` in plain mode | UNCHANGED (PASS) | [P2-T6] 2123 passed, no Python file modified ([P2-T8]) |
| 2 | Python validator accepts `step6_status: blocked_remediation_loop_limit` in plain mode | UNCHANGED (PASS) | [P2-T6]; [P2-T8] no Python change |
| 3 | Python validator rejects each per-key extra value on non-owning keys | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 4 | Shared `VALID_STEP_STATUS` unchanged; new values carried in a per-key additive map | PASS | [P1-T5]: no diff hunk touches `$script:VALID_STEP_STATUS` or `$script:STEP_SPECIFIC_EXTRA_STATUS`; Python side unmodified ([P2-T8]) |
| 5 | `--require-complete` fails on `failed_remediation_required` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 6 | `--require-complete` fails on `blocked_ci_loop_limit` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 7 | `--require-complete` fails on `blocked_remediation_loop_limit` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 8 | `--require-complete` does not fail on `step9_status: passed` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 9 | Python `--require-pr-creation-ready` fails when `step6_status` is `blocked_remediation_loop_limit` | UNCHANGED (PASS) | [P0-T7] and [P2-T1] both show the Python gate returning the readiness error; [P2-T6] |
| 10 | TypeScript mirror implements per-key acceptance/rejection with byte-identical strings | UNCHANGED (PASS) | [P2-T8]: no TypeScript file changed in this cycle |
| 11 | TypeScript completion check rejects the three values, not `step9_status: passed` | UNCHANGED (PASS) | [P2-T8]: no TypeScript file changed |
| 12 | `OrchestratorState.psm1` implements the same per-key acceptance and rejection behavior, verified by Pester | PASS | [P2-T5]: `accepts step6_status value blocked_remediation_loop_limit` and all `rejects ... on <non-owning key>` cases green; [P1-T5]: constants untouched |
| 13 | `epic_mode: true` + `step9_status: passed` passes plain validation and satisfies `enforce-epic-merge-gate.ps1` with zero hook edits | PASS | [P2-T5]: `passes base validation for an epic_mode checkpoint recording step9_status passed`; [P2-T8]: hook untouched |
| 14 | All pre-existing step-status validator tests (Python, Pester, Jest) pass without fixture modification | PASS | [P1-T2]: 53 pre-existing Pester tests pass with only the new test failing; [P2-T5]: 54/54 pass; [P2-T6]: 2123 passed; no fixture modified ([P1-T1] diff is pure addition) |

### Divergence 2 — complexity-floor semantics

| # | Acceptance criterion (abbreviated) | Result | Supporting evidence |
|---|---|---|---|
| 15 | `compute_complexity_floor` returns `C1` for non-floor single-element and unknown-signal lists | UNCHANGED (PASS) | [P2-T6]; [P2-T8] no Python change |
| 16 | `compute_complexity_floor` returns `C3` for floor signals and mixed lists, `C1` for `[]`, never `C4` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 17 | `Get-ComplexityFloor` in `ModelRouting.psm1` matches `compute_complexity_floor` | UNCHANGED (PASS) | [P2-T4] 1394 tests / 0 failures; [P2-T8]: `ModelRouting.psm1` not in the cycle-modified set |
| 18 | `test_compute_complexity_floor.py` static parity assertion on `FLOOR_SIGNAL_NAMES` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 19 | `ModelRouting.Parity.Tests.ps1` static parity assertion pinning `$script:FLOOR_SIGNAL_NAMES` | UNCHANGED (PASS) | [P2-T4]; [P2-T8]: `config/orchestration-routing.json` untouched |
| 20 | Complexity validator accepts a non-floor-only entry with `floor: C1` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 21 | Complexity validator rejects the same entry with `floor: C3`, naming `C1` | UNCHANGED (PASS) | [P2-T6]; [P2-T8] |
| 22 | `compute_complexity_floor.py` docstrings, no file I/O, under 500 lines | UNCHANGED (PASS) | [P2-T8]: no Python change |
| 23 | `ModelRouting.psm1` performs no file reads at runtime | UNCHANGED (PASS) | [P2-T8]: file not in the cycle-modified set |
| 24 | PR body records the divergence-2 backward-compatibility statement | **UNCHECKED — not regressed** | Pending PR authoring, which is outside this remediation cycle. The prepared text is at `evidence/other/pr-body-backcompat-statement.md`. This cycle did not touch it and cannot satisfy it. |

### Cross-cutting

| # | Acceptance criterion (abbreviated) | Result | Supporting evidence |
|---|---|---|---|
| 25 | `test_push_down_claude_resource_contracts.py` passes; root `.claude/lib` modules and mirrors content-identical | PASS | [P1-T11]: 7 passed, exit 0; [P1-T6]: both files hash `7C34F149...5463991D` |
| 26 | Full per-language toolchain passes for every batch | PASS | [P2-T2] format exit 0 / no changes; [P2-T3] analyze exit 0 / 0 findings; [P2-T4] test exit 0 / 0 failures; [P2-T5] direct Pester exit 0; [P2-T6] pytest exit 0. Single clean pass, no restart. Type-check is not applicable to PowerShell |
| 27 | Line coverage >= 85% and branch coverage >= 75% maintained on changed files | PASS | [P2-T7]: `OrchestratorState.psm1` 96.67% commands (up from 96.64%), 97.17% lines; PowerShell overall 90.26% lines; Python 91.00% lines / 81.84% branches. PowerShell branch coverage is not obtainable (Pester 5 CoverageGutters measures commands) |

## Regression check on the value this cycle constrains

`blocked_remediation_loop_limit` remains **plain-valid** on `step6_status`:

- [P1-T5] confirms `$script:STEP_SPECIFIC_EXTRA_STATUS` still maps
  `step6_status = @('blocked_remediation_loop_limit')` and that neither untouchable constant appears
  in any diff hunk.
- [P2-T5] confirms the untouched base-validation acceptance test
  `accepts step6_status value blocked_remediation_loop_limit` still passes, alongside every
  `rejects blocked_remediation_loop_limit on <non-owning key>` case.

Only the PR-creation readiness gate changed. No acceptance criterion regressed as a result of this
cycle.

## Note on AC coverage of F-1

No criterion in `spec.md` covers the PowerShell PR-creation readiness gate. That absence is the
stated reason `feature-review` classified CR-1 as Major rather than Blocking, and it is why this
cycle checks off no new AC item. Per the acceptance-criteria-tracking protocol, no phantom criterion
was added to `spec.md`; the F-1 closure is recorded in the evidence artifacts instead.

## AC counts

- Total AC items in `## Acceptance Criteria`: **27**
- Checked off (delivered): **26**
- Remaining (unchecked): **1** — item 24, the PR-body backward-compatibility statement, pending PR
  authoring outside this cycle.

Output Summary: All 27 acceptance criteria in `spec.md` were reconciled against evidence. **26 are
PASS or UNCHANGED-PASS**; the single unchecked item (the PR-body divergence-2 backward-compatibility
statement) is pending PR authoring, is outside this remediation cycle's scope, and was not regressed
by it. No criterion regressed: `blocked_remediation_loop_limit` remains plain-valid on `step6_status`
(pinned by the untouched base-validation acceptance test and the [P1-T5] constants check), and only
the PR-creation readiness gate changed. No new AC item was added to `spec.md`.
