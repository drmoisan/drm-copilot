# 2026-06-27-harden-claude-pretooluse-hook-schema — Atomic Implementation Plan

- **Issue:** #259
- **Parent:** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-28T00-00
- **Status:** Approved-pending-preflight
- **Version:** 1.0
- **Work Mode:** full-feature

## Authoritative Status Note

This plan is the **authoritative** plan for issue #259. It supersedes the template placeholder
`plan.2026-06-27T20-46.md`, which is a scaffold only and MUST NOT be executed. All execution
references this file.

## Ground-Truth Sources

- `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/research/hook-surface-inventory.2026-06-27.md` — file-by-file inventory, decision-function names, line numbers, mirror locations, contract-test path, 14-batch phasing.
- `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/spec.md`
- `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/issue.md`
- `.claude/rules/powershell.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`

## Root-Cause Invariant (the contract this plan enforces)

At PreToolUse a hook denies ONLY when it writes to stdout:

```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<reason>"}}
```

The legacy top-level `{"decision":"block","reason":"..."}` form and `exit 1` are IGNORED at PreToolUse (fail-open). SubagentStop / PostToolUse / UserPromptSubmit hooks DO honor top-level `{"decision":"block"}` + `exit 1` and MUST NOT be changed.

## Per-Hook Mechanical Transformation (applies to every Part-1 batch unless noted)

For each PreToolUse hook (runtime under `.claude/hooks/` AND its byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`):

1. ALLOW shape: `[ordered]@{ decision = 'allow' }` → `[ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }`, preserving any sibling keys (`state`, `shouldWriteState`).
2. BLOCK shape: `[ordered]@{ decision = 'block'; reason = $Reason }` → `[ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $Reason } }`.
3. Final decision-gate comparison: `$decision.decision -eq 'block'` → `$decision.hookSpecificOutput.permissionDecision -eq 'deny'`.
4. JSON emission: use `ConvertTo-Json -Compress -Depth 5` (the envelope is nested). For hooks currently using plain `@{}`, also convert to `[ordered]@{}`.
5. Error-path `exit 1` (malformed-JSON hard failure) is RETAINED; only deny-path `exit 1` is removed.
6. Runtime edit and mirror edit are ALWAYS paired in the same batch to keep the byte-identical parity test green.

## Per-Batch Constraints (hard)

- PowerShell per-batch cap: at most 3 production `.ps1` and 3 test `.ps1`. A runtime hook + its bundled mirror = 2 separate production files.
- 500-line cap on every touched `.ps1`. Tightest headroom: `enforce-completion-consistency.ps1` (~80 lines).
- Each Part-1/4/5/6 phase ends with the PowerShell toolchain loop (`mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`) plus the relevant per-hook Pester run, then the bundle-parity pytest `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (any phase touching `.claude/**` runtime files).

---

### Phase 0 — Baseline Capture and Policy Reads

- [x] [P0-T1] Read policy files in required order and record the read in evidence.
  - Files: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`.
  - Acceptance: `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/evidence/baseline/phase0-instructions-read.2026-06-28T00-00.md` exists with `Timestamp:`, `Policy Order:`, and the explicit list of files read.

- [x] [P0-T2] Capture baseline PoshQC format state across the hook and test scope.
  - Command: `mcp__drm-copilot__run_poshqc_format` (check/report mode over `.claude/hooks` and `tests/scripts/claude-hooks`).
  - Acceptance: `evidence/baseline/poshqc-format-baseline.2026-06-28T00-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail and count of files needing format).

- [x] [P0-T3] Capture baseline PSScriptAnalyzer state across the hook and test scope.
  - Command: `mcp__drm-copilot__run_poshqc_analyze`.
  - Acceptance: `evidence/baseline/poshqc-analyze-baseline.2026-06-28T00-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (finding count).

- [x] [P0-T4] Capture baseline Pester state with coverage for the PowerShell hook suite.
  - Command: `mcp__drm-copilot__run_poshqc_test` (coverage-enabled, discovery roots `scripts`, `tests/powershell`, `tests/scripts`).
  - Acceptance: `evidence/baseline/pester-baseline.2026-06-28T00-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric line-coverage % and branch-coverage % headline values.

