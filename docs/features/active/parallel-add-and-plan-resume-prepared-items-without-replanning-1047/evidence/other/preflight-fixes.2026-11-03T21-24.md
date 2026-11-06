# Preflight Fixes (remediation cycle 2)

Timestamp: 2026-11-03T21-24
Plan: docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/remediation-plan.2026-11-03T21-16.md

Single-pass review of every phase, task, and prose region. Branch-current plan validator (`scripts.dev_tools.validate_orchestration_artifacts plan`) exit 0 before and after the fix.

## Fixes

1. [P1-T2] | literal-formatting / clarity (trivial) | The three new rows listed their `Arguments` and messages but not the `Name` and `Value` keys that the renamed It title `exits 2 on <Subcommand> <Name> <Value>` renders. Added the clause "each carrying the `Name` and `Value` keys that the It title renders (`-Branch`, `-Main`, `-Ref` with the option value below)". The asserted messages, rows, and test count are unchanged.

## Citations re-checked (no defect)

- `Get-ParallelAdmissionUsageError` and `$script:AdmissionRequiredOption` in `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`; the empty-`-Main` default in `Invoke-ParallelAdmissionCli`.
- Describe `Usage errors`, its `BeforeEach` mocks, and It `exits 2 on reuse-edges <Name> <Value>` in `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1` (692 logical lines; script 621).
- No test passes a `-Branch`, `-Main`, or `-Ref` value beginning with `-`.
- `## Implementation Strategy` first implementation-scope bullet in `spec.md`; `## Acceptance Criteria` is a separate section.
- `## Contract Test Set` in `remediation-plan.2026-11-03T18-43.md`; the three templates under `docs/features/templates/policy_audit/`.
- Greatest `mirror-hashes.*.md` (2026-11-03T20-31) carries the canonical hash; greatest `pester-coverage.*.md` (2026-11-03T20-57) carries 96.44%.
