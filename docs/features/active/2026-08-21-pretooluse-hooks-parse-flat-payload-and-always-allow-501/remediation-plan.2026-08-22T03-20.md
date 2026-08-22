# Remediation Plan — Cycle 1: PreToolUse hooks parse flat payload and always allow (#501)

- **Issue:** #501
- **Feature Folder:** `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
- **Owner:** drmoisan
- **Last Updated:** 2026-08-22T03-20
- **Status:** Remediation cycle 1 — pending execution
- **Cycle Trigger:** one Blocking finding (coverage regression) plus one Major, one Minor, and two Info findings from the initial feature review.
- **Inputs:** `remediation-inputs.2026-08-21T22-23.md`, `policy-audit.2026-08-21T22-23.md` (section 5), `code-review.2026-08-21T22-23.md` (Findings Table), `feature-audit.2026-08-21T22-23.md`, `spec.md` (AC-1 through AC-15).
- **Does not modify:** `plan.2026-08-21T17-45.md` (fully executed, 35/35 tasks checked off) or `spec.md`'s already-delivered AC-15 / scope-expansion subsection.

## Plan Overview

This cycle has one required code fix (Fix 1, Blocking) and one required documentation fix (Fix 2, Major), plus explicit disposition of three lower-severity findings. Fix 1 restores per-file line coverage on `.claude/hooks/enforce-powershell-batch-budget.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1` from the regressed 81.93% back to at least their 96.30% baseline (or, at minimum, above the 85% floor with zero changed-line regression), by giving each hook the same `Invoke-<Name>EntryPoint` seam that the other ten migrated hooks in this branch already received. Fix 2 corrects the coverage-comparison evidence artifact so it no longer asserts "no regression on changed lines" on the basis of nine files when the two batch-budget hooks were not re-examined.

Notational shorthand: `FEATURE/` denotes `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`, and `MIRROR/` denotes `extensions/drm-copilot/resources/claude-customizations/.claude/`. All evidence this cycle writes goes under `FEATURE/evidence/<kind>/` (canonical scheme; never `artifacts/`). Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; test-step artifacts carry numeric coverage headline values read from `artifacts/pester/powershell-coverage.xml` (the MCP tool result carries no counts).

**Do-not-do list (restated from remediation-inputs, binding for every task below):**

- Do not change either hook's decision logic, deny-reason strings, or the anomaly fail-closed posture. This cycle is coverage/seam work only.
- Do not reintroduce `$env:CLAUDE_TOOL_INPUT` or `$env:CLAUDE_HOOK_INPUT` in any hook file.
- Do not use the `exit (Invoke-<Name>EntryPoint)` tail form; it captures the emitted JSON into the exit expression and emits nothing.
- Do not spawn child `pwsh` processes or use `Start-Process` in Pester suites.
- Do not add any coverage exclusion or remove any `CodeCoverage.Path` entry.
- Do not touch `.codex/hooks/` or the eight SubagentStop validators.
- Do not weaken, skip, or reorder the toolchain gates.
- Do not widen scope into `spec.md`'s AC-15 or `enforce-prd-feature-before-planner.ps1`'s work-mode awareness — both are already delivered and committed (`d0c472c3`).

### Exact entry-point tail shape (both hooks; naive form is prohibited)

Both hooks must replace their current tail (the block from the dot-source guard through the final `exit 0`, currently at `enforce-powershell-batch-budget.ps1:217-241` and `enforce-python-batch-budget.ps1:214-238`) with a new `Invoke-<Name>EntryPoint` function plus the corrected write-then-exit wiring, matching the precedent at `enforce-epic-merge-gate.ps1:401-452` and `enforce-evidence-locations.ps1:171-223`, adapted to preserve this pair's existing deny-only emission convention (only a deny decision is written to stdout; an allow decision emits nothing):

```powershell
function Invoke-PowerShellBatchBudgetEntryPoint {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string] $ToolInputRaw,

        [scriptblock] $ReadPayload = { Read-ClaudeHookRawPayload }
    )

    if (-not $PSBoundParameters.ContainsKey('ToolInputRaw')) {
        $ToolInputRaw = [string](& $ReadPayload)
    }

    $sessionId = $env:CLAUDE_SESSION_ID
    if (-not $sessionId) {
        $sessionId = 'default'
    }

    $prodCap = 3
    $testCap = 3
    if ($env:CLAUDE_POWERSHELL_BUDGET_PROD -match '^\d+$') {
        $prodCap = [int]$env:CLAUDE_POWERSHELL_BUDGET_PROD
    }
    if ($env:CLAUDE_POWERSHELL_BUDGET_TEST -match '^\d+$') {
        $testCap = [int]$env:CLAUDE_POWERSHELL_BUDGET_TEST
    }

    $decision = Invoke-PowerShellBatchBudgetHook -ToolInputRaw $ToolInputRaw -SessionId $sessionId -ProdCap $prodCap -TestCap $testCap
    if ($decision.hookSpecificOutput.permissionDecision -eq 'deny') {
        $decision.Remove('state')
        $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
    }

    return 0
}