- [x] [P0-T5] Capture baseline bundle-parity pytest state.
  - Command: `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  - Acceptance: `evidence/baseline/bundle-parity-baseline.2026-06-28T00-00.md` exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Note: research records a pre-existing `validate-bash.ps1` mirror divergence (`-ErrorAction Stop`), so this baseline may already FAIL for that file; record the actual result.

- [x] [P0-T6] Record a grep baseline of legacy-shape usage across all 13 PreToolUse hooks (runtime + mirror).
  - Command: search `.claude/hooks` and the bundled mirror for `decision = 'block'`, `decision = 'allow'`, and `exit 1`.
  - Acceptance: `evidence/baseline/legacy-shape-grep-baseline.2026-06-28T00-00.md` lists every current legacy-shape and deny-path `exit 1` occurrence (the set to be eliminated by Part 1).

---

### Phase 1 — validate-bash.ps1 (Part 1; highest priority: currently emits nothing on deny)

- [x] [P1-T1] Restructure `.claude/hooks/validate-bash.ps1` into pure functions plus orchestrator.
  - Add pure `Get-BashBlockReason` (returns matched blocked pattern or `$null`) and `Get-BlockedPatternMatch` detector; add pure `Get-BashDenyDecision` returning the `[ordered]@{ hookSpecificOutput = ... permissionDecision = 'deny'; permissionDecisionReason = ... }` object; add `Invoke-ValidateBashDecision` orchestrator that reads `CLAUDE_TOOL_INPUT`/`CLAUDE_HOOK_INPUT`, calls the detector, returns allow or deny.
  - File: `.claude/hooks/validate-bash.ps1`.
  - Acceptance: On a blocked-pattern match the entrypoint emits the deny JSON via `ConvertTo-Json -Compress -Depth 5` and `exit 0`; no-match path `exit 0`; no deny-path `exit 1` remains; dot-sourcing guard `if ($MyInvocation.InvocationName -eq '.') { return }` present; file <= 500 lines.

- [x] [P1-T2] Replicate the Phase-1 runtime change byte-identically to the bundled mirror.
  - File: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`.
  - Acceptance: Mirror content is byte-identical to the runtime file (resolves the pre-existing `-ErrorAction Stop` divergence noted in research).

- [x] [P1-T3] Update `tests/scripts/claude-hooks/validate-bash.Tests.ps1` to assert the new shape.
  - Dot-source the hook; assert `Get-BashBlockReason` returns the matched pattern on a blocked command and `$null` otherwise; assert `Get-BashDenyDecision` output, after `ConvertTo-Json -Depth 5` then `ConvertFrom-Json`, has `hookSpecificOutput.hookEventName -eq 'PreToolUse'` and `hookSpecificOutput.permissionDecision -eq 'deny'`; assert no deny path uses `exit 1`. No disk/network/temp-file use.
  - Acceptance: Test asserts the `hookSpecificOutput`/`permissionDecision=deny` shape and passes.

- [x] [P1-T4] Run the Phase-1 verification loop.
  - Commands: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test` (validate-bash), then `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  - Acceptance: `evidence/qa-gates/phase1-qa.2026-06-28T00-00.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each command; PSScriptAnalyzer 0 findings on changed files; validate-bash Pester passes; parity pytest passes for validate-bash. Restart from format if any step changes files or fails.

---

### Phase 2 — enforce-promotion-mcp-only.ps1 (Part 1)

- [x] [P2-T1] Apply the schema transformation to `.claude/hooks/enforce-promotion-mcp-only.ps1`.
  - Replace the block literal in `Get-PromotionMcpOnlyBlockDecision` and the allow literals with the `hookSpecificOutput` envelope; update the final decision-gate comparison; change entrypoint emission to `ConvertTo-Json -Compress -Depth 5`; retain the error-path `exit 1`.
  - Acceptance: Hook emits deny via `hookSpecificOutput.permissionDecision='deny'`; allow via `permissionDecision='allow'`; no deny-path `exit 1`; file <= 500 lines.
- [x] [P2-T2] Replicate P2-T1 byte-identically to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P2-T3] Update `tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1` to assert the new deny/allow shape (serialize-then-parse on `Get-PromotionMcpOnlyBlockDecision`); no temp files.
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P2-T4] Run the Phase-2 verification loop (format → analyze → test for this hook, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase2-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 3 — enforce-pr-author-skill.ps1 (Part 1)

- [x] [P3-T1] Apply the schema transformation to `.claude/hooks/enforce-pr-author-skill.ps1`.
  - Replace block/allow literals in `Invoke-PrAuthorSkillDecision`; update the decision-gate comparison; entrypoint `ConvertTo-Json -Compress -Depth 5`; retain error-path `exit 1`; do not alter `Get-PrAuthorBypassReason` or the existing injectable seams.
  - Acceptance: deny/allow emitted in `hookSpecificOutput` shape; no deny-path `exit 1`; file <= 500 lines.
- [x] [P3-T2] Replicate P3-T1 byte-identically to the bundled mirror `.../enforce-pr-author-skill.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P3-T3] Update `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` to assert the new shape; mock the `Test-Path`/`Get-Content`/clock seams (no disk/network/temp files).
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P3-T4] Run the Phase-3 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase3-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 4 — enforce-orchestration-preimplementation-gate.ps1 (Part 1 + Part 5 confirmation)

