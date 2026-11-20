# PowerShell QA Gate (Issue #305)

Timestamp: 2026-07-04T13-50

## Format

Command: `mcp__drm-copilot__run_poshqc_format` scoped to `.claude/hooks`, `tests/scripts/claude-hooks`
EXIT_CODE: 0
Output Summary: Ran clean; `git status` showed no format drift outside the intentionally edited/new
files (`enforce-model-routing-receipt.ps1`, `validate-orchestrator-output.ps1`, and the two hook test
files). No loop restart required.

## Analyze

Command: `mcp__drm-copilot__run_poshqc_analyze` scoped to `.claude/hooks`, `tests/scripts/claude-hooks`
EXIT_CODE: 0
Output Summary: ok=true, no PSScriptAnalyzer findings.

## Test (Pester)

Command: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks`
EXIT_CODE: 0
Output Summary: JUnit results (`artifacts/pester/pester-junit.xml`): tests=495, errors=0, failures=0
(baseline was 478; +17 new: 11 for `enforce-model-routing-receipt.Tests.ps1` and 6 across
`validate-orchestrator-output` files, including the sibling `...model-routing.Tests.ps1`).

## Coverage (changed hooks)

Pester v5 code coverage is command-based (line-equivalent); a separate branch-rate is not emitted by
the CoverageGutters/JaCoCo output, so command/line coverage is reported here.

- `.claude/hooks/enforce-model-routing-receipt.ps1` (NEW): 42/49 commands = 85.7% (>= 85%). The only
  uncovered lines are the dot-source-guarded host-bound entrypoint (`try { Invoke... } catch { ... }`
  and `$decision | ConvertTo-Json | Write-Output; exit 0`, lines 173-182), which cannot execute under
  dot-source testing. This is the thin host-bound wiring acknowledged by the coverage-exclusion policy
  in `.claude/rules/general-unit-test.md`. The file was added to the workspace Pester coverage config
  (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) so it is measured by CI and not
  excluded.
- `.claude/hooks/validate-orchestrator-output.ps1` (edited): 82/94 lines = 87.2% (JaCoCo LINE),
  150/168 instructions = 89.3%.
- Aggregate across both changed hooks: 192/217 commands = 88.5%.

All changed-hook decision branches (allow/deny paths, MODEL_ROUTING_BLOCKED vs ROUTING_CONTRACT_BLOCKED
branch, presence/absence of receipts) are exercised by the new and existing tests.
