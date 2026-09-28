# Baseline — PowerShell Tests and Coverage (PoshQC / Pester 5.6.1)

Timestamp: 2026-08-07T14-17

Task: [P0-T8]
Feature: 2026-08-07-parallel-blast-radius-447 (issue #447)
Branch: feature/parallel-blast-radius-447
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a2857bcb4458f15cf`

Command: `mcp__drm-copilot__run_poshqc_test` invoked with `workspace_root` only (no `scan_folders`; the tool resolves scan folders from `config/poshqc-scan.json` and Pester settings, including `CodeCoverage.Path`, from `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`).

EXIT_CODE: 1

Output Summary: Baseline is NOT green. 1711 tests executed: 1701 passed, 1 failed, 9 skipped, 0 errors, in 91.252s. The MCP tool returned `ok: false` with "Command exited with code 1" because Pester `Run.Exit = $true` propagates the single test failure. Baseline Pester code coverage is 93.95% by command/instruction (4316 of 4594 commands covered; 278 missed) and 94.34% by line (3148 of 3337 lines covered; 189 missed), measured over the 47 files enumerated in `CodeCoverage.Path`. Both baseline coverage values exceed the 85% line threshold. The single failure is pre-existing on the branch head, environment-coupled, and unrelated to issue #447 (details below); it does not block Phases 1-5, and its handling in Phase 6 is stated below.

## Numeric Coverage Baseline

| Metric | Value |
|---|---|
| Command (instruction) coverage | 93.95% |
| Line coverage | 94.34% |
| Commands covered | 4316 |
| Commands missed | 278 |
| Commands analyzed | 4594 |
| Lines covered | 3148 |
| Lines missed | 189 |
| Lines analyzed | 3337 |
| Methods covered / missed | 240 / 26 |
| Classes covered / missed | 39 / 2 |

Pester reports its headline percentage over analyzed commands; 93.95% is therefore the value to compare against the Phase 6 post-change figure. `CoveragePercentTarget` is set to 0 in the runsettings, so coverage does not itself fail the run.

## Test Counts

| Result | Count |
|---|---|
| Passed | 1701 |
| Failed | 1 |
| Skipped (disabled) | 9 |
| Errors | 0 |
| Total | 1711 |
| Duration | 91.252s |

## Failing Test (pre-existing, environment-coupled)

- File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142`
- Test: `enforce-pr-author-skill.ps1 > allowed commands > allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion: `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`
- Observed: `deny` (expected `allow`)

Cause, as read from `.claude/hooks/enforce-pr-author-skill.ps1`: receipt verification Check 6 calls `Test-EpicBaseBranchOverride`, which reads the live orchestrator-state checkpoint through the `Get-PrAuthorCheckpointContent` seam. The `allowed commands` Context mocks `Get-PrContextArtifactExistence`, `Invoke-OrchestratorStatePreflight`, `Get-PrBodyFileBytes`, `Get-PrAuthorReceiptContent`, and `Get-PrContextSummaryLastWriteUtc`, but does not mock `Get-PrAuthorCheckpointContent`. The repository's current `artifacts/orchestration/orchestrator-state.json` contains `"epic_mode": true` with `"integration_branch": "epic/parallel-orchestration-integration"`, so Check 6 blocks the mocked `gh pr create` command (which carries no `--base`) with `EPIC_BASE_BRANCH_MISMATCH`. The sibling `gh pr edit` assertion passes because Check 6 applies only to `gh pr create`.

Assessment:
- The failure is a test-isolation defect in an existing test (an unmocked seam reading live session state), not a defect introduced by this feature. The working tree at the time of this run contained no source change — `git status --porcelain` listed only the untracked Phase 0 evidence directory.
- The failure is in `tests/scripts/claude-hooks/`, entirely outside the surface this feature touches (`.claude/lib/blast-radius/`, `scripts/dev_tools/`, `tests/scripts/claude-lib/blast-radius/`, `tests/fixtures/blast_radius/`, `config/blast-radius.json`).
- It does not block Phases 1 through 5.
- It does affect the Phase 6 exit gate: P6-T7 requires `mcp__drm-copilot__run_poshqc_test` to succeed, and this pre-existing failure will keep the tool at exit 1 for as long as `artifacts/orchestration/orchestrator-state.json` records `epic_mode: true`. This baseline is recorded so Phase 6 can distinguish this known pre-existing failure from any regression introduced by this feature. Per Phase 0 scope, no repository file was modified to make this baseline pass.

## Raw Tool Result

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a2857bcb4458f15cf",
  "summary": "Command exited with code 1."
}
```

## Source Artifacts Parsed for These Numbers

The MCP surface returns a status object without counts, so the numbers above were read from the run's own Pester outputs configured in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (both are gitignored build outputs, not evidence):

- `artifacts/pester/pester-junit.xml` — `<testsuites ... tests="1711" errors="0" failures="1" disabled="9" time="91.252">`; status tally: 1701 `Passed`, 1 `Failed`, 9 `Skipped`.
- `artifacts/pester/powershell-coverage.xml` — report-level counters: `INSTRUCTION missed="278" covered="4316"`, `LINE missed="189" covered="3148"`, `METHOD missed="26" covered="240"`, `CLASS missed="2" covered="39"`.

## Orchestrator Correction — Attribution and CI Reachability (appended 2026-08-07T14-30)

The mechanism described above is confirmed correct. Two characterizations in the preceding
section are corrected here on the basis of a controlled experiment run by the orchestrator.

**Correction 1 — the failure is session-induced, not pre-existing.** The failure did not exist
before this orchestration session. It is caused by the orchestrator's own checkpoint at
`artifacts/orchestration/orchestrator-state.json`, which this session wrote with
`"epic_mode": true` prior to Phase 0. Controlled verification:

- Command: temporarily move `artifacts/orchestration/orchestrator-state.json` aside, then run
  `Invoke-Pester` filtered to `*allows gh pr create --body-file*`.
- Result with the checkpoint absent: `Tests Passed: 1, Failed: 0`.
- Result with the checkpoint present: the same test fails with `EPIC_BASE_BRANCH_MISMATCH`.
- The checkpoint was restored immediately after the experiment; no repository file was modified.

The accurate characterization is therefore: an existing latent test-isolation defect that any
epic-mode orchestration session triggers, and that this session triggered. It is not a defect in
the blast-radius feature, and it is not a defect that predates the session in an observable form.
The phrase "pre-existing on the branch head" in the Output Summary above is superseded by this
correction.

**Correction 2 — the failure cannot reach CI.** `artifacts/` is gitignored at repository root
(`.gitignore:6:/artifacts`), verified with
`git check-ignore -v artifacts/orchestration/orchestrator-state.json`. The checkpoint is never
committed and is absent on a CI runner, so `Test-EpicBaseBranchOverride` reads no checkpoint and
Check 6 does not fire. This failure is strictly local to an epic-mode working tree and will not
appear in the CI PowerShell gate for this pull request.

**Consequence for the Phase 6 exit gate.** P6-T7 requires `mcp__drm-copilot__run_poshqc_test` to
succeed. Because the cause is the session checkpoint and not the feature, Phase 6 must record the
PowerShell gate against this known-cause baseline: the gate is clean if and only if the observed
failure set equals exactly this one test. Any additional failure is a regression attributable to
this feature. Phase 6 must not modify
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` to make the gate pass — that file
is outside the three existing files Guardrail 2 authorizes for edit.

**Follow-up.** The unmocked `Get-PrAuthorCheckpointContent` seam in the `allowed commands` Context
is a genuine test-isolation defect worth fixing repo-wide, because every epic-mode session will
reproduce it. It is out of scope for issue #447 and is recorded here for separate promotion.