- [x] [P4-T1] Apply the schema transformation to `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`.
  - Replace block/allow literals in `Invoke-OrchestrationPreimplementationGateDecision`; update the decision-gate comparison; entrypoint `ConvertTo-Json -Compress -Depth 5`; retain error-path `exit 1`.
  - Acceptance: deny/allow emitted in `hookSpecificOutput` shape; no deny-path `exit 1`; file <= 500 lines.
- [x] [P4-T2] Replicate P4-T1 byte-identically to the bundled mirror `.../enforce-orchestration-preimplementation-gate.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P4-T3] Verify Part-5 registration: confirm `.claude/settings.json` registers this hook under Bash, Write|Edit, and Agent matchers, and confirm the bundled `settings.json` mirror matches.
  - Acceptance: `evidence/other/preimpl-gate-registration.2026-06-28T00-00.md` cites settings.json lines 90/119/144 and confirms the mirror is identical; no settings.json change required (or, if a change is made, the mirror is updated in this batch).
- [x] [P4-T4] Update `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` to assert the new deny/allow shape via `CheckpointRaw`-injected decision calls; no temp files.
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P4-T5] Run the Phase-4 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase4-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 5 — check-python-test-purity.ps1 (Part 1)

- [x] [P5-T1] Apply the schema transformation to `.claude/hooks/check-python-test-purity.ps1`.
  - Replace the block literal in `Get-PythonTestPurityBlockDecision`; retain the conditional emit-on-block logic but switch to the `hookSpecificOutput` deny shape and `ConvertTo-Json -Compress -Depth 5`; allow paths emit no decision (valid for PreToolUse).
  - Acceptance: deny emitted in `hookSpecificOutput` shape; exit always 0; file <= 500 lines.
- [x] [P5-T2] Replicate P5-T1 byte-identically to the bundled mirror `.../check-python-test-purity.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P5-T3] Update `tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1` to assert the new deny shape (serialize-then-parse on `Get-PythonTestPurityBlockDecision`); no temp files.
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P5-T4] Run the Phase-5 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase5-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 6 — enforce-python-batch-budget.ps1 (Part 1)

- [x] [P6-T1] Apply the schema transformation to `.claude/hooks/enforce-python-batch-budget.ps1`.
  - Replace block/allow literals in `Get-PythonBatchBudgetBlockDecision` / `Invoke-PythonBatchBudgetDecision`, preserving sibling keys `state`/`shouldWriteState`; keep the existing `state`-key stripping before emission; entrypoint `ConvertTo-Json -Compress -Depth 5`.
  - Acceptance: deny/allow in `hookSpecificOutput` shape with `state`/`shouldWriteState` preserved on the allow object and `state` stripped before emission; exit always 0; file <= 500 lines.
