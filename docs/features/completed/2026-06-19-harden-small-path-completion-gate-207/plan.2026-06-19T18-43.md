# harden-small-path-completion-gate — Minimal-Audit Plan

- **Issue:** #207
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-19T18-43
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** minor-audit
- **Plan Type:** DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED

## Requirements Source

- Sole requirements source: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/issue.md`
- Acceptance Criteria source: the `## Acceptance Criteria` section of that `issue.md` (only that section is the minor-audit AC source).
- This plan does not require `spec.md`, `user-story.md`, or `research.md`.

## Objective

Add a `PreToolUse` completion-consistency gate for the orchestrator checkpoint at
`artifacts/orchestration/orchestrator-state.json`. The new PowerShell hook
`.claude/hooks/enforce-completion-consistency.ps1` blocks Write operations whose checkpoint
asserts completion unless the checkpoint carries verifiable completion evidence (non-empty
`issue-num`, non-empty `feature-folder`, and a populated `ci_gate` with `conclusion == "success"`
and a non-empty `head_sha`). The hook mirrors the structure and decision contract of
`.claude/hooks/enforce-checkpoint-monotonic.ps1` and is registered in `.claude/settings.json`
under the existing `PreToolUse` `Write|Edit` matcher block. Pester tests cover the block path,
the allow-on-evidence path, and the backward-compatible non-assertion path.

## In-Scope Languages

- PowerShell only. Toolchain: PoshQC format -> PSScriptAnalyzer analyze -> Pester test
  (no type-check step for PowerShell). Coverage policy applies (line >= 85%, branch >= 75%).

## Evidence Location Invariant

All evidence artifacts MUST be written under
`docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/<kind>/`.
Any non-canonical path supplied by a caller is rejected and replaced with the canonical path,
recorded as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied> replaced with <canonical>`.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read policy files in required order and record a Phase 0 instructions-read evidence artifact.
  - Read in this order: `CLAUDE.md`, `.claude/rules/general-code-change.md`,
    `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/baseline/phase0-instructions-read.md`
    exists and contains `Timestamp:`, `Policy Order:`, and an explicit list of the four files read.

- [x] [P0-T2] Confirm minor-audit document expectations against the active feature folder.
  - Verify `issue.md` contains an explicit `## Acceptance Criteria` section; verify `spec.md` and
    `user-story.md` are absent from the active folder.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/baseline/phase0-doc-scope.md`
    exists and records `Timestamp:`, the presence of `## Acceptance Criteria` in `issue.md`, and the
    absence of `spec.md` and `user-story.md`. Fail closed if `## Acceptance Criteria` is missing or if
    `spec.md`/`user-story.md` unexpectedly exists.

- [x] [P0-T3] Capture baseline PoshQC format state for in-scope PowerShell paths.
  - Command: `mcp__drm-copilot__run_poshqc_format` over `.claude/hooks/` and `tests/scripts/claude-hooks/`.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/baseline/baseline-poshqc-format.md`
    exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and files changed count).

- [x] [P0-T4] Capture baseline PSScriptAnalyzer state for in-scope PowerShell paths.
  - Command: `mcp__drm-copilot__run_poshqc_analyze` over `.claude/hooks/` and `tests/scripts/claude-hooks/`.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/baseline/baseline-poshqc-analyze.md`
    exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (analyzer finding counts by severity).

- [x] [P0-T5] Capture baseline Pester run with coverage for the claude-hooks test tree.
  - Command: `mcp__drm-copilot__run_poshqc_test` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` scoped to `tests/scripts/claude-hooks/`.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/baseline/baseline-pester.md`
    exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric headline values:
    tests passed/failed counts and baseline line and branch coverage percentages.

---

### Phase 1 — Constrained Small-Path Implementation

