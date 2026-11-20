# Remediation Inputs — Issue 1118

Timestamp: 2026-11-07T23-18
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/policy-audit.2026-11-07T23-18.md`
- `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/code-review.2026-11-07T23-18.md`
- `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/feature-audit.2026-11-07T23-18.md`
Head: `84a25a90a17f38e31a90b7e81ce3461d91e96ddb`
Remediation plan target: `docs/features/active/2026-11-07-progress-report-orchestration-step-model-1118/remediation-plan.2026-11-07T23-18.md`

The path is full because RF1 changes the stage-name normalization rule stated in `spec.md`. The orchestrator classifies the cycle as proportionate: every finding is fixed within files already in the branch diff plus their tests and mirrors, and no acceptance criterion or public interface changes (the normalization paragraph is descriptive text, not a criterion).

## Findings requiring remediation

### RF1 — Live stage and step vocabulary maps to no type

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The names to map are recorded in committed stage-timing evidence and live checkpoints in this repository, and the issue already names stage_timing and completed_steps as data sources; no owner decision, external system, or CI result is needed.
Finding-Scope: design

- Files: `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Stages.ps1` (`ConvertTo-EpicProgressStepType`), `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Steps.ps1` (`$fallback` in `Get-EpicProgressItemStep`, the `pr` record lookup in `Get-EpicProgressCycleStep`), `spec.md` `### Step types` normalization paragraph, `SKILL.md`, the bundle copies, and the Stages and Steps tests.
- Problem: `feature_review`, `atomic_execution`, `S2_research`, `S3_spec`, `S4_atomic_planning`, `S4_preflight`, `S5_atomic_execution`, `S7_feature_review`, `S8_create_pr`, `S9_ci_gate`, and `S9_ci_green` map to `unmapped`. `completed_steps` records `S3b_research`, which the `S2_research` fallback does not match. On the live epic the open #1038 review shows `0 h 00 min` elapsed, the estimate does not fall between runs, and a phantom research step remains.
- Required change: add an alias mapping from each observed name to its step type (research, spec, plan, preflight, execution, review, pr, ci), keep `promotion` and other unknown names unmapped, and accept the `S3b_research` form in the research fallback. Amend the spec normalization paragraph and SKILL.md to list the aliases. Add tests with the live names, including a two-run test with an open `feature_review` stage whose estimate falls.
- Verification required: probe results for each alias; the AC5 behavior with `feature_review`; one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run with zero failures; bundle copies identical; re-review.

### RF2 — In-progress execution elapsed is measured from the stage start

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect and the correct start time (the plan tick anchor already held in the state) are both inside the skill; the fix needs no decision or external input.
Finding-Scope: contained

- Files: `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Steps.ps1` (`$openExecution` block in `Get-EpicProgressItemStep`) and `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Gather.ps1` (`Get-EpicProgressStepReport`), their tests, and the bundle copies.
- Problem: the first unchecked task inherits the start of the whole open `execution` stage and is compared with the per-task median, so the Now line reads `over median` during the whole execution phase (`#1118 execution (1 h 20 min of median 0 h 03 min, over median)`), and the in-progress credit is always 0.
- Required change: start the in-progress execution step at the later of the stage start and the plan anchor's `LastTickUnixSeconds`; add a test with an open stage and a recent tick.
- Verification required: the new test; the gates as in RF1.

### RF3 — Item-mode and singular report wording

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The wording is produced by two render functions in the skill; the corrected phrasing follows from the item-mode subject rule in the spec and needs no owner input.
Finding-Scope: contained

- Files: `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` (`Get-EpicProgressTldrLine`, `Get-EpicProgressFullLine`), the Render and ItemMode goldens, the SKILL.md format examples if affected, and the bundle copies.
- Problem: `None of the 1 features is done yet.`, `1 of 1 features are done.`, `(1 blocked steps excluded)`; in item mode `points since the epic started`, `it is not the epic's cost alone`, the `Features` column header, and `(wave 1)`.
- Required change: in item mode, phrase the done sentence about the item, drop the wave label, and use `since the measurement started` and `not this item's cost alone`; use singular forms for a count of one in both modes; keep the TL;DR at four lines.
- Verification required: updated goldens for epic and item mode, including a one-feature epic and one blocked step; the gates as in RF1.

## Non-blocking items (no remediation required)

- A step in progress without a recorded start prints `0 h 00 min of median ...`; consider a distinct phrase.
- Plan anchors of merged items remain in the state file.
- Keep RF1 to RF3 changes out of the 495-line entry script.

## Constraints

- PowerShell only; no Python in the skill.
- Tests stay in memory with mocked seams; no temporary files.
- One `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate.
- CLI parameters and the version 2 state format stay unchanged.