- [x] [P6-T2] Replicate P6-T1 byte-identically to the bundled mirror `.../enforce-python-batch-budget.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P6-T3] Update `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` to assert the new deny shape and preserved-state behavior; inject the `TestPathExists`/`ReadState`/`WriteState`/`EnsureDirectory` seams (no temp files).
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P6-T4] Run the Phase-6 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase6-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 7 — check-powershell-test-purity.ps1 (Part 1 + Part 5 restructuring)

- [x] [P7-T1] Extract a pure deny-builder and restructure `.claude/hooks/check-powershell-test-purity.ps1`.
  - Add pure `Get-PowerShellTestPurityBlockDecision` (mirroring the Python purity hook) returning the `[ordered]@{ hookSpecificOutput = ... }` deny object; convert the inline plain `@{}` to `[ordered]@{}`; emit via `ConvertTo-Json -Compress -Depth 5`; add the dot-sourcing guard `if ($MyInvocation.InvocationName -eq '.') { return }`.
  - Acceptance: deny emitted in `hookSpecificOutput` shape; `[ordered]` used; dot-sourcing guard present; exit always 0; file <= 500 lines.
- [x] [P7-T2] Replicate P7-T1 byte-identically to the bundled mirror `.../check-powershell-test-purity.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P7-T3] Update `tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1` to dot-source the hook and assert the new deny shape via `Get-PowerShellTestPurityBlockDecision`; no temp files.
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P7-T4] Run the Phase-7 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase7-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 8 — enforce-powershell-batch-budget.ps1 (Part 1 + Part 5 confirmation)

- [x] [P8-T1] Apply the schema transformation to `.claude/hooks/enforce-powershell-batch-budget.ps1`.
  - Replace block/allow literals in `Get-PowerShellBatchBudgetBlockDecision` / `Invoke-PowerShellBatchBudgetDecision`, preserving `state`/`shouldWriteState`; keep `state`-key stripping before emission; entrypoint `ConvertTo-Json -Compress -Depth 5`.
  - Acceptance: deny/allow in `hookSpecificOutput` shape; exit always 0; file <= 500 lines.
- [x] [P8-T2] Replicate P8-T1 byte-identically to the bundled mirror `.../enforce-powershell-batch-budget.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P8-T3] Verify Part-5 registration: confirm this hook is registered under Write|Edit in `.claude/settings.json` (line 111) and the mirror matches.
  - Acceptance: `evidence/other/pwsh-batch-budget-registration.2026-06-28T00-00.md` cites the registration line and mirror parity.
- [x] [P8-T4] Update `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` to assert the new deny shape and preserved-state behavior; inject the state seams (no temp files).
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P8-T5] Run the Phase-8 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase8-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 9 — enforce-evidence-locations.ps1 (Part 1 + Part 7 decision)

- [x] [P9-T1] Apply the schema transformation to `.claude/hooks/enforce-evidence-locations.ps1`.
  - Replace block/allow literals in `Get-EvidenceLocationBlockDecision` / `Invoke-EvidenceLocationDecision`; update the decision-gate comparison; entrypoint `ConvertTo-Json -Compress -Depth 5`; preserve the `Invoke-EvidenceLocationEntryPoint` int-returning pattern and its error-path `return 1`/`exit 1`.
  - Acceptance: deny/allow in `hookSpecificOutput` shape; error-path int-return preserved; no deny-path `exit 1`; file <= 500 lines.
- [x] [P9-T2] Replicate P9-T1 byte-identically to the bundled mirror `.../enforce-evidence-locations.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P9-T3] Resolve Part-7 research-path migration as out-of-scope no-op with justification.
  - Verify the repo writes research under `docs/features/<feature>/research/` (this feature does) and never under `artifacts/research/`; therefore no `artifacts/research/` forbidden-prefix addition is required.
  - Acceptance: `evidence/other/part7-research-path-decision.2026-06-28T00-00.md` records `SearchScope:`, `SearchPatterns:`, `SearchResult:` proving no `artifacts/research/` writes exist, and states the no-op decision. No code change to the forbidden-prefix list.
- [x] [P9-T4] Update `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` to assert the new deny shape via `Get-EvidenceLocationBlockDecision`; no temp files.
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P9-T5] Run the Phase-9 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase9-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 10 — enforce-feature-folder-order.ps1 (Part 1)

