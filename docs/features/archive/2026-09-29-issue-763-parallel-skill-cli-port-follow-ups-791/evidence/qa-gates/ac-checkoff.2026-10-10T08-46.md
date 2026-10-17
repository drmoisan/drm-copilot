# Acceptance-Criteria Check-Off — Issue #791

Timestamp: 2026-10-10T08-46
Task: [P9-T2] (records the [P9-T1] result)
Command: grep -c -e "- \[x\] AC-" docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md; grep -c -e "- \[ \] AC-" docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md
EXIT_CODE: 0, 0

Output Summary:
- AC source: `spec.md` (Work Mode full-bug). Checked: 14. Unchecked: 7. Sum: 21.
- The only edit to `spec.md` was `- [ ]` to `- [x]` on 14 lines (word-level diff shows only 14 `[ ]` to `[x]` token changes).
- Deferred AC set (union of `CI-DEFERRED-ACS:` lines across [P4-T11], [P4-T12], [P4-T13], [P4-T14], [P8-T9], [P8-T13]): AC-8, AC-9, AC-10, AC-11, AC-12, AC-13 (6 distinct IDs).
- Unchecked count 7 = 1 (AC-18) + 6. `PENDING-CI` rows below: 7.

## Operator adjustment to the [P9-T1] acceptance

The plan's [P9-T1] deferred set is the union over [P4-T11], [P4-T12], [P4-T13], and [P8-T9]. Under binding operator constraint 3, AC-13 is also left unchecked as PENDING-CI because its Pester evidence ([P4-T14], [P8-T13]) is CI-deferred: the PoshQC MCP test tool returns no `Failed:` count or case result. The count acceptance is therefore: checked + unchecked = 21, and unchecked = 1 (AC-18) + distinct IDs in the union of `CI-DEFERRED-ACS:` lines across [P4-T11], [P4-T12], [P4-T13], [P4-T14], [P8-T9], [P8-T13]. AC-11 is deferred even though its local checks ([P3-T6]..[P3-T9], [P8-T6], [P8-T7]) pass, because [P4-T13] lists it. The adjustment is also recorded in `evidence/other/execution-deviations.2026-10-10T08-02.md`.

## AC mapping

