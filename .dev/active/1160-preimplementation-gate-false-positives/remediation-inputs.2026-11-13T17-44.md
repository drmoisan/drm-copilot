# Remediation Inputs — Issue 1160

Timestamp: 2026-11-13T17-44
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design
Head: `4767fe8a35e9a1b8f404ff827f009098b7ed9855`
Base: `main`, merge base `18520b3fce8b6273ac63a16fef03816f7119dcad`
Source review artifacts:
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/policy-audit.2026-11-13T17-44.md`
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/code-review.2026-11-13T17-44.md`
- `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/feature-audit.2026-11-13T17-44.md`
Remediation plan target: `docs/features/active/2026-11-09-preimplementation-gate-false-positives-1160/remediation-plan.2026-11-13T17-44.md`

Path note: the single finding is autonomous but changes the D2 stage-2 rule, which requires a recorded spec decision, edits to all four sibling copies, and new corpus rows on both surfaces, so it is a design-scope fix and takes the full path.

## Findings requiring remediation

### F1 — Stage 2 declassifies a mention host piped into an executing consumer

Severity: Blocking
Relation: related to issue #1160 (introduced by this branch's stage-2 rule)
Remediability: autonomous
Remediability-Evidence: The fix is a rule change inside the item's own sibling file and its tests, recorded as a spec decision in the same manner as D14 and D15; it needs no external system, CI result, or owner decision.
Finding-Scope: design

- Location: `Test-OrchestrationGateInvocationConfirmed` in `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, and both bundle copies under `extensions/drm-copilot/resources/`; the per-record loop skips any record that does not carry the governed word (`if (-not $carries[$position]) { continue }`), and the wrapper clause runs only for a carrying wrapper record.
- Observed: these commands are classified by the merge-base gate and unclassified at head, identically on both surfaces (reviewer probes of `Test-ImplementationCommand`):
  - `pwsh -NoProfile -Command "Get-ChildItem tests/scripts/run.ps1 | ForEach-Object { & $_.FullName }"`
  - `pwsh -NoProfile -Command "Get-ChildItem tests/scripts/ -Filter *.Tests.ps1 | ForEach-Object { & $_ }"`
  - `pwsh -NoProfile -Command "Get-ChildItem tests/scripts/run.ps1 | % { & $_ }"`
  - `pwsh -NoProfile -Command "Get-Command pytest | ForEach-Object { & $_ }"`
  - `pwsh -NoProfile -Command "Get-Command pytest | ForEach-Object { & $_.Source -q }"`
  - `pwsh -NoProfile -Command "Get-Command Invoke-Pester | ForEach-Object { & $_ }"`
  - `echo pytest | xargs env`
  Each executes the governed tool or a script under `tests/scripts/`. The issue requires classifying only real invocations, and D2 marks `ForEach-Object` as not a host because it can execute its arguments.
- Required change: record decision D16 in `spec.md` (amending the D2 stage-2 rule) and implement it in all four byte-identical sibling copies: confirm a stage-1 hit when a record that follows a carrying record in the same pipeline, at the same depth, is not itself a mention host (or, at minimum, is a `NotHost` entry, `%`, `foreach`, an evaluator, a call-operator expression, or an `xargs` or `env` wrapper). Keep the FP rows allowed: in FP-01, FP-02, FP-16, and FP-17 the carrying record is the last stage of its pipeline. Optionally fold in code review N1 (`sort --compress-program` as an executing option) and N2 (state whether `NotHost` is read).
- Tests: add existing-denial rows for the seven forms to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1` (both runners), with the generic deny text; add named cases to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-commands.Tests.ps1`; confirm each new row fails on the current head before the fix (expect-fail evidence under `evidence/regression-testing/`).
- Verification required: task checks per the cadence; one `Invoke-PoshQCParallelTest` final gate with 0 failures, compared with the Phase 0 baseline (95.80% repo-wide lines); sibling coverage at least 90% on both surfaces; four-copy parity suites; FP, ED, and NG rows on both surfaces; push-down contract tests and generator check if bundle copies change. Then re-review.

## Non-blocking items (no remediation required in this PR)

- N1: `sort --compress-program` executes its operand; optional executing-option entry.
- N2: `NotHost` is not read by the decision logic; optional clarification.
- N3: `git -C . log --grep pytest` stays classified; conservative, no change.
- N4: AC-22 evidence lies under `evidence/qa-gates/` by the canonical-location override; no change.
- AC-24 is pending CI and is not a finding.
- No finding unrelated to issue #1160 was identified.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest` run per gate, re-run only after a fix. No serial, single-process, shuffled, or reversed gate runs.
- Evidence is append-only; no artifact records an absolute path.
- No Python in the hook path; no edit to the shared `hook-command-` matcher files, the helpers, targets, cleanup, epic-scope, or modes siblings, `hook-epic-fan-in.ps1`, or hook registrations.
- Existing gate suites stay unmodified (AC-9, AC-17); `$script:SharedGateFunction` stays unchanged (AC-14).
