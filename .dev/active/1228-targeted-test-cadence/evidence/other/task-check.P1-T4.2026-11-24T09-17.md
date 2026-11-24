# Task Check - [P1-T4] - Issue #1228, remediation cycle 1

Timestamp: 2026-11-24T09-17
Plan: remediation-plan.2026-11-24T07-15.md
Kind: task check (not a gate; no coverage measured; not coverage evidence)
Command: Edit-tool edits of `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`; `sh <item worktree>/artifacts/issue-1228/c1fmt.sh` (`Invoke-PoshQCFormat -Root <worktree root> -ScanFolders tests/scripts/claude-runtime` with a capturing logger, and `git hash-object` of the test file before and after); `sh <item worktree>/artifacts/issue-1228/c1tc.sh p1t4 tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`, which runs `Invoke-Formatter` and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` on the file and then `sh <item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` (through the exit-75 retry wrapper)
EXIT_CODE: 0
Output Summary:
- Changed file: `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1`.
- Rows: the `REVIEW` check (now `$script:ReviewCheck`) adds the required tokens `supplies per-file figures only` and `a full-suite final-QC artifact` and the forbidden token `local artifact that shows the`; new group `REVIEW-AGENT` over `.claude/agents/feature-review.md` and `.codex/agents/feature-review.toml` with their bundles (`## Coverage Verification`: five required tokens; forbidden `does NOT rerun coverage generation`, `rather than rerunning coverage generation`, `local artifact that shows the`); new group `REVIEW-TEMPLATE` over `.dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` and `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` (explicit paths, no derived bundle; `#### 4A.1 Framework and Scope`); new `TCW-COVERAGE-SOURCE-DISCRIMINATES`, which applies the [P1-T1] delta and shortcut checks and the three [P1-T4] checks to in-memory lines holding each removed sentence under its heading and asserts that each of the 5 distinct forbidden tokens is reported.
- Format: `Invoke-PoshQCFormat` visited 46 files under `tests/scripts/claude-runtime`, 0 `Formatted:` lines; the test file hash is unchanged (`6295f045b84ceb294d85b0405a1d6bdcac1db289` before and after). `Invoke-Formatter` drift 0.
- Lint: PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, 0 findings.
- Logical line count: 688 (below 700).
- Selection and rule: this file and `parallel-gate-wording.Tests.ps1` (the [P1-T4] task text); `PGW-SWEEP-*` token list and count unchanged. Known-failing window: `ProcessReductionChain.Ledger.Tests.ps1` excluded until [P1-T5].
- Pester: EXIT_CODE 0; JUnit 293 tests, 0 failed, 0 skipped; 193 `TCW-` tests, 0 failed; `TCW-QAGATE` and `TCW-REVIEW-` tests 24, 0 failed (8 of them `TCW-REVIEW-AGENT-*` and `TCW-REVIEW-TEMPLATE-*`); `TCW-COVERAGE-SOURCE-DISCRIMINATES` 1 passed (forbidden-token count 5); `PGW-SWEEP` 2 passed. 21 attempts exited 75 (queue timeout; the lock was held by Pester suites of other worktrees) before attempt 22 passed.
- Result: PASS.
