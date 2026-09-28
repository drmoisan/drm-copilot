# Final QC — PowerShell Tests and Coverage (P6-T7)

Timestamp: 2026-08-07T17-05

Command (primary, per plan text): `mcp__drm-copilot__run_poshqc_test` invoked with `workspace_root` only (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2857bcb4458f15cf`).

EXIT_CODE: 1

Command (supplementary, coverage capture): `pwsh -NoProfile -File <scratchpad>/direct-pester.ps1 -WorkspaceRoot <worktree> -OutputRoot <scratchpad>` — `Invoke-Pester` driven directly from the worktree's own `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, outputs redirected to the session scratchpad.

EXIT_CODE: 0 (`Run.Exit = $false` set for the supplementary run; test outcome recorded below)

Output Summary: 1995 tests executed: 1985 passed, 1 failed, 9 skipped, 0 errors, in 89.8s (baseline P0-T8: 1711 executed, 1701 passed, 1 failed, 9 skipped; +284 tests added by this feature). The observed failure set is exactly the one known session-induced failure documented in the P0-T8 baseline artifact's "Orchestrator Correction" section; no additional failure appeared, so the PowerShell gate is clean by the stated criterion. Post-change Pester coverage measured against the worktree runsettings is 94.50% by command/instruction (4858 of 5141; 283 missed) and 94.88% by line (3557 of 3749; 192 missed), up from the 93.95% / 94.34% baseline. The five new `.claude/lib/blast-radius/` modules are covered at 99.09% by command (542 of 547; 5 missed) and 99.27% by line (409 of 412; 3 missed), with per-module figures below. All values exceed line >= 85% and are recorded numerically with no placeholder.

## Two Recorded Runs and Why Both Are Present

The plan's P6-T7 acceptance requires "a numeric coverage value covering the new module(s)". The bundled MCP PoshQC resolves its Pester settings from the **installed** extension resources (v1.0.21), which predate the Phase 4 `CodeCoverage.Path` append made in this worktree. Its coverage output therefore enumerates the pre-Phase-4 file set and contains no `.claude/lib/blast-radius` package at all. This is a settings-resolution behavior of the installed tool, not a defect in the change.

Verification of the resolution behavior: the MCP run's `artifacts/pester/powershell-coverage.xml` reports report-level counters `INSTRUCTION covered=4316 missed=278` and `LINE covered=3148 missed=189` — byte-identical to the P0-T8 baseline captured before the Phase 4 append — and its `<package>` list contains `.claude/hooks`, `.claude/lib/model-routing`, `.claude/lib/orchestrator-state`, `.codex/hooks`, `scripts/dev-tools`, `scripts/powershell`, and `scripts/powershell/PoshQC`, with no `.claude/lib/blast-radius` entry. Coverage of the new modules is consequently unobtainable from the MCP surface in this worktree.

The supplementary direct run loads the worktree's own runsettings verbatim (identical `Run.Path`, identical `CodeCoverage.Path` including the five Phase 4 entries) and therefore does measure the new modules. Its outputs were written to the session scratchpad so the canonical `artifacts/pester/` outputs from the MCP run were not overwritten. No repository file was added or modified by the supplementary run.

Both runs executed the same test set and produced the same result: 1995 tests, 1985 passed, 1 failed, 9 skipped, with the identical single failing test.

## MCP Run Result

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a2857bcb4458f15cf",
  "summary": "Command exited with code 1."
}
```

`ok: false` / exit 1 arises because Pester `Run.Exit = $true` propagates the single test failure. Read from `artifacts/pester/pester-junit.xml`: `<testsuites ... tests="1995" errors="0" failures="1" disabled="9" time="89.808">`; status tally 1985 Passed, 1 Failed, 9 Skipped. Coverage counters from `artifacts/pester/powershell-coverage.xml`: `INSTRUCTION missed="278" covered="4316"` (93.95%), `LINE missed="189" covered="3148"` (94.34%) — unchanged from baseline because the measured file set is unchanged.

## The Single Failing Test — Attribution

- File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Test: `enforce-pr-author-skill.ps1 > allowed commands > allows gh pr create --body-file artifacts/pr_body_12.md when context exists`

This is exactly the failure recorded in `evidence/baseline/baseline-powershell-test-coverage.2026-08-07T14-17.md` and corrected in that artifact's "Orchestrator Correction — Attribution and CI Reachability (appended 2026-08-07T14-30)" section. Per that correction:

- The failure is session-induced, not feature-induced. The `allowed commands` Context does not mock the `Get-PrAuthorCheckpointContent` seam, so it reads this session's live `artifacts/orchestration/orchestrator-state.json`, which records `epic_mode: true`. A controlled experiment recorded in the baseline artifact confirmed the test passes when the checkpoint is moved aside and fails when it is present.
- The failure cannot reach CI. `artifacts/` is gitignored at repository root (`.gitignore:6:/artifacts`), so the checkpoint is never committed and is absent on a CI runner.
- The baseline artifact states the Phase 6 gate criterion explicitly: "the gate is clean if and only if the observed failure set equals exactly this one test. Any additional failure is a regression attributable to this feature."

The observed failure set in both runs is exactly this one test, verified by enumerating every non-Passed, non-Skipped `<testcase>` in both JUnit outputs (1 result in each, identical). **The PowerShell gate therefore passes under the stated criterion.**

Per the baseline artifact's Guardrail 2 constraint, `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` was not modified, and the orchestrator checkpoint was neither modified nor deleted, to make this gate green.

## Post-Change Coverage (direct run, worktree runsettings)

Report-level totals over the 46 measured files:

| Metric | Baseline (P0-T8, MCP) | Post-change (direct run) | Delta |
|---|---|---|---|
| Command (instruction) coverage | 93.95% | 94.50% | +0.55 pp |
| Line coverage | 94.34% | 94.88% | +0.54 pp |
| Commands covered / analyzed | 4316 / 4594 | 4858 / 5141 | +542 / +547 |
| Commands missed | 278 | 283 | +5 |
| Lines covered / analyzed | 3148 / 3337 | 3557 / 3749 | +409 / +412 |
| Lines missed | 189 | 192 | +3 |
| Methods covered / missed | 240 / 26 | 282 / 26 | +42 / 0 |
| Classes covered / missed | 39 / 2 | 44 / 2 | +5 / 0 |

The entire increase in the denominator (+547 commands, +412 lines) is the five new blast-radius modules; the pre-existing measured surface is unchanged.

## Per-Module Coverage — The Five New Blast-Radius Modules

Package `.claude/lib/blast-radius` aggregate: **99.09% command** (542 of 547 covered; 5 missed), **99.27% line** (409 of 412 covered; 3 missed), 100.00% method (42 of 42), 100.00% class (5 of 5).

| Module | Commands covered / analyzed | Command coverage | Lines covered / analyzed | Line coverage |
|---|---|---|---|---|
| `.claude/lib/blast-radius/BlastRadius.psm1` | 121 / 121 | 100.00% | 80 / 80 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 105 / 105 | 100.00% | 82 / 82 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 114 / 114 | 100.00% | 98 / 98 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 67 / 67 | 100.00% | 57 / 57 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 135 / 140 | 96.43% | 92 / 95 | 96.84% |

Every module exceeds the 85% line threshold.

## The Three Uncovered Lines

All three sit in `BlastRadiusValidation.psm1`:

- Line 145 — `throw` in `New-RadiusFinding` for a `Rule` outside the allowed set. Internal invariant guard; every production caller passes a literal from `$script:FindingRule`, so no test can reach it without bypassing the module's own constructors.
- Line 148 — the sibling `throw` for a `Severity` outside the allowed set, with the same rationale.
- Line 291 — `$position -= 1` in the insertion-sort backscan of the finding-ordering helper. Reached only when a candidate must move more than one slot; the fixture corpus produces findings that are already near-ordered, so the multi-slot backscan step is not exercised.

Module coverage remains 96.43% command / 96.84% line, above the threshold, so no remediation is required.

## Test Counts

| Result | Baseline (P0-T8) | Post-change |
|---|---|---|
| Passed | 1701 | 1985 |
| Failed | 1 | 1 (identical test) |
| Skipped (disabled) | 9 | 9 |
| Errors | 0 | 0 |
| Total | 1711 | 1995 |
| Duration | 91.252s | 89.808s (MCP) / 89.026s (direct) |
