# Remediation Inputs — feature review 2026-08-21T22-23 (#501)

- **Cycle trigger:** one Blocking finding in `policy-audit.2026-08-21T22-23.md` (coverage regression on two modified hooks).
- **Produced by:** feature-review agent, initial review of `bug/pretooluse-hooks-parse-flat-payload-501 @ 6a8d59f3` vs `main @ fb30a9a5`.
- **Audit artifacts:**
  - `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/policy-audit.2026-08-21T22-23.md` (section 5, Blocking finding)
  - `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/code-review.2026-08-21T22-23.md` (Findings Table, Blocker row)
  - `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/feature-audit.2026-08-21T22-23.md` (all 14 ACs PASS; readiness NEEDS REVISION on the policy finding)
- **Handoff:** per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the orchestrator authors the cycle's `remediation/<entry-ts>/remediation-inputs.md` from this document and delegates plan authoring to `atomic-planner`. This reviewer produces findings, not the plan.

## Blocking finding to remediate

### Fix 1 — restore tail coverage in the two batch-budget hooks (Blocking)

- **Files:**
  - `.claude/hooks/enforce-powershell-batch-budget.ps1` (and mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`)
  - `.claude/hooks/enforce-python-batch-budget.ps1` (and mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`)
  - `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`
- **Defect:** per-file line coverage regressed from 96.30% (merge-base) to 81.93% because the migrated suites removed the baseline in-process full-file execution (`$result = & $script:ScriptPath | ConvertFrom-Json`) that covered the script tail, and these two hooks were not given the `Invoke-<Name>EntryPoint` seam the other eight converted hooks received. The uncovered region is the entire tail below the dot-source guard (lines 217-241 / 214-238). One changed line per file regressed from covered to uncovered: `enforce-powershell-batch-budget.ps1:235` and `enforce-python-batch-budget.ps1:232` (the `$decision = Invoke-<Name>BatchBudgetHook -ToolInputRaw (Read-ClaudeHookRawPayload) ...` tail statement).
- **Expected behavior after fix:**
  - Each hook exposes an entry-point function (pattern precedent: `Invoke-EpicMergeGateEntryPoint` in `.claude/hooks/enforce-epic-merge-gate.ps1`) that accepts an optional `-ToolInputRaw` and a `-ReadPayload` scriptblock seam, performs the session-id/cap resolution and decision emission currently inlined in the tail, and returns the `[int]` exit code; the file tail reduces to the corrected write-then-exit form (emit all but the last pipeline element, `exit ([int]$entryPointResult[-1])`). Do NOT use the bare `exit (Invoke-...)` form — it swallows the emitted JSON (see spec `Executed Outcome and Deviations` item 1).
  - Runtime behavior is unchanged: same decision JSON, same deny-only emission convention for these hooks, exit 0.
  - Each suite gains seam-driven tests covering the entry point (env-cap resolution, deny emission path, allow path, anomaly path), restoring tail coverage without child processes or live stdin reads.
  - Per-file line coverage >= 85% for both hooks; the changed tail lines covered; no regression elsewhere; both hooks stay under 500 lines; mirrors stay byte-identical; `PreToolUsePayload.Contract.Tests.ps1` still passes (the seam must acquire the payload through `Read-ClaudeHookRawPayload` and must not reintroduce either retired env literal).
- **Verification commands:**
  - Full suite: `mcp__drm-copilot__run_poshqc_format` -> `mcp__drm-copilot__run_poshqc_analyze` -> `mcp__drm-copilot__run_poshqc_test` (single sequential clean pass).
  - Repository-denominator coverage: run `Invoke-Pester` with a `PesterConfiguration` built from `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (JaCoCo output) and assert LINE coverage >= 85% per file for both hooks from the report's `sourcefile` counters (reviewer precedent: `artifacts/pester/powershell-coverage.review-repo-runsettings.xml`, which shows the current 68/83 = 81.93% failure state; the fixed state must show >= 85%).
  - Changed-line check: intersect `git diff -U0 main...HEAD` post-fix changed lines for the two hooks with the JaCoCo missed-line set; the intersection must be empty for the tail acquisition statements.
  - Mirror parity: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -k test_bundled_claude_payload_contains_all_repo_runtime_contracts` (delete any stray gitignored `.claude/state/*.json` runtime files first — they are recreated by live hook activity and fail the filesystem walk).

### Fix 2 — correct the coverage-comparison evidence record (Major, ride-along)

- **File:** `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/evidence/qa-gates/` (new artifact; do not rewrite the existing timestamped record).
- **Defect:** `2026-08-22T00-50-coverage-comparison.md` asserts "there is no regression on changed lines" from the nine newly registered files alone; the assertion is falsified for the two batch-budget hooks.
- **Expected behavior:** the remediation cycle's coverage evidence artifact supersedes the claim with a per-changed-file measurement (all 27 changed production files), citing the fixed figures.

## Do-not-do list

- Do not change any hook's decision logic, deny-reason strings, or the anomaly fail-closed posture; this cycle is coverage/seam work only.
- Do not reintroduce `$env:CLAUDE_TOOL_INPUT` or `$env:CLAUDE_HOOK_INPUT` in any hook file (the AC-8 contract suite will fail).
- Do not use the `exit (Invoke-<Name>EntryPoint)` tail form; use the corrected write-then-exit tail.
- Do not spawn child `pwsh` processes or use `Start-Process` in Pester suites (test-purity guard).
- Do not add any coverage exclusion or remove any `CodeCoverage.Path` entry.
- Do not touch `.codex/hooks/` or the eight SubagentStop validators (AC-13 boundary).
- Do not weaken, skip, or reorder the toolchain gates; a full single-pass clean run is required at cycle exit.
- No scope creep: the SubagentStop defect is already filed separately (`docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md`) and must not be absorbed into this cycle.

## Reference measurements (fail-before state for the remediation's discriminating checks)

| File | Baseline (merge-base) | Current (head) | Required after fix |
|---|---|---|---|
| `enforce-powershell-batch-budget.ps1` | 96.30% (78/81) | 81.93% (68/83), missed 158, 221-241 | >= 85%, tail acquisition line covered |
| `enforce-python-batch-budget.ps1` | 96.30% (78/81) | 81.93% (68/83), missed 155, 218-238 | >= 85%, tail acquisition line covered |
| Repo-wide (repository denominator) | 96.2126% (5792/6020) | 95.8226% (6308/6583) | >= 85% (already met; must not fall) |
