# Task check - P1-T4

Timestamp: 2026-11-17T22-23
Changed files:
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: one guarded dot-source of enforce-orchestration-preimplementation-gate-release.ps1 after the parallel-records line, one leg line immediately before the final deny, and `+ $release.DenySuffix` as the last term of the final deny (493 -> 495 lines); bundle copy byte-identical (SHA256 prefix d6647a4963b1da66 for both).
- .codex/hooks/enforce-orchestration-preimplementation-gate.ps1: the same three edits, the dot-source after the docs line (485 -> 487 lines, at or under 500); bundle copy byte-identical (SHA256 prefix 8e3af15665e4f4f0 for both).
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1 and tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1 (test-only fix to the P1-T3 container-probe mock, see command 3).
Selection rule: every test file under tests/ that names enforce-orchestration-preimplementation-gate (86 files, found by a text search of *.Tests.ps1) plus tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 and tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (88 files; legacy-codex-hook-contracts.Tests.ps1 is in the set). The list is kept as SCRATCH/issue-1201-sel-p1t4.txt.

Commands:
1. Command: sh SCRATCH/issue-1201-ps-static.sh .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
   EXIT_CODE: 0
   Output Summary: format drift 0, PSScriptAnalyzer findings 0; Claude gate 495 lines, Codex gate 487 lines.
2. Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <the 88 selected files>
   EXIT_CODE: 1
   Output Summary: the only failures were the two AC12-directory-entry rows (Claude and Codex): the test's container-probe mock used GetNewClosure, which hides the mock's bound RelativePath, so the probe never reported a directory. Every other test of the 88 files passed (no failure outside the release-allowance rows; 200 of 202 release-allowance rows passed), including every existing preimplementation-gate suite, the dependency-guard completeness suite, the Codex line-limit suites, and the discovery guard.
3. Command: sh SCRATCH/issue-1201-ps-static.sh <the two decision suites>, then sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ReleaseAllowance.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-release-allowance.Tests.ps1
   EXIT_CODE: 0 (static 0 findings; one earlier attempt exited 75 because another worktree held the machine test-suite lock, recorded as a queue timeout)
   Output Summary: the container mock now reads a script-scope value without a closure. 204 tests, 204 passed, 0 failed: all 101 rows on each surface plus both interception probes, which turns every P1-T3 expected failure into a pass.