- [x] [P1-T1] Create the completion-consistency hook file `.claude/hooks/enforce-completion-consistency.ps1`.
  - Mirror `.claude/hooks/enforce-checkpoint-monotonic.ps1`: comment-based help header, `[CmdletBinding()] param()`,
    a mockable JSON-parse seam function `ConvertFrom-CheckpointJson`, a `Test-IsCheckpointPath` matcher reusing the
    pattern `(^|/)artifacts/orchestration/orchestrator-state\.json$`, a dot-source guard
    `if ($MyInvocation.InvocationName -eq '.') { return }`, and an entrypoint that reads `$env:CLAUDE_TOOL_INPUT`,
    calls the decision function, emits the decision JSON via `ConvertTo-Json -Compress | Write-Output`, and exits 0
    (exit 1 only on thrown error via `Write-Error`).
  - Acceptance: file exists; dot-sourcing the file in a PowerShell session defines `Invoke-CompletionConsistencyDecision`
    without executing the entrypoint; the file is under 500 lines.

- [x] [P1-T2] Implement `Invoke-CompletionConsistencyDecision -ToolInputRaw <string>` as the pure decision function.
  - Returns an `[ordered]` hashtable with `decision` (`allow` or `block`) and, when blocking, a specific `reason`.
  - Behavior: allow when `$ToolInputRaw` is empty, when `file_path` is missing, when the normalized path is not the
    checkpoint, and when the tool call is an Edit (only `old_string`/`new_string`, no `content`). For Write calls, parse
    `content` via `ConvertFrom-CheckpointJson`; allow when content is not valid JSON (defer to downstream tools).
  - Completion assertion is true when `next_step == "complete"` OR `completed_steps` contains `S12_complete` OR any of
    `step8_status`/`step9_status`/`step10_status` equals `completed`.
  - When completion is NOT asserted, return `decision = allow`.
  - When completion IS asserted, block unless ALL evidence is present: top-level `issue-num` non-empty string
    (accept `variables.issue-num` as fallback), top-level `feature-folder` non-empty string (accept
    `variables.feature-folder` as fallback), and `ci_gate` is an object with `conclusion == "success"` and a non-empty
    `head_sha`. Block reason uses a specific prefix (for example `COMPLETION_CONSISTENCY_BLOCKED:`) naming the missing
    evidence.
  - Acceptance: dot-sourcing the hook and calling `Invoke-CompletionConsistencyDecision` returns the documented
    decisions for representative allow and block inputs; the throw path on malformed top-level JSON propagates so the
    entrypoint exits 1.

- [x] [P1-T3] Register the hook in `.claude/settings.json` under the existing `PreToolUse` `Write|Edit` matcher block.
  - Add a command entry `pwsh -NoProfile -File .claude/hooks/enforce-completion-consistency.ps1` adjacent to the
    existing `enforce-checkpoint-monotonic.ps1` entry, preserving valid JSON.
  - Acceptance: `.claude/settings.json` parses as valid JSON and contains the new hook command string inside the
    `Write|Edit` matcher `hooks` array alongside `enforce-checkpoint-monotonic.ps1`.

- [x] [P1-T4] Create the Pester test file `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`.
  - Mirror `tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1`: `#Requires -Version 7.0`,
    `#Requires -Modules Pester 5.0.0`, a `BeforeAll` that resolves the hook path relative to `$PSScriptRoot` and
    dot-sources it, and `Describe`/`Context`/`It` structure. Mock the `ConvertFrom-CheckpointJson` / JSON-parse seam
    where needed; use no temporary files.
  - Acceptance: file exists, dot-sources the hook under test, and is under 500 lines.

- [x] [P1-T5] Add test scenario: non-checkpoint path is allowed.
  - `It` asserts `Invoke-CompletionConsistencyDecision` returns `allow` for a `file_path` other than the checkpoint.
  - Acceptance: the `It` block exists and asserts `decision -eq 'allow'`.

- [x] [P1-T6] Add test scenario: Edit tool call (only `old_string`/`new_string`, checkpoint path) is allowed.
  - Acceptance: the `It` block exists and asserts `decision -eq 'allow'` for an Edit-style payload on the checkpoint path.

