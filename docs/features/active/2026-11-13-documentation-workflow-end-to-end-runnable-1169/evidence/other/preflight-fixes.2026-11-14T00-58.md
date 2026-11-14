# Preflight Fixes - Remediation Cycle 1 Plan, Issue 1169

Timestamp: 2026-11-14T00-58
Plan: docs/features/active/2026-11-13-documentation-workflow-end-to-end-runnable-1169/remediation-plan.2026-11-14T00-21.md
Pre-fix snapshot: SCRATCH/issue-1169-plan-snapshot.md
Validators after the fixes: MCP plan validator ok; branch-current Python CLI `plan` exit 0.

## Fixes (task text only; no task added, removed, or reordered)

1. [P1-T1] | expect-fail claim not observed on unmodified code | A SCRATCH probe of `Get-OrchestrationDocsEstateSegmentShape` on the current head returned `commit` for `git commit --file=a.txt --trailer=Refs:1169` and threw only for single `=`-form options. The acceptance now names the nine rows expected to fail (the `--file=`, `--message=`, `--trailer=`, and `-C` `--file=` allow rows in each suite, plus the Claude direct-call row) and states that the two-option row passes before the fix. The `ExpectedExitCode` value is now the exit code the fail-before run is expected to produce (the failed-row count, 9, under `Run.Exit`) instead of a fixed `1`. The fail-before intent and every post-fix assertion are unchanged.
2. [P3-T2] | duplicated row instruction | The moved `hook-docs-estate-context.Tests.ps1` rows for `estate/docs-coverage-ledger.json` and `guide/start.md` were also listed as rows to add. The text now states that the moved rows are those reject rows, so no duplicate row is added.
3. [P3-T3] | acceptance contradicts tree state | The six `documentation-workflow/SKILL.md` copies are three surface-specific byte-identical pairs (`.claude` with `claude-customizations`, `.agents` with `codex-and-agents-customizations`, `.github` with `customizations`), so six equal SHA-256 values cannot occur. The acceptance now requires the edited sentence to be identical in all six copies and each copy to match its bundle mirror. The parity meaning is unchanged.
4. [P3-T4] | placement that would make the hygiene step inert | `codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1` dot-sources the gate inside its `Describe`-level `BeforeAll`; a file-level `AfterAll` would not reach those functions. The task now places that suite's `AfterAll` in the same `Describe` block.
5. [Pre-Mortem, Mirror parity] | incorrect parity fact | The bullet stated that the six skill copies are byte-copied; it now states the three-pair structure and per-pair hash check.
6. [Pre-Mortem, File size] | incorrect size range | The bullet stated that all edited suites are between 135 and 280 lines; the P2-T1 suites reach 543 lines and only lose lines, which the bullet now states.
