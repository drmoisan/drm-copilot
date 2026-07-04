# Remediation Plan — enforce-evidence-locations.ps1 coverage shortfall (Issue #227)

- **Timestamp:** 2026-06-24T13-55
- **Feature folder:** docs/features/active/2026-06-24-relocate-research-canonical-location-227
- **Remediation inputs:** docs/features/active/2026-06-24-relocate-research-canonical-location-227/remediation-inputs.2026-06-24T13-55.md
- **Blocking finding addressed:** Finding 1 — `enforce-evidence-locations.ps1` line coverage 81.5% (22/27), below the uniform 85% line threshold. Uncovered region is the entry-point dispatch block (lines 145-154), unreachable from dot-sourced unit tests.

## Objective

Bring `enforce-evidence-locations.ps1` line coverage to >= 85% with no regression on changed lines, by refactoring the untestable entry-point dispatch into a testable function and adding Pester coverage for the success-output path and the malformed-JSON error path. No coverage exclusions and no assertion weakening are permitted.

## Chosen Approach (verified against current file structure)

The current file (verified at this timestamp) ends with:

```
# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $decision = Invoke-EvidenceLocationDecision -ToolInputRaw $env:CLAUDE_TOOL_INPUT
} catch {
    Write-Error $_
    exit 1
}

$decision | ConvertTo-Json -Compress | Write-Output

exit 0
```

The uncovered lines (146, 148, 149, 152, 154) are inside this block. `exit` cannot be executed in-process under Pester without terminating the test host, so the dispatch logic is extracted into a new advanced function `Invoke-EvidenceLocationEntryPoint` that:

- accepts the raw tool input as a parameter (default `$env:CLAUDE_TOOL_INPUT`),
- calls `Invoke-EvidenceLocationDecision`,
- on success: writes the compact JSON to the output stream and returns exit code `0`,
- on failure (malformed JSON): writes the error via `Write-Error` and returns exit code `1`,
- returns the integer exit code rather than calling `exit` itself.

The thin dot-source guard then becomes only:

```
if ($MyInvocation.InvocationName -eq '.') {
    return
}

exit (Invoke-EvidenceLocationEntryPoint)
```

This makes the JSON-output path and the malformed-JSON error path unit-testable through the new function. Only the single `exit (...)` wiring line and the dot-source guard remain outside unit reach; both are within the residual tolerance for the 85% threshold once the dispatch body is covered. This approach complies with the no-exclusion policy (`general-unit-test.md` Coverage Exclusion Policy) by extracting logic into a testable function rather than excluding lines.

### Parity scope

The fix applies to three production files. The root and Claude-bundled mirror are byte-identical and must remain so. The Codex copy shares the same entry-point dispatch logic (differing only in its converted-header banner and the SKILL.md path inside the block reason); the dispatch refactor is shared logic and must be mirrored there to preserve translation parity (AC7).

- Root: `.claude/hooks/enforce-evidence-locations.ps1`
- Claude mirror (byte-identical to root): `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1`
- Codex translation (parity, not byte-identical): `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1`
- Test: `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`

### Batch-cap compliance

3 production files + 1 test file. Within the PowerShell per-batch cap (max 3 production, 3 test). All four files remain well under the 500-line limit.

---

### Phase 0 — Baseline capture and policy reads

- [x] [P0-T1] Read policy files in required order and record an evidence artifact at `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/other/phase0-instructions-read.2026-06-24T13-55.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`. Acceptance: artifact exists with all three required fields and the five listed files.
- [x] [P0-T2] Capture baseline PoshQC format state for the three production hook files and the test file by running `mcp__drm-copilot__run_poshqc_format` (check mode). Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/baseline/poshqc-format.2026-06-24T13-55.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact records exit code and pass/fail signal.
- [x] [P0-T3] Capture baseline PoshQC analyze state by running `mcp__drm-copilot__run_poshqc_analyze`. Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/baseline/poshqc-analyze.2026-06-24T13-55.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (analyzer finding count). Acceptance: artifact records exit code and finding count.
- [x] [P0-T4] Capture baseline targeted Pester coverage for `enforce-evidence-locations.ps1` by running `mcp__drm-copilot__run_poshqc_test` with CodeCoverage scoped to the root and Claude-mirror hook files and the claude-hooks test path. Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/baseline/pester.2026-06-24T13-55.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including the numeric baseline line-coverage headline for `enforce-evidence-locations.ps1` (expected 81.5%, 22/27) and the uncovered line numbers. Acceptance: artifact records the numeric baseline coverage value and uncovered lines.

### Phase 1 — Refactor entry-point dispatch into a testable function (all three production files)

