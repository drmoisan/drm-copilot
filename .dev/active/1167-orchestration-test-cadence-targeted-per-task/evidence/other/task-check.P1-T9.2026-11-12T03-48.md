# Task Check [P1-T9] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T03-48
Command: sh SCRATCH/issue-1167-psstatic.sh tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 (Invoke-Formatter check, Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1, Invoke-PoshQCLeakScan); bash SCRATCH/issue-1167-taskcheck.sh p1t9 (New-PesterConfiguration with Run.Path = the selected files, Run.Exit = $true)
EXIT_CODE: 0
Output Summary:
- Scoped format check: 1 file, drift 0; PSScriptAnalyzer: 0 findings (a first pass reported 1 PSUseOutputTypeCorrectly finding in Get-TcwFileLine, fixed by returning the split lines without the unary comma); leak scan: 742 files, 0 failures; git status --porcelain unchanged across the format step.
- Pester selection: 3 files, 196 passed, 0 failed (PESTER_EXIT=0). test-cadence-wording.Tests.ps1 alone: 135 rows passed (122 TCW wording rows, 6 TCW-TEMPLATE rows, 5 TCW-BUNDLE rows, TCW-SWEEP-SURFACES, TCW-SWEEP-HELPER).
- tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1: unchanged against HEAD (git diff --quiet HEAD) and passing (AC2).
- Falsifiability probe (debugging only, not evidence of a gate): ten bundle copies were set to their HEAD text in place, the file was run (121 passed, 14 failed: TCW-CANONICAL-CLAUDE-BUNDLE, TCW-CANONICAL-REF-CLAUDE-BUNDLE, TCW-REMEDIATION-CLAUDE-BUNDLE, TCW-DELEGATION-CLAUDE-BUNDLE, TCW-EXECUTOR-CODEX-C2-BUNDLE, TCW-EXECUTOR-COPILOT-PY-BUNDLE, TCW-PLANNER-CODEX-C4-BUNDLE, TCW-RULE-CLAUDE-PYTHON-BUNDLE, TCW-QAGATE-CLAUDE-PYTHON-BUNDLE, TCW-PROMPT-EXECUTE-BUNDLE, TCW-BRIEF-GITHUB-BUNDLE, TCW-TEMPLATE-BUG-BUNDLE, TCW-BUNDLE-EXECUTE, TCW-SWEEP-SURFACES), and the ten files were restored byte-for-byte from SCRATCH copies.
- File size: 499 lines (under the 500-line guidance).

Changed files:
- tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 (new)

Selection rule: the new test file, parallel-gate-wording.Tests.ps1 (required unchanged and passing by the plan), and test-name-uniqueness.Tests.ps1, which parses every test file under tests/.