- [x] [P10-T1] Apply the schema transformation to `.claude/hooks/enforce-feature-folder-order.ps1`.
  - Replace the inline block literal and allow literals in `Invoke-FeatureFolderOrderDecision`; update the decision-gate comparison; entrypoint `ConvertTo-Json -Compress -Depth 5`; retain error-path `exit 1`; do not alter the `Get-FeatureFolderFileExistence` seam.
  - Acceptance: deny/allow in `hookSpecificOutput` shape; no deny-path `exit 1`; file <= 500 lines.
- [x] [P10-T2] Replicate P10-T1 byte-identically to the bundled mirror `.../enforce-feature-folder-order.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P10-T3] Update `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` to assert the new deny shape; inject `Get-FeatureFolderFileExistence` (no temp files).
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P10-T4] Run the Phase-10 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase10-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 11 — enforce-checkpoint-monotonic.ps1 (Part 1 + Part 4 prerequisite gate)

- [x] [P11-T1] Apply the schema transformation to both block sites in `.claude/hooks/enforce-checkpoint-monotonic.ps1`.
  - Replace the order-violation block literal and the missing-prerequisite block literal with the `hookSpecificOutput` deny shape; replace the allow literals; update the decision-gate comparison; entrypoint `ConvertTo-Json -Compress -Depth 5`; retain error-path `exit 1`; do not alter `Test-StepHasPrefix`, `Get-MissingPrerequisiteForAdvancedStep`, or `ConvertFrom-CheckpointJson`.
  - Acceptance: both deny paths emit the `hookSpecificOutput` deny shape; the missing-prerequisite deny reason still names `S3_promotion` and `S4_atomic_planning`; no deny-path `exit 1`; file <= 500 lines.
- [x] [P11-T2] Replicate P11-T1 byte-identically to the bundled mirror `.../enforce-checkpoint-monotonic.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P11-T3] Verify the Part-4 prerequisite gate behavior and update the positive fixture in `tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1`.
  - Confirm: an advanced step (canonical index >= 5) present while `S3_promotion` and/or `S4_atomic_planning` is absent yields a deny. Update the positive in-order allow fixture so `CompletedSteps` includes `S3_promotion` and `S4_atomic_planning`.
  - Acceptance: Positive fixture allows (with S3/S4 present) and asserts `permissionDecision='allow'`.
- [x] [P11-T4] Add a negative prerequisite-gate test to `tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1`.
  - Assert deny when an advanced step is present with S3/S4 missing; assert the deny reason text names `S3_promotion` and `S4_atomic_planning`; assert `hookEventName='PreToolUse'` and `permissionDecision='deny'`. Inject `ConvertFrom-CheckpointJson` via `ToolInputRaw` (no temp files).
  - Acceptance: Negative test passes and asserts the new deny shape and reason content.
- [x] [P11-T5] Run the Phase-11 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase11-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 12 — enforce-completion-consistency.ps1 + enforce-completion-helpers.ps1 (Part 1 + Part 6)

- [x] [P12-T1] Apply the schema transformation to `.claude/hooks/enforce-completion-consistency.ps1`.
  - Replace the block literal and allow literals in `Invoke-CompletionConsistencyDecision`; update the decision-gate comparison; entrypoint `ConvertTo-Json -Compress -Depth 5`; retain error-path `exit 1`; keep dot-sourcing of `enforce-completion-helpers.ps1`. If the addition risks exceeding 500 lines, extract the deny-reason string to a constant to stay under cap.
  - Acceptance: deny/allow in `hookSpecificOutput` shape; no deny-path `exit 1`; file <= 500 lines (verify tight headroom).
- [x] [P12-T2] Replicate P12-T1 byte-identically to the bundled mirror `.../enforce-completion-consistency.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P12-T3] Replicate `enforce-completion-helpers.ps1` to its bundled mirror (no schema change to helpers; parity-only sync if runtime is unchanged).
  - Files: `.claude/hooks/enforce-completion-helpers.ps1` and `.../claude-customizations/.claude/hooks/enforce-completion-helpers.ps1`.
  - Acceptance: Helpers mirror is byte-identical to runtime; `Test-IsValidIssueNum` / `Test-IsValidFeatureFolder` / `Test-RouteRequiresPrGate` unchanged. The hook is NOT deregistered.
- [x] [P12-T4] Update `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` to assert the new deny shape; inject `FolderExistsCheck`/`CheckpointReader`/`RoutingMatrixReader` (no temp files).
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'`; passes.
- [x] [P12-T5] Run the Phase-12 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase12-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 13 — enforce-prd-feature-before-planner.ps1 (Part 1)