# Guard allows dot-sourcing in tests without executing the entrypoint.
if ($MyInvocation.InvocationName -eq '.') {
    return
}

# The entry point returns its [int] exit code as the last pipeline element and the
# decision JSON before it. `exit (<call>)` would capture BOTH into the exit
# expression and emit nothing, so the decision is written explicitly here first.
$entryPointResult = @(Invoke-PowerShellBatchBudgetEntryPoint)
if ($entryPointResult.Count -gt 1) {
    $entryPointResult[0..($entryPointResult.Count - 2)] | Write-Output
}

exit ([int]$entryPointResult[-1])
```

The Python-named hook uses the identical shape with `Invoke-PythonBatchBudgetEntryPoint`, `Invoke-PythonBatchBudgetHook`, `CLAUDE_PYTHON_BUDGET_PROD`, and `CLAUDE_PYTHON_BUDGET_TEST` substituted throughout. Both files stay pure PowerShell; no Python is introduced.

### Finding-to-task map

| Finding (severity) | Discharged by |
| --- | --- |
| Fix 1 — batch-budget hook coverage regression (Blocking) | P0-T5 (baseline), P1-T1..P1-T7 (implementation), P2-T1..P2-T3 (targeted verification), P5-T3, P5-T5 (final confirmation) |
| Fix 2 — coverage-comparison evidence overstated (Major) | P3-T1, P3-T2 |
| Minor — cited coverage artifact absent from disk | P4-T1 |
| Info — AC-9 mirror-parity pytest transient (`.claude/state/*.json`) | P4-T1 (disposition); standing mitigation already present in P1-T1, P2-T1, P2-T3, P5-T4 |
| Info — PR-context close-candidate noise | P4-T1 (disposition; out of scope for #501) |

### Phase 0 — Policy Reads and Remediation Baseline Capture

- [x] [P0-T1] Read the policy files in this order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/plan-acceptance-gates.md`. Write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:`, and the explicit list of files read. Acceptance: the artifact exists with all required fields.
- [x] [P0-T2] Delete every file matching `.claude/state/powershell-batch-budget.*.json` (the batch-budget hook is live and counts distinct paths session-cumulatively; this cycle's edits must start from a reset counter). Acceptance: `Get-ChildItem .claude/state/powershell-batch-budget.*.json -ErrorAction SilentlyContinue` returns no items.
- [x] [P0-T3] Capture the PowerShell format baseline for this cycle: run `mcp__drm-copilot__run_poshqc_format` and record the result (exit code, count of files changed) in `FEATURE/evidence/remediation-baseline/<ISO-8601>-poshqc-format-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact exists with all four fields and reports zero files changed (clean starting tree).
- [x] [P0-T4] Capture the PowerShell lint baseline for this cycle: run `mcp__drm-copilot__run_poshqc_analyze` and record the finding count in `FEATURE/evidence/remediation-baseline/<ISO-8601>-poshqc-analyze-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact exists with all four fields and reports zero analyzer findings.
- [x] [P0-T5] Capture the pre-fix per-file coverage baseline for the two batch-budget hooks: run `mcp__drm-copilot__run_poshqc_test` (repo Pester config, coverage enabled) and, from the `LINE` missed/covered `sourcefile` counters in `artifacts/pester/powershell-coverage.xml`, record in `FEATURE/evidence/remediation-baseline/<ISO-8601>-batch-budget-hooks-coverage-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`: the repository-wide LINE coverage percentage, and the per-file LINE missed count, covered count, and percentage for `.claude/hooks/enforce-powershell-batch-budget.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1` individually. Acceptance: the artifact exists with all four fields and both hooks' numeric per-file percentages are present (expected starting point: 81.93% each, per `remediation-inputs.2026-08-21T22-23.md`).
- [x] [P0-T6] Capture the mirror-parity baseline: delete every file under `.claude/state/`, then run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts` and record the result in `FEATURE/evidence/remediation-baseline/<ISO-8601>-mirror-parity-baseline.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact exists with all four fields and the named test passed.

### Phase 1 — Entry-Point Seam Implementation (Fix 1)

- [x] [P1-T1] Delete every file matching `.claude/state/powershell-batch-budget.*.json` at the start of this edit batch (2 production files + 2 test files, within the 3+3 per-batch cap). Acceptance: `Get-ChildItem .claude/state/powershell-batch-budget.*.json -ErrorAction SilentlyContinue` returns no items.
- [x] [P1-T2] Edit `.claude/hooks/enforce-powershell-batch-budget.ps1`: replace the tail (dot-source guard through `exit 0`, currently lines 217-241) with `Invoke-PowerShellBatchBudgetEntryPoint` and the corrected write-then-exit wiring shown in the "Exact entry-point tail shape" section above, with names substituted for the PowerShell hook (`Invoke-PowerShellBatchBudgetEntryPoint`, `Invoke-PowerShellBatchBudgetHook`, `CLAUDE_POWERSHELL_BUDGET_PROD`, `CLAUDE_POWERSHELL_BUDGET_TEST`). Do not change `Invoke-PowerShellBatchBudgetHook`, `Invoke-PowerShellBatchBudgetDecision`, `Get-PowerShellBatchBudgetBlockDecision`, `Get-PowerShellBatchBudgetState`, or `ConvertTo-PowerShellBatchBudgetState`. Acceptance: the file contains a function named `Invoke-PowerShellBatchBudgetEntryPoint` with `[OutputType([int])]`, the file's final executable statement is `exit ([int]$entryPointResult[-1])`, the file contains no occurrence of `exit (Invoke-`, and the file is at or under 500 lines (record the exact post-edit line count).
- [x] [P1-T3] Edit `.claude/hooks/enforce-python-batch-budget.ps1`: apply the same tail replacement as P1-T2 with `Invoke-PythonBatchBudgetEntryPoint`, `Invoke-PythonBatchBudgetHook`, `CLAUDE_PYTHON_BUDGET_PROD`, `CLAUDE_PYTHON_BUDGET_TEST` substituted throughout. Do not change `Invoke-PythonBatchBudgetHook`, `Invoke-PythonBatchBudgetDecision`, `Get-PythonBatchBudgetBlockDecision`, `Get-PythonBatchBudgetState`, or `ConvertTo-PythonBatchBudgetState`. Acceptance: the file contains a function named `Invoke-PythonBatchBudgetEntryPoint` with `[OutputType([int])]`, the file's final executable statement is `exit ([int]$entryPointResult[-1])`, the file contains no occurrence of `exit (Invoke-`, and the file is at or under 500 lines (record the exact post-edit line count).
- [x] [P1-T4] Copy both edited hooks byte-identically to their mirrors using a file-copy command: `.claude/hooks/enforce-powershell-batch-budget.ps1` to `MIRROR/hooks/enforce-powershell-batch-budget.ps1`, and `.claude/hooks/enforce-python-batch-budget.ps1` to `MIRROR/hooks/enforce-python-batch-budget.ps1`. Acceptance: `Get-FileHash` reports identical hashes for both source/mirror pairs.
- [x] [P1-T5] Add four seam-driven `It` blocks to `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` exercising `Invoke-PowerShellBatchBudgetEntryPoint` directly (no child processes, no real filesystem writes): (a) a well-formed nested envelope naming a non-PowerShell file (for example `README.md`) returns an emitted-output array of length 1 whose single element, cast to `[int]`, is `0` (allow, no decision written); (b) `-ToolInputRaw ''` (empty-payload anomaly) returns exit code `0` and an emitted deny decision whose parsed JSON has no `state` property; (c) omitting `-ToolInputRaw` and supplying `-ReadPayload { '' }` returns exit code `0` and an emitted deny decision (proves the `ReadPayload` seam is consulted when `ToolInputRaw` is not bound); (d) with `$env:CLAUDE_SESSION_ID`, `$env:CLAUDE_POWERSHELL_BUDGET_PROD`, and `$env:CLAUDE_POWERSHELL_BUDGET_TEST` set to non-default values, `-ToolInputRaw '{not-json'` (malformed-JSON anomaly) returns exit code `0`. None of the four scenarios reach the hook's file-write path, so none creates a real file under `.claude/state/`. Then run `mcp__drm-copilot__run_poshqc_test` scoped to this suite. Acceptance: the suite passes, and the file is at or under 500 lines (record the exact post-edit line count).
- [x] [P1-T6] Add the same four seam-driven `It` blocks (Python-named equivalents) to `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` exercising `Invoke-PythonBatchBudgetEntryPoint`, substituting `docs/readme.md`/`src/app.py`-style paths and `CLAUDE_PYTHON_BUDGET_PROD`/`CLAUDE_PYTHON_BUDGET_TEST` for the env-var scenario. Then run `mcp__drm-copilot__run_poshqc_test` scoped to this suite. Acceptance: the suite passes, and the file is at or under 500 lines (record the exact post-edit line count).
- [x] [P1-T7] Run `Invoke-Pester -Path tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` (the AC-8 structural guard) to confirm neither edited hook reintroduced `$env:CLAUDE_TOOL_INPUT` or `$env:CLAUDE_HOOK_INPUT` and that both still call `Read-ClaudeHookRawPayload` through the shared module. Record the result in `FEATURE/evidence/qa-gates/<ISO-8601>-payload-contract-regression-check.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the suite passes with 0 failures.

### Phase 2 — Coverage and Regression Verification (Fix 1 closeout)

- [x] [P2-T1] Delete every file under `.claude/state/`, then run `mcp__drm-copilot__run_poshqc_test` (repo Pester config, coverage enabled). From the `LINE` missed/covered `sourcefile` counters in `artifacts/pester/powershell-coverage.xml`, record in `FEATURE/evidence/qa-gates/<ISO-8601>-batch-budget-hooks-coverage-postfix.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`: the repository-wide LINE coverage percentage, and the per-file LINE missed count, covered count, and percentage for both hooks, plus the delta against the P0-T5 baseline figures. Acceptance: both hooks individually report LINE coverage >= 85%, and the repository-wide LINE coverage percentage is not lower than the P0-T5 baseline.
- [x] [P2-T2] Compute the changed-line regression check: run `git diff -U0 fb30a9a5..HEAD -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1` to obtain the changed-line set for both files, and intersect it against the P2-T1 missed-line set for the same two files. Record the command, both line sets, and the intersection in `FEATURE/evidence/qa-gates/<ISO-8601>-batch-budget-changed-line-regression.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the intersection is empty for both files.
- [x] [P2-T3] Delete every file under `.claude/state/`, then run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Record the result in `FEATURE/evidence/qa-gates/<ISO-8601>-mirror-parity-postfix.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the named test passes with exit code 0.

### Phase 3 — Coverage-Comparison Evidence Correction (Fix 2)

- [x] [P3-T1] Create a new artifact `FEATURE/evidence/qa-gates/<ISO-8601>-coverage-comparison-correction.md` (do not edit `evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md`). The new artifact must: (a) name the superseded claim and its source (`evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md`'s "there is no regression on changed lines" statement, derived only from the nine newly-registered denominator files); (b) cite the falsifying measurement (`policy-audit.2026-08-21T22-23.md` section 5: `enforce-powershell-batch-budget.ps1` and `enforce-python-batch-budget.ps1` each regressed 96.30% -> 81.93%); (c) present a single corrected per-changed-file LINE coverage table covering all 27 changed production files from the original feature — reusing the 25 already-passing figures from `policy-audit.2026-08-21T22-23.md` section 5 verbatim and substituting this cycle's P2-T1 post-fix figures for the two batch-budget hooks; (d) state the corrected verdict: no regression on changed lines, verified by intersecting `git diff -U0 fb30a9a5..HEAD` changed lines against the missed-line set for every changed production file, not only the nine newly-registered ones, citing `evidence/qa-gates/<ISO-8601>-batch-budget-changed-line-regression.md` (P2-T2) as the evidence for the two hooks this cycle re-examined. Acceptance: the artifact exists, contains all four elements (a)-(d), and every row in its table shows LINE coverage >= 85%.
- [x] [P3-T2] Verify the original evidence artifact was not modified: run `git status --porcelain -- "docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md"` and record the output in `FEATURE/evidence/qa-gates/<ISO-8601>-original-evidence-untouched-check.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the command's output is empty (no pending changes to that file).

### Phase 4 — Minor and Info Findings Disposition

- [x] [P4-T1] Write `FEATURE/evidence/other/<ISO-8601>-minor-info-findings-disposition.md` recording an explicit disposition for each of the three remaining review findings, with `Timestamp:` and one named section per finding: (1) **Minor — cited coverage artifact absent from disk** (`artifacts/pester/powershell-coverage.repo-runsettings.xml`, cited by the executor's original [P7-T3] evidence but not present at review time): disposition is no code change; state that `artifacts/` is gitignored ephemeral working state, and that the reviewer's independently regenerated run (`artifacts/pester/powershell-coverage.review-repo-runsettings.xml`) reproduced the same root counters byte-exactly, per `policy-audit.2026-08-21T22-23.md` section 5 and the Findings Table Minor row of `code-review.2026-08-21T22-23.md`. (2) **Info — AC-9 mirror-parity pytest transient** (untracked, gitignored `.claude/state/*.json` runtime files failing the bundle-parity filesystem walk): disposition is no code change; state that this cycle's tasks (P1-T1, P2-T1, P2-T3, P5-T4) already delete `.claude/state/` contents immediately before every mirror-parity run as the standing mitigation, matching the executor's and reviewer's own documented workaround. (3) **Info — PR-context close-candidate noise** (`artifacts/pr_context.summary.txt` listing `#AC-1`..`#AC-14`, `#ISO-8601`, `#SHA-256` as author-asserted autoclose issues): disposition is no code change; this is pre-existing `pr_context` generator behavior, out of scope for #501, and the PR author must assert only `#501` for autoclose. Acceptance: the artifact exists and contains all three named sections with an explicit disposition statement in each.

### Phase 5 — Final QA Loop (Unconditional)

Run the full PowerShell toolchain loop in order (format -> analyze -> test; type checking is not applicable to PowerShell). If any step fails or changes files, fix, re-copy any reformatted `.claude/hooks/` file to `MIRROR/hooks/`, delete every file under `.claude/state/`, and restart the loop from P5-T1 until a single clean pass completes. Every task below is unconditional; no `SKIPPED` outcome is authorized.

- [x] [P5-T1] Run `mcp__drm-copilot__run_poshqc_format`. Record the result in `FEATURE/evidence/qa-gates/<ISO-8601>-poshqc-format-final.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the format stage modifies zero files in the final clean pass.
- [x] [P5-T2] Run `mcp__drm-copilot__run_poshqc_analyze`. Record the result in `FEATURE/evidence/qa-gates/<ISO-8601>-poshqc-analyze-final.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: zero analyzer findings.
- [x] [P5-T3] Run `mcp__drm-copilot__run_poshqc_test` (repo Pester config, coverage enabled). Record pass/fail counts and, from `artifacts/pester/powershell-coverage.xml`, the numeric repository-wide LINE coverage percentage and the per-file LINE coverage percentage for both batch-budget hooks in `FEATURE/evidence/qa-gates/<ISO-8601>-poshqc-test-final.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: all suites pass with 0 failures, repository-wide LINE coverage >= 85%, and both batch-budget hooks individually >= 85%.
- [x] [P5-T4] Delete every file under `.claude/state/`, then run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Record the result in `FEATURE/evidence/qa-gates/<ISO-8601>-mirror-parity-final.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the named test passes with exit code 0.
- [x] [P5-T5] Re-run the changed-line regression check from P2-T2 against the final P5-T3 coverage report: `git diff -U0 fb30a9a5..HEAD -- .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-python-batch-budget.ps1` intersected with the final missed-line set. Record in `FEATURE/evidence/qa-gates/<ISO-8601>-batch-budget-changed-line-regression-final.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the intersection is empty for both files.
- [x] [P5-T6] Run `Get-ChildItem .claude/hooks/enforce-powershell-batch-budget.ps1, .claude/hooks/enforce-python-batch-budget.ps1, tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1, tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | ForEach-Object { [pscustomobject]@{ Name = $_.Name; Lines = (Get-Content $_.FullName).Count } } | Where-Object Lines -gt 500` and record the result, including the actual line count of each of the four files, in `FEATURE/evidence/qa-gates/<ISO-8601>-file-size-ceiling-final.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the command returns no rows.

## Cycle Exit Criteria

This cycle closes when a re-audit finds zero Blocking findings: both `enforce-powershell-batch-budget.ps1` and `enforce-python-batch-budget.ps1` at or above their 96.30% baseline per-file LINE coverage (or, at minimum, every changed line covered with no changed line regressed, both above the 85% floor); the coverage-comparison evidence record corrected per Phase 3; the Minor and two Info findings explicitly disposed of per Phase 4; and a single clean pass of the full toolchain loop in Phase 5 with no `SKIPPED` step.
