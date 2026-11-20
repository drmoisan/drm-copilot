# Remediation Inputs — Issue 1118, cycle 2

Timestamp: 2026-11-08T00-16
Review-Verdict: PASS
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/policy-audit.2026-11-08T00-12.md`
- `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/code-review.2026-11-08T00-12.md`
- `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/feature-audit.2026-11-08T00-12.md`
Head: `b82381ed282445648ee6a9e95f106778999e9f85`
Remediation plan target: `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/remediation-plan.2026-11-08T00-16.md`

The re-audit passed. The orchestrator opens this cycle for the three related non-blocking items the re-audit recorded, so that they are closed inside the item rather than filed as follow-up issues. The cycle is proportionate: each item is fixed within files already in the branch diff plus their tests and bundle mirrors, and no acceptance criterion, CLI parameter, or version 2 state field changes.

## Findings

### NB1 — A step without a recorded start prints a measured-looking elapsed time

Remediability: autonomous
Finding-Scope: contained

- Files: `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` (`Get-EpicProgressTldrLine` Now line), its tests, and the bundle copy.
- Problem: an in-progress step with a null `StartedUnixSeconds` (every step of a remediation cycle, the epic `integration-pr` step, the first observation of a partly ticked plan) prints `0 h 00 min of median <m>`, which reads as a measured value.
- Required change: when the step has no recorded start, print `<type> (start not recorded; median <m>)` instead of an elapsed figure. Keep the TL;DR at four lines. Update SKILL.md if it shows the Now-line format.
- Verification: a Render test for a step with no start; the existing Now-line goldens for steps with a start unchanged.

### NB3 — `S2_feature_documents` stage name is unmapped

Remediability: autonomous
Finding-Scope: contained

- Files: `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Stages.ps1` (`ConvertTo-EpicProgressStepType` alias table), its tests, the spec normalization paragraph and SKILL.md alias list, and the bundle copies.
- Required change: map `S2_feature_documents` to `spec`.
- Verification: the alias test covers the new name.

### NB4 — Plan anchors of merged items stay in the state file

Remediability: autonomous
Finding-Scope: contained

- Files: `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` (`Get-EpicProgressStepReport` item anchor retention), its tests, and the bundle copy.
- Required change: drop the `items` entry of an item whose `merge` step is done, so the state file does not grow with merged items. The `durations` ledger is unaffected.
- Verification: a Gather test showing a merged item's anchor removed and an unmerged item's anchor kept.

## Constraints

- PowerShell only; tests in memory with mocked seams; no temporary files.
- Keep the 495-line entry script unchanged; every file under 500 lines.
- One `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run as final gates, compared with the Phase 0 baseline artifacts.