- [x] [P1-T1] In `.claude/hooks/enforce-evidence-locations.ps1`, add a new advanced function `Invoke-EvidenceLocationEntryPoint` (with `[CmdletBinding()]`, `[OutputType([int])]`, and an optional `[string] $ToolInputRaw = $env:CLAUDE_TOOL_INPUT` parameter) that: calls `Invoke-EvidenceLocationDecision -ToolInputRaw $ToolInputRaw` inside a try/catch; on catch writes `Write-Error $_` and returns `1`; on success writes `$decision | ConvertTo-Json -Compress | Write-Output` and returns `0`. Acceptance: function is defined above the dot-source guard, returns an `[int]` exit code, and does not call `exit` itself.
- [x] [P1-T2] In `.claude/hooks/enforce-evidence-locations.ps1`, replace the existing `try { ... } catch { ... } ; $decision | ConvertTo-Json ... ; exit 0` block (current lines 145-154) with the thin wiring `exit (Invoke-EvidenceLocationEntryPoint)` placed after the dot-source guard. Acceptance: the only post-guard statement is the single `exit (Invoke-EvidenceLocationEntryPoint)` line; no dispatch logic remains inline; file remains under 500 lines.
- [x] [P1-T3] Apply the identical edits from P1-T1 and P1-T2 to the Claude bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1`, preserving byte-for-byte equality with the root file. Acceptance: a byte-comparison of the root file and the Claude mirror reports identical content.
- [x] [P1-T4] Apply the equivalent dispatch refactor (new `Invoke-EvidenceLocationEntryPoint` function plus thin `exit (Invoke-EvidenceLocationEntryPoint)` wiring) to the Codex translation `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-evidence-locations.ps1`, preserving its converted-header banner and its existing `.agents/skills/...` SKILL.md path in the block reason (do not copy the `.claude/skills/...` path from the root). Acceptance: the Codex file contains the same `Invoke-EvidenceLocationEntryPoint` function and thin wiring as the root, while its banner and SKILL.md path remain unchanged from the pre-edit Codex copy.

### Phase 2 — Add Pester coverage for the extracted entry-point function

- [x] [P2-T1] In `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`, add a `Context 'entry-point dispatch'` block with an `It` test (Arrange-Act-Assert) that sets a representative allowed `file_path` JSON, calls `Invoke-EvidenceLocationEntryPoint -ToolInputRaw <allowed-json>`, captures the function's output and returned code, and asserts the returned code is `0` and the captured stdout is the compact JSON containing `"decision":"allow"`. Acceptance: test exercises the success-output path of `Invoke-EvidenceLocationEntryPoint` and asserts both the exit code and the emitted JSON content without weakening any assertion.
- [x] [P2-T2] In the same test file, add an `It` test (Arrange-Act-Assert) that calls `Invoke-EvidenceLocationEntryPoint -ToolInputRaw '{ not valid json'` with `-ErrorAction SilentlyContinue` (capturing the error) and asserts the returned code is `1` and that an error record matching `*malformed JSON*` was written. Acceptance: test exercises the malformed-JSON error path of `Invoke-EvidenceLocationEntryPoint`, asserts the exit code is `1`, and asserts the error message, without temporary files or external dependencies.
- [x] [P2-T3] In the same test file, add an `It` test for a forbidden path that calls `Invoke-EvidenceLocationEntryPoint -ToolInputRaw '{"file_path":"artifacts/research/notes.md"}'` and asserts the returned code is `0` and the emitted JSON contains `"decision":"block"` and `EVIDENCE_LOCATION_BLOCKED`. Acceptance: test exercises the block-decision output path through the entry-point function and asserts the JSON content and exit code.

### Phase 3 — Final QA loop (PowerShell) and coverage re-verification

- [x] [P3-T1] Run `mcp__drm-copilot__run_poshqc_format` over the three production files and the test file. If it changes any file, restart the loop from this step. Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/qa-gates/final-poshqc-format.2026-06-24T13-55.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: format check passes with exit code 0 and no residual changes.
- [x] [P3-T2] Run `mcp__drm-copilot__run_poshqc_analyze`. If it fails or changes files, fix and restart from P3-T1. Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/qa-gates/final-poshqc-analyze.2026-06-24T13-55.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (analyzer finding count, expected 0). Acceptance: analyzer reports zero findings, exit code 0.
- [x] [P3-T3] Run `mcp__drm-copilot__run_poshqc_test` for the full claude-hooks Pester suite with CodeCoverage scoped to the root and Claude-mirror `enforce-evidence-locations.ps1` files. If it fails or changes files, fix and restart from P3-T1. Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/qa-gates/final-pester-coverage.2026-06-24T13-55.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including the post-change numeric line-coverage value for `enforce-evidence-locations.ps1`, the new-code coverage for the added function, and the baseline value (81.5%) for delta context. Acceptance: full claude-hooks suite passes (exit code 0) and the artifact records post-change coverage, new-code coverage, and baseline coverage.
- [x] [P3-T4] Verify the coverage threshold and no-regression condition: confirm the post-change line coverage for `enforce-evidence-locations.ps1` recorded in P3-T3 is >= 85% and that the previously-changed line (the `'artifacts/research/'` forbidden prefix in `Test-EvidenceLocationForbidden`) remains covered. Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/qa-gates/coverage-threshold-verification.2026-06-24T13-55.md` recording baseline coverage, post-change coverage, the delta, new/changed-code coverage, and a PASS/FAIL determination. Acceptance: artifact shows line coverage >= 85% with no regression on changed lines; FAIL determination requires returning to Phase 1/2.
- [x] [P3-T5] Verify cross-ecosystem parity: confirm the root file `.claude/hooks/enforce-evidence-locations.ps1` and the Claude mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-evidence-locations.ps1` are byte-identical, and confirm the Codex copy contains the equivalent `Invoke-EvidenceLocationEntryPoint` function and thin wiring while retaining its banner and `.agents/skills/...` SKILL.md path. Write `docs/features/active/2026-06-24-relocate-research-canonical-location-227/evidence/qa-gates/cross-ecosystem-equality.2026-06-24T13-55.md` with `Timestamp:`, the byte-comparison result for root vs Claude mirror, and the Codex parity confirmation. Acceptance: root and Claude mirror are byte-identical; Codex copy has equivalent dispatch logic with its translation-specific differences intact.

## Closure Criteria

- `enforce-evidence-locations.ps1` line coverage >= 85% (recorded numerically in P3-T3 and P3-T4 artifacts).
- No regression on changed lines.
- Root and Claude bundled mirror remain byte-identical; Codex copy retains parity.
- Full claude-hooks Pester suite is green.
- No coverage exclusions introduced; no assertions weakened.