- [x] [P13-T1] Apply the schema transformation to both block sites in `.claude/hooks/enforce-prd-feature-before-planner.ps1`.
  - Replace the no-folder block literal and the missing-files block literal with the `hookSpecificOutput` deny shape; replace allow literals; update the decision-gate comparison; entrypoint `ConvertTo-Json -Compress -Depth 5`; retain error-path `exit 1`; do not alter `Get-PrdFeatureFileExistence` or `Get-PrdFeatureCheckpointFolder`.
  - Acceptance: both deny paths emit the `hookSpecificOutput` deny shape; no deny-path `exit 1`; file <= 500 lines.
- [x] [P13-T2] Replicate P13-T1 byte-identically to the bundled mirror `.../enforce-prd-feature-before-planner.ps1`.
  - Acceptance: Mirror byte-identical to runtime.
- [x] [P13-T3] Update `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` to assert the new deny shape on both block paths; inject the file-existence and checkpoint seams (no temp files).
  - Acceptance: Test asserts `hookEventName='PreToolUse'` and `permissionDecision='deny'` for both deny paths; passes.
- [x] [P13-T4] Run the Phase-13 verification loop (format → analyze → test, then parity pytest).
  - Acceptance: `evidence/qa-gates/phase13-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings; Pester + parity pass.

---

### Phase 14 — PreToolUse schema contract test (Part 2)

- [x] [P14-T1] Create `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (Pester v5).
  - For EACH of the 13 PreToolUse hooks: dot-source the hook (using its dot-sourcing guard), mock filesystem seams (no disk/network/temp files), obtain a representative DENY decision from the hook's pure decision/deny-builder function, serialize with `ConvertTo-Json -Depth 5`, re-parse with `ConvertFrom-Json`, and assert `parsed.hookSpecificOutput.hookEventName -eq 'PreToolUse'` and `parsed.hookSpecificOutput.permissionDecision -eq 'deny'`. One assertion block per hook.
  - Path note: file MUST be under `tests/scripts/claude-hooks/` (a Pester discovery root); `tests/hooks/` is NOT a discovery root.
  - Acceptance: File exists at `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` with one DENY assertion block per PreToolUse hook (13 total); file <= 500 lines.
- [x] [P14-T2] Run the contract test and the full PowerShell hook suite.
  - Commands: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`.
  - Acceptance: `evidence/qa-gates/phase14-qa.2026-06-28T00-00.md` records the four schema fields per command; the contract test passes; analyzer 0 findings on the new test file.

---

### Phase 15 — SubagentStop validator hardening verification (Part 3; KEEP top-level decision:block / exit 1)

- [x] [P15-T1] Verify Part 3.1 (multi-language executor status) in `.claude/hooks/validate-executor-output.ps1`.
  - Confirm `Test-OutputHasLanguageStatus` (lines ~118–139) detects per-language PASS/FAIL via the `$labelMap` and regex; confirm `Get-TouchedLanguagesFromPlan` (lines ~93–116); confirm the command-evidence regex (lines ~265–266) includes `npx `. If any element is absent, add an atomic fix task; otherwise record a no-op verification citing the function and line. SubagentStop block form unchanged.
  - Acceptance: `evidence/other/part3-1-executor.2026-06-28T00-00.md` cites the functions/lines and states no-op or the specific gap fixed; the validator still emits top-level `decision:block` + `exit 1`.
- [x] [P15-T2] Verify Part 3.2 (multi-language coverage floors) in `.claude/hooks/validate-feature-review-coverage.ps1`.
  - Confirm per-language LCOV parsing (`Get-LcovRepoCoverage`, `Get-LcovBranchCoverage`) and JaCoCo parsing (`Get-JacocoRepoCoverage`, `Get-JacocoBranchCoverage`); confirm `Test-LanguageCoverageRow` enforces BOTH floors line < 85% FAIL and branch < 75% FAIL; confirm scope-narrowing-as-failure handling. Add an atomic fix task only where the research identifies a concrete gap; otherwise record a no-op verification.
  - Acceptance: `evidence/other/part3-2-coverage.2026-06-28T00-00.md` cites the functions/lines and the two floor checks (line 85% / branch 75%) and states no-op or the specific gap fixed; SubagentStop block form unchanged.
- [x] [P15-T3] Verify Part 3.3 (routing-contract subprocess seam + human_interaction shape gate) in `.claude/hooks/validate-orchestrator-output.ps1`.
  - Confirm `Invoke-RoutingContractValidation` has an injectable `Invoker` scriptblock seam and produces a `ROUTING_CONTRACT_BLOCKED` outcome; confirm `Test-HumanInteractionShape` enforces the `human_interaction` invariants (requirements array; `response` in {scope_change, exception, halt}; `halt` blocks; `exception` requires existing `runbook_path`). Add a fix task only where a concrete gap exists; otherwise record a no-op verification.
  - Acceptance: `evidence/other/part3-3-routing-human.2026-06-28T00-00.md` cites the functions/lines and states no-op or the specific gap fixed; SubagentStop block form unchanged.
- [x] [P15-T4] Verify Part 3.4 (two research roots + Automation-Feasibility gate) in `.claude/hooks/validate-task-researcher-output.ps1`.
  - Confirm `Test-IsUnderResearchRoot` accepts both `docs/features/<...>/research/` and `docs/research/`; confirm `Test-AutomationFeasibilitySection` gates the `## Automation Feasibility` heading via its regex through the injectable `ReadFileContent` seam. Add a fix task only where a concrete gap exists; otherwise record a no-op verification.
  - Acceptance: `evidence/other/part3-4-research-roots.2026-06-28T00-00.md` cites the functions/lines and states no-op or the specific gap fixed; SubagentStop block form unchanged.