| AC | Implementing tasks | Evidence artifacts | Status |
| --- | --- | --- | --- |
| AC-1 | P1-T1, P2-T1 | `evidence/regression-testing/fail-before.2026-10-10T08-16.md` (10 failed); `evidence/regression-testing/pass-after-guard-fix.2026-10-10T08-21.md` (9 passed) | PASS |
| AC-2 | P1-T2, P2-T2 | `evidence/regression-testing/fail-before.2026-10-10T08-16.md`; `evidence/regression-testing/pass-after-guard-fix.2026-10-10T08-21.md` | PASS |
| AC-3 | P1-T3, P2-T1 | `evidence/regression-testing/fail-before.2026-10-10T08-16.md`; `evidence/regression-testing/pass-after-guard-fix.2026-10-10T08-21.md` | PASS |
| AC-4 | P2-T1, P2-T2 | `evidence/regression-testing/pre-existing-unchanged.2026-10-10T08-17.md` (26 passed, 10 deselected); `evidence/other/guard-change-scope.2026-10-10T08-22.md` (3+/3-, 486 lines); `evidence/qa-gates/python-pytest-coverage.2026-10-10T08-39.md` (181 passed); `evidence/qa-gates/file-sizes.2026-10-10T08-45.md` | PASS |
| AC-5 | P5-T1, P5-T2, P5-T3 | `evidence/regression-testing/pass-after-skill-port.2026-10-10T08-34.md` (17 passed) | PASS |
| AC-6 | P1-T4, P1-T5, P2-T1, P5-T1..P5-T3 | `evidence/regression-testing/pass-after-guard-fix.2026-10-10T08-21.md`; `evidence/regression-testing/pass-after-skill-port.2026-10-10T08-34.md` | PASS |
| AC-7 | P5-T1..P5-T3 | `evidence/regression-testing/pass-after-skill-port.2026-10-10T08-34.md` (seam test passes); `evidence/other/disposition-token-scan.2026-10-10T08-35.md` (exit 1, no output) | PASS |
| AC-8 | P3-T1, P3-T2, P4-T6 | `evidence/other/bats-unit-local.2026-10-10T08-27.md` (`CI-DEFERRED-ACS: AC-8, AC-9`); `evidence/qa-gates/bash-bats-local.2026-10-10T08-41.md` | PENDING-CI |
| AC-9 | P3-T1, P3-T2, P4-T6 | `evidence/other/bats-unit-local.2026-10-10T08-27.md` (`CI-DEFERRED-ACS: AC-8, AC-9`); `evidence/qa-gates/bash-bats-local.2026-10-10T08-41.md` | PENDING-CI |
| AC-10 | P4-T1..P4-T5, P4-T7 | `evidence/other/bats-parity-local.2026-10-10T08-27.md` (`CI-DEFERRED-ACS: AC-10`); `evidence/other/python-parity-lane.2026-10-10T08-22.md` (18 passed, Python lane) | PENDING-CI |
| AC-11 | P3-T1..P3-T5, P4-T9 | `evidence/other/bats-payload-membership-local.2026-10-10T08-27.md` (`CI-DEFERRED-ACS: AC-11, AC-12`); local checks passed: `evidence/other/bash-mirror-identity.2026-10-10T08-18.md`, `evidence/other/bash-structure.2026-10-10T08-18.md`, `evidence/other/bash-line-counts.2026-10-10T08-18.md`, `evidence/qa-gates/bash-shfmt.2026-10-10T08-40.md`, `evidence/qa-gates/bash-shellcheck.2026-10-10T08-40.md` | PENDING-CI |
| AC-12 | P3-T4, P4-T8 | `evidence/other/bats-payload-membership-local.2026-10-10T08-27.md` (`CI-DEFERRED-ACS: AC-11, AC-12`) | PENDING-CI |
| AC-13 | P4-T10 | `evidence/other/pester-trigger-scoping.2026-10-10T08-30.md` (`CI-DEFERRED-ACS: AC-13`); `evidence/qa-gates/powershell-pester.2026-10-10T08-44.md` (`CI-DEFERRED-ACS: AC-13`) | PENDING-CI |
| AC-14 | P3-T5, P5-T1..P5-T4 | `evidence/regression-testing/pass-after-skill-port.2026-10-10T08-34.md` | PASS |
| AC-15 | P6-T1, P6-T2 | `evidence/other/permission-surface-present.2026-10-10T08-41.md`; `evidence/other/permission-surface-absent.2026-10-10T08-41.md`; `evidence/other/permission-surface-tests.2026-10-10T08-42.md` (40 passed) | PASS |
| AC-16 | P6-T3, P6-T4, P6-T5 | `evidence/other/permission-surface-present.2026-10-10T08-41.md`; `evidence/other/permission-surface-absent.2026-10-10T08-41.md`; `evidence/other/permission-surface-tests.2026-10-10T08-42.md` | PASS |
| AC-17 | P2-T1, P2-T2, P4-T4 | `evidence/qa-gates/python-black.2026-10-10T08-39.md`; `evidence/qa-gates/python-ruff.2026-10-10T08-39.md`; `evidence/qa-gates/python-pyright.2026-10-10T08-39.md`; `evidence/qa-gates/python-pytest-coverage.2026-10-10T08-39.md` (line 96.45%, branch 95.00%); `evidence/qa-gates/python-coverage-comparison.2026-10-10T08-39.md` | PASS |
| AC-18 | P3-T1, P3-T2, P4-T6..P4-T9 | `evidence/qa-gates/bash-coverage-ci-pending.2026-10-10T08-41.md` (CI-only kcov gate) | PENDING-CI |
| AC-19 | P1-T1..P1-T5, P4-T4, P4-T6..P4-T10 | `evidence/qa-gates/test-hygiene.2026-10-10T08-45.md` (exit 1, no output) | PASS |
| AC-20 | P7-T1 | `follow-ups.md` | PASS |
| AC-21 | P5-T7 | `evidence/other/hook-precedence-verification.2026-10-10T08-36.md` (committed in 3e6a2545f, before the Phase 6 permission edits in e0e8dee1a) | PASS |

## Plan-time deviations (from "Plan-Time Deviations and Recorded Facts")

1. `quality-tiers.yml` exists at the repository root and classifies `.claude/lib/bash` as T3 (lines 34-36); spec D6 states the file does not exist, but its T3 conclusion is unchanged and no edit to `quality-tiers.yml` was required.
2. `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` excludes `.claude/lib/bash/*` from its scan; the AC-11 "no Python invocation" condition is verified by the [P3-T7] grep.
3. The optional edit to `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` was not taken; no TypeScript file was written, so no TypeScript toolchain loop was in scope.
4. The `--at` default is tested by format assertion only (spec NFR-4); the optional `date` shim fixture was not created.
5. kcov has no local route; the bash coverage gate (AC-18) runs only in CI and AC-18 is left unchecked as PENDING-CI.
6. The plan validator was unavailable to the planner session; the orchestrator ran it against the round-0 text (pass) and the revised text required re-validation before approval.
7. Spec AC-21 and FR-9 were added after revision round 3; the hook-over-allow precedence was re-recorded as execution evidence by [P5-T7] before [P6-T1] and [P6-T3]. The hook search used the single-line literal `'deny'` because of alignment padding at `.claude/hooks/enforce-parallel-abandon-gate.ps1` line 273.
