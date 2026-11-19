# Final QA Loop Remediation 1 (P3-T2)

Timestamp: 2026-11-19T11-01
Command: sh SCRATCH/issue-1050-p1t3.sh (copy of the edited script to scripts/ci and the bundle, cmp); sh SCRATCH/issue-1050-static.sh pwsh scripts/ci extensions/drm-copilot/resources/ci-workflows tests/scripts/ci; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1
EXIT_CODE: 0
Output Summary: Trigger: the first final Pester gate (29234 tests, 0 failures) reported repo-wide line coverage 96.76% (47230/48811) against the 96.77% (47184/48759) `Phase 0 baseline`, because the new `scripts/ci/Set-CiRequiredChecks.ps1` entered at 88.46% (46/52). Fix: six uncovered lines reduced to one. After the fix: format drift 0 and analyzer findings 0 over 24 files; bundle copy byte-identical; selection run 25 passed, 0 failed; `scripts/ci/Set-CiRequiredChecks.ps1` 98.08% (51/52; the remaining line is the `-DataFilePath` parameter default, which coverage does not trace). The final loop restarts from P3-T1.

## Uncovered Lines Before the Fix

| Line | Content | Disposition |
| --- | --- | --- |
| 34 | `-DataFilePath` default (`Join-Path ... $PSScriptRoot`) | remains uncovered (parameter default evaluation is not traced) |
| 53-58 | `Invoke-GhExe` body | covered: the wrapper gains `-GhCommand` (default `gh`), an injectable delegate seam as `.claude/rules/powershell.md` allows when a wrapper alone is insufficient; the tests pass a local test-double function, so no process starts and `gh` itself is never mocked |
| 185 | guarded `Invoke-SetCiRequiredChecks` call | covered: a direct-run test invokes the script with no data file beside it, which throws `CI data file not found` before any gh call |

## Iterations

1. The first test-double version bound the first gh argument positionally to its pipeline parameter (2 of 25 failed); the double now declares `[CmdletBinding(PositionalBinding = $false)]` and its arguments carry no leading dash.
2. Analyzer `PSUseOutputTypeCorrectly` (2 findings) on the test double; resolved with `[OutputType([string])]`.

Changed files: `scripts/ci/Set-CiRequiredChecks.ps1`, `extensions/drm-copilot/resources/ci-workflows/Set-CiRequiredChecks.ps1` (byte copy), `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`. The superseded first-pass Pester gate is not recorded as `final-pester`; only the restarted loop's runs are.