- [x] [P15-T5] Replicate any Part-3 runtime change byte-identically to its bundled mirror, or record that all Part-3 tasks were no-op verifications requiring no mirror edit.
  - Acceptance: For each Part-3 file actually edited, the mirror under `.../claude-customizations/.claude/hooks/` is byte-identical; if no edits were made, `evidence/other/part3-mirror.2026-06-28T00-00.md` records the no-edit status.
- [x] [P15-T6] Run the Part-3 verification loop (format → analyze → test for the four SubagentStop validators, then parity pytest only if any file was edited).
  - Acceptance: `evidence/qa-gates/phase15-qa.2026-06-28T00-00.md` records the four schema fields per command; analyzer 0 findings on any changed validator; the SubagentStop validator Pester tests pass; parity pytest passes if applicable.

---

### Phase 16 — Final QA Gate and Verification

- [x] [P16-T1] Run the full PoshQC format check across all changed hooks and tests.
  - Command: `mcp__drm-copilot__run_poshqc_format`.
  - Acceptance: `evidence/qa-gates/final-format.2026-06-28T00-00.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; format clean (0 files needing format). Restart the loop if any file is reformatted.
- [x] [P16-T2] Run the full PSScriptAnalyzer check across all changed hooks and tests.
  - Command: `mcp__drm-copilot__run_poshqc_analyze`.
  - Acceptance: `evidence/qa-gates/final-analyze.2026-06-28T00-00.md` records the four schema fields; 0 findings on changed files.
- [x] [P16-T3] Run the full Pester hook suite with coverage, including the new contract test.
  - Command: `mcp__drm-copilot__run_poshqc_test` (coverage-enabled).
  - Acceptance: `evidence/qa-gates/final-pester.2026-06-28T00-00.md` records the four schema fields and numeric post-change line-coverage % (>= 85%) and branch-coverage % (>= 75%); all hook tests and `PreToolUseSchema.Contract.Tests.ps1` pass.
- [x] [P16-T4] Record the coverage delta verification.
  - Acceptance: `evidence/qa-gates/coverage-delta.2026-06-28T00-00.md` reports baseline coverage (from P0-T4), post-change coverage (from P16-T3), and changed-code coverage; confirms no regression on changed lines.
- [x] [P16-T5] Run the bundle-parity pytest and confirm runtime == mirror across all touched hooks.
  - Command: `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
  - Acceptance: `evidence/qa-gates/final-bundle-parity.2026-06-28T00-00.md` records the four schema fields; pytest passes (byte-identical parity across `.claude/**`, including the pre-existing validate-bash divergence now resolved).
