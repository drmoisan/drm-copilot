# Remediation Inputs — Issue #929

- Timestamp: 2026-10-16T05-25
- Issue: #929
- Branch: bug/subagentstop-artifact-gates-review-notes-929
- Head at review: af34e23e4ccc91ce2c3f8e95324958a1eb2d41c8
- Feature folder: docs/features/active/subagentstop-artifact-gates-review-notes-929
- Work mode: full-bug
- Source review set:
  - docs/features/active/subagentstop-artifact-gates-review-notes-929/policy-audit.2026-10-16T05-25.md
  - docs/features/active/subagentstop-artifact-gates-review-notes-929/code-review.2026-10-16T05-25.md
  - docs/features/active/subagentstop-artifact-gates-review-notes-929/feature-audit.2026-10-16T05-25.md

Review-Verdict: REMEDIATION_REQUIRED

## Blocking findings

### F1 (PA-1 / CR-2 / FA-1): repo-wide PowerShell coverage not evidenced

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: A full self-hosted PoshQC test run is a local command available to the executor; it needs no external service, CI result, or operator decision.
- Related: yes (evidence gap of this item; PowerShell is the only changed language)
- Location: `artifacts/pester/powershell-coverage.xml` report-level `LINE` counter; `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/qa-gates/final-pester-selfhosted.2026-10-16T05-12.md` (command used `-ScanFolders @('tests/scripts/claude-hooks','tests/scripts/claude-runtime')`).
- Problem: the only PowerShell coverage artifact is from a scoped run. It reports `LINE missed="9492" covered="8623"` (47.60%) across the 203 files in the roots of `config/poshqc-coverage.json`; packages outside the scoped test folders report 0% (for example `scripts/dev-tools` 0/1745, `.claude/lib/blast-radius` 0/845). No artifact records a full-suite repo-wide figure, so the 85% repo-wide line threshold is not demonstrated.
- Required fix: run `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root <worktree root>` without `-ScanFolders` (the command the CI `PowerShell QC` job runs, `.github/workflows/_poshqc.yml:42`). Record in a new `evidence/qa-gates/coverage-repo-wide.<timestamp>.md`: the command, exit code, the pass/fail summary line, the report-level `<counter type="LINE" ... />` element verbatim from `artifacts/pester/powershell-coverage.xml`, the computed percentage, and the per-file `LINE` counter for `.claude/hooks/validate-task-researcher-output.ps1` (must still be `missed="2"`). If the repo-wide figure is below 85%, record whether `origin/main` (merge base `5bc97774b`) is also below 85% so the reviewer can classify the shortfall as pre-existing.
- No production or test file change is expected.

## Non-blocking findings to resolve in this item

### F2 (CR-1 / PA-4 / FA-2): NB-11 case does not use the shared envelope helper

- Severity: Minor (non-blocking)
- Remediability: autonomous
- Remediability-Evidence: A two-line edit in one test file that this item created; verifiable with the existing suite.
- Related: yes (same file and same feature; introduced by this item, contrary to the NB-4 intent of one shared builder)
- Location: `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` lines 329-336 (Describe `Invoke-TaskResearcherOutputValidation dependency decision in process (issue #929)`; `BeforeAll` at lines 330-332; literal at line 336).
- Problem: `$inputText` is a hand-written JSON literal, `'{"session_id":"e3-905","hook_event_name":"SubagentStop","agent_type":"task-researcher","stop_hook_active":false,"last_assistant_message":"Done. Findings recorded."}'`, so this suite builds envelopes two ways. AC-09 does not detect it because it searches only for the old builder name.
- Required fix: add `. (Join-Path $PSScriptRoot 'SubagentStopEnvelope.Helpers.ps1')` to the Describe's `BeforeAll` after the hook dot-source, and replace line 336 with `$inputText = ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher' -AssistantMessage 'Done. Findings recorded.'`. The produced JSON text is identical (same key order and values). Re-run format, analyze, and the suite; confirm the file stays at or below 500 lines and the AC-08 fragment count for this file becomes 2.

### F3 (PA-2): AC-26 pending CI

- Severity: Pending CI (non-blocking)
- Remediability: awaiting_ci
- Remediability-Evidence: Requires the conclusion of workflow job `poshqc / PowerShell QC` on the PR head SHA; no PR exists yet.
- Related: yes
- Required action: none before PR creation; the item's orchestrator run checks off AC-26 at S9.

### F4 (PA-3): AC-27 pending CI

- Severity: Pending CI (non-blocking)
- Remediability: awaiting_ci
- Remediability-Evidence: Requires the conclusion of workflow job `poshqc / PowerShell hook suites (Linux)` on the PR head SHA; no PR exists yet.
- Related: yes
- Required action: none before PR creation; the item's orchestrator run checks off AC-27 at S9.

## No action

- CR-3 (Info): the new `validate-discovery-artifact-gate.Dispatch.Tests.ps1` and the pre-existing `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` have similar names but complementary purposes; the new file's header states the placement reason.

## Unrelated findings

- None. The `profile_cli.py` prefix match in `Get-DiscoveryArtifactType` is the existing out-of-scope E3 follow-up owned by `TODO(#9002)`.

## Scope for the remediation cycle

- May change: `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` (F2 only), new evidence under `docs/features/active/subagentstop-artifact-gates-review-notes-929/evidence/`, and the remediation plan.
- Must not change: any file under `.claude/`, `.codex/`, `extensions/`, `scripts/`, `.github/`; the R3 pattern; any validator message; `spec.md` checkbox states (AC-26 and AC-27 stay unchecked).

## Exit condition

Re-run feature review. Exit when the reaudit records 0 blocking findings, F1 evidence shows repo-wide PowerShell line coverage at or above 85% (or a recorded pre-existing shortfall that the reviewer classifies), and F2 is resolved with the PowerShell toolchain (format, analyze, suite run) clean in one pass.