- [x] [P1-T7] Add test scenario: checkpoint NOT asserting completion is allowed.
  - Payload on checkpoint path with `next_step != "complete"`, no `S12_complete`, and step8/9/10 not `completed`.
  - Acceptance: the `It` block exists and asserts `decision -eq 'allow'`.

- [x] [P1-T8] Add test scenario: completion asserted with full evidence is allowed.
  - Payload asserts completion and supplies non-empty `issue-num`, non-empty `feature-folder`, and
    `ci_gate` with `conclusion == "success"` and non-empty `head_sha`.
  - Acceptance: the `It` block exists and asserts `decision -eq 'allow'`.

- [x] [P1-T9] Add test scenario: completion asserted with missing `ci_gate` is blocked.
  - Acceptance: the `It` block exists and asserts `decision -eq 'block'` and `reason` matches the block prefix and references `ci_gate`.

- [x] [P1-T10] Add test scenario: completion asserted with success `ci_gate` but empty `issue-num` is blocked.
  - Acceptance: the `It` block exists and asserts `decision -eq 'block'` and `reason` references `issue-num`.

- [x] [P1-T11] Add test scenario: completion asserted with empty `feature-folder` is blocked.
  - Acceptance: the `It` block exists and asserts `decision -eq 'block'` and `reason` references `feature-folder`.

- [x] [P1-T12] Add test scenario: completion asserted with `ci_gate.conclusion != "success"` is blocked.
  - Acceptance: the `It` block exists and asserts `decision -eq 'block'` and `reason` references `ci_gate` / `conclusion`.

---

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run PoshQC format on the changed PowerShell files and record evidence.
  - Command: `mcp__drm-copilot__run_poshqc_format` over `.claude/hooks/enforce-completion-consistency.ps1` and
    `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/final-poshqc-format.md`
    exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If files change, restart the loop from P2-T1.

- [x] [P2-T2] Run PSScriptAnalyzer on the changed PowerShell files and record evidence.
  - Command: `mcp__drm-copilot__run_poshqc_analyze` over the two changed files.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/final-poshqc-analyze.md`
    exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (0 errors required). If findings require fixes,
    apply them and restart from P2-T1.

- [x] [P2-T3] Run Pester with coverage and record post-change numeric coverage evidence.
  - Command: `mcp__drm-copilot__run_poshqc_test` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
    scoped to `tests/scripts/claude-hooks/`.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/final-pester.md`
    exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` containing numeric post-change line and
    branch coverage percentages and pass/fail counts; all eight new scenarios pass. If any test fails, fix and restart from P2-T1.

- [x] [P2-T4] Verify coverage delta and thresholds for the changed code.
  - Compare baseline (P0-T5) line/branch coverage against post-change (P2-T3); confirm no regression on changed lines,
    line coverage >= 85%, branch coverage >= 75%.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/coverage-delta.md`
    exists recording baseline coverage, post-change coverage, and new/changed-code coverage with a PASS/FAIL verdict
    against the thresholds. If thresholds are not met, the outcome is remediation-required, not PASS.

- [x] [P2-T5] Confirm all changed files are under the 500-line limit.
  - Files: `.claude/hooks/enforce-completion-consistency.ps1`,
    `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/file-size-check.md`
    exists recording `Timestamp:` and each file's line count, each below 500.

---

## Reduced Audit Block (Small Path)

- [x] [P2-T6] Post-implementation minor-audit handoff: verify each `## Acceptance Criteria` item in `issue.md` against the
  recorded evidence artifacts (baseline + final QC). Record the reduced-audit result.
  - Acceptance: `docs/features/active/2026-06-19-harden-small-path-completion-gate-207/evidence/qa-gates/minor-audit.md`
    exists mapping each AC item to a concrete evidence artifact path, with a PASS/PARTIAL/BLOCKED verdict and, for any
    non-PASS, the violated rule and corrective action.

## Notes

- Fail-closed evidence rule: if any required baseline, final-QC, or coverage artifact is missing or incomplete, the audit
  verdict is BLOCKED or INCOMPLETE, never PASS.
- Plan-path continuity: this file is the single canonical plan file for this feature; preflight revisions update this file in place.