- [x] [P16-T6] Produce the grep proof of schema compliance.
  - Search all 13 PreToolUse hooks (runtime + mirror) and confirm: no top-level `decision = 'block'` / `decision = 'allow'` / `decision`/`reason` emission shape remains and no deny-path `exit 1` remains; confirm the four SubagentStop validators STILL use top-level `decision:block` + `exit 1`.
  - Acceptance: `evidence/qa-gates/schema-grep-proof.2026-06-28T00-00.md` shows zero legacy-shape/deny-`exit 1` occurrences in PreToolUse hooks and confirms SubagentStop validators unchanged.
- [x] [P16-T7] Verify the 500-line cap on every touched `.ps1`.
  - Acceptance: `evidence/qa-gates/line-count-proof.2026-06-28T00-00.md` lists each touched `.ps1` (runtime, mirror, test) with its final line count; all <= 500.

---

## Acceptance-Criteria Mapping (issue.md AC → phase/task)

| issue.md Acceptance Criterion | Satisfying phase/task |
|---|---|
| Every PreToolUse-registered hook emits `hookSpecificOutput`/`permissionDecision=deny` for blocks and `permissionDecision=allow` for allows; no top-level `decision`/`reason` or `exit 1` to block | Phases 1–13 (all 13 hooks + mirrors) and per-hook test updates; proven by P16-T6 grep proof and P14 contract test |
| `validate-bash` blocks via a pure detector + deny-decision builder writing `hookSpecificOutput`, never `exit 1` | P1-T1, P1-T2, P1-T3 |
| Serialize-then-parse contract test asserts `permissionDecision=deny` and `hookEventName=PreToolUse` for every PreToolUse hook | P14-T1, P14-T2 |
| SubagentStop validator hardening (Parts 3.1–3.4) ported without changing the SubagentStop block form | P15-T1, P15-T2, P15-T3, P15-T4, P15-T5, P15-T6 |
| checkpoint-monotonic prerequisite gate (Part 4) and new PreToolUse gate hooks (Part 5) present, registered, tested on correct schema | P11 (Part 4 gate + tests); P4-T3, P8-T3 (Part 5 registration); P7 (Part 5 pwsh-test-purity restructure) |
| Bundled mirror hooks match runtime hooks; bundle-parity contract tests pass | Mirror tasks in every Part-1 phase (P1-T2 … P13-T2, P12-T3) and P16-T5 |
| PoshQC format clean, PSScriptAnalyzer 0 findings on changed files, all Pester hook tests pass, every touched `.ps1` <= 500 lines | P16-T1, P16-T2, P16-T3, P16-T7 |

## Part-to-Phase Coverage Map

- Part 1 (fix PreToolUse deny-schema in all 13 hooks + mirrors): Phases 1–13.
- Part 2 (contract test at `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`): Phase 14.
- Part 3 (SubagentStop validator hardening, keep block form): Phase 15.
- Part 4 (checkpoint-monotonic prerequisite gate + tests): Phase 11.
- Part 5 (three gate hooks confirm + tests): Phase 4 (preimpl gate), Phase 8 (pwsh batch budget), Phase 7 (pwsh test purity).
- Part 6 (completion-consistency + helpers schema fix + test; not deregistered): Phase 12.
- Part 7 (evidence-locations research-path migration; out-of-scope no-op with justification): Phase 9 (P9-T3).

## Evidence Location Invariant

All evidence artifacts resolve to `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/evidence/<kind>/`
(`baseline/`, `qa-gates/`, `other/`). No `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`,
`artifacts/evidence/`, or `artifacts/research/` evidence paths are used.

## Open Notes

- `enforce-completion-consistency.ps1` has the tightest 500-line headroom (~80 lines). P12-T1 includes a contingency to extract the deny-reason string to a constant if the envelope addition risks exceeding the cap.
- `validate-bash.ps1` has a pre-existing mirror parity divergence (`-ErrorAction Stop`); P1-T2 resolves it in the same batch as the runtime change.
- The live-harness denial verification is out-of-band and is not a Pester test; the in-repo proving artifact is the Phase-14 contract test.
