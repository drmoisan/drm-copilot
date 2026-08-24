# Baseline — PowerShell Tests and Coverage (PoshQC / Pester 5) — Issue #475

Timestamp: 2026-08-15T19-16

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afc9f4fd25ec235a5`, default scan set from `config/poshqc-scan.json` (`scripts`, `tests/powershell`, `tests/scripts`), using the repo config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

Coverage values below were read from `artifacts/pester/powershell-coverage.xml` (and its converted sibling `artifacts/pester/powershell-coverage.koverage.xml`, which carries repo-relative `sourcefile` names), not inferred from the exit code. Per the plan's binding coverage-evidence rule, `CoveragePercentTarget = 0` in `pester.runsettings.psd1:148`, so PoshQC does not fail on coverage and a zero exit code is not coverage evidence.

EXIT_CODE: 0

Output Summary:

**Test results** (from `artifacts/pester/powershell-coverage.xml`'s sibling `artifacts/pester/pester-junit.xml`, root `<testsuites>` element):
- Total tests: 2233
- Failures: 0
- Errors: 0
- Disabled/skipped: 9
- Wall time: 102.705 s

**Line coverage (report-level, from the `LINE` counter on the `<report>` root):**
- Covered: 4019
- Missed: 218
- Total: 4237
- **Line coverage: 94.85%** (floor 85% — met, headroom 9.85 points)

**Instruction coverage (report-level `INSTRUCTION` counter, recorded as the closest available second dimension):**
- Covered: 5457, Missed: 320, Total: 5777
- Instruction coverage: 94.46%

**Branch coverage: NOT EMITTED by this toolchain.**
This is an instrument limitation, recorded factually rather than estimated. Verification performed:
- `grep -c 'counter type="BRANCH"'` over `artifacts/pester/powershell-coverage.xml` returns 0; no `BRANCH` counter element exists at report, package, class, or sourcefile level.
- The JaCoCo `<line>` elements carry `mb` (missed branches) and `cb` (covered branches) attributes, but summing them across every `<line>` node in the report yields `mb = 0, cb = 0` (total 0), i.e. Pester 5's JaCoCo exporter populates command/line hit data only and never records branch arcs.
- The converted `artifacts/pester/powershell-coverage.koverage.xml` contains no `BRANCH` token either.

Consequence for this plan: the 75% branch-coverage floor cannot be measured from this repository's PowerShell instrument. Every downstream coverage-bearing task in this plan therefore reports the numeric **line** coverage read from the coverage XML against the 85% floor, and records branch coverage as not emitted with this artifact as the basis. No threshold is relaxed and no check is dropped; the branch figure is unavailable at the instrument level, not waived.

## Per-File Baselines for Files This Plan Will Modify

Captured now so the no-regression-on-changed-lines rule can be evaluated against a recorded reference. Read from `powershell-coverage.koverage.xml` `<sourcefile>` `LINE` counters.

| File | Covered | Missed | Line % |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 48 | 7 | 87.27% |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 51 | 7 | 87.93% |
| `.claude/hooks/validate-orchestrator-output.ps1` | 94 | 8 | 92.16% |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 103 | 3 | 97.17% |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | 50 | 0 | 100% |
| `.claude/lib/model-routing/ModelRouting.psm1` | 46 | 0 | 100% |

Note carried from the plan's Hard Constraints: removing the Python probe and the Python leg from `OrchestratorState.psm1` removes currently-covered lines, so that file's percentage may tick down from 97.17%. The 85% line floor still applies; an increase is not required there.
