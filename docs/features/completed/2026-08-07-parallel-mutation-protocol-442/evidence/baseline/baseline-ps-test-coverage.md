# Baseline — PowerShell Pester Tests and Coverage (P0-T6)

Timestamp: 2026-08-08T21-38

Task: [P0-T6] Capture PowerShell Pester test + coverage baseline with numeric coverage values.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
HEAD at capture time: `c939b5b80c8c297db49febaebdd35dda2c869a3f`

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`
(no `scan_folders` argument, so the scan set resolves from `config/poshqc-scan.json` `test.scanFolders`)

EXIT_CODE: 1

The non-zero exit code is caused entirely by ONE pre-existing, out-of-scope test failure that also
fails identically at baseline before any F6 edit. It is characterized in full below. Pester
5.6.1; run recorded `Pester (08/08/2026 21:31:57)`; wall time 113.834 s.

## Raw MCP Output

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c",
  "summary": "Command exited with code 1."
}
```

The MCP wrapper prints no counts, so the numeric values below were read from the two result files the
run itself wrote: `artifacts/pester/pester-junit.xml` (JUnit results) and
`artifacts/pester/powershell-coverage.xml` (JaCoCo-format coverage). Both are the existing PoshQC
tool output locations, not evidence paths; no evidence artifact for this feature is written under
`artifacts/`.

## Test Result Counts (numeric, no placeholders)

Root JUnit element:

```xml
<testsuites name="Pester" tests="2031" errors="0" failures="1" disabled="9" time="113.834">
```

Counts cross-checked by direct tally of `<testcase>` status attributes:

| Metric | Baseline value | Verification |
| --- | --- | --- |
| Total test cases | 2031 | `grep -c "<testcase"` = 2031, matches `tests="2031"` |
| Passed | **2021** | `grep -c 'status="Passed"'` = 2021 |
| Failed | **1** | `grep -c 'status="Failed"'` = 1, matches `failures="1"` |
| Errors | 0 | `errors="0"` |
| Skipped / disabled | 9 | `grep -c 'status="Skipped"'` = 9, matches `disabled="9"` |
| Wall time | 113.834 s | `time="113.834"` |

2021 + 1 + 9 = 2031, so the tally reconciles exactly with the root element.

## Coverage — Numeric Baseline Values (no placeholders)

Report-level counters from `artifacts/pester/powershell-coverage.xml`:

```xml
  <counter type="INSTRUCTION" missed="278" covered="4316" />
  <counter type="LINE" missed="189" covered="3148" />
  <counter type="METHOD" missed="26" covered="240" />
  <counter type="CLASS" missed="2" covered="39" />
```

| Coverage metric | Baseline numeric value | Threshold | Baseline verdict |
| --- | --- | --- | --- |
| **Line coverage** | **94.34%** (3148 covered / 3337 total lines; 189 missed) | >= 85% | PASS, margin +9.34 pp |
| Instruction coverage | 93.95% (4316 covered / 4594; 278 missed) | not a policy threshold | recorded for comparison |
| Method coverage | 90.23% (240 covered / 266; 26 missed) | not a policy threshold | recorded for comparison |
| Class coverage | 95.12% (39 covered / 41; 2 missed) | not a policy threshold | recorded for comparison |

Line-coverage arithmetic: `3148 / (3148 + 189) = 3148 / 3337 = 94.34%`.

Pester's JaCoCo output carries no `BRANCH` counter, so a branch-coverage figure is not produced by
this toolchain for PowerShell. The policy branch threshold is measurable for Python only; for
PowerShell the line-coverage figure above is the recorded coverage headline, consistent with the
plan's P0-T6 and P7-T7 wording, which require the numeric LINE coverage percentage for Pester.

`.claude/hooks/enforce-parallel-abandon-gate.ps1` (the hook created by P5-T1) does not exist at
baseline, so its baseline coverage is NOT APPLICABLE (file absent), not zero. P7-T7 records its
post-change coverage.

## Pre-Existing Failures — PRE-EXISTING and OUT OF SCOPE

### Failure 1 (the only failing test in this run)

- Test file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Suite result: `tests="46" errors="0" failures="1" skipped="0" disabled="0"` (45 of 46 pass)
- Failing test: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: `enforce-pr-author-skill.Tests.ps1:142` — `$decision.hookSpecificOutput.permissionDecision | Should -Be 'allow'`
- Failure message: `Expected strings to be the same, but they were different. Expected length: 5, Actual length: 4, Strings differ at index 0. Expected: 'allow' But was: 'deny'`

Cause and scope: this test reads the real, gitignored
`artifacts/orchestration/orchestrator-state.json` rather than a mocked read seam. An orchestrated run
is live and that checkpoint has been written by the orchestrator, so the hook under test correctly
returns `deny` where the test's fixture-free expectation assumes `allow`. The defect is in the test's
missing seam, not in the hook and not in anything F6 touches.

Classification: **PRE-EXISTING and OUT OF SCOPE.** It fails identically at baseline, before any F6
edit. Per the execution directive this test file is NOT edited to force a green gate, and it does not
block progress. F6 creates no file that this test loads and modifies no `enforce-*` hook it exercises.

### Failure 2 as predicted — did NOT manifest in this run (recorded for accuracy)

The execution directive anticipated a second pre-existing failure in
`codex-pretooluse-integration.Tests.ps1`. That file **passed** in this baseline run and is recorded
here so the baseline is not overstated:

- Actual path: `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (under
  `codex-hooks/`, not `claude-hooks/` as the directive stated)
- Suite result: `tests="6" errors="0" failures="0" skipped="0" disabled="0"` — all 6 pass

This file shares the same live-checkpoint sensitivity as Failure 1, so it may fail in a later run
depending on the state of `artifacts/orchestration/orchestrator-state.json` at that moment. If it
fails in Phase 5 or Phase 7 it is to be treated as the same pre-existing, out-of-scope condition and
not as an F6 regression. It is recorded as PASSING at baseline.

### Expected-failure budget for later phases

Any Pester failure in P5-T5 or P7-T7 beyond the two files named above is a GENUINE finding
attributable to this feature and must be fixed, not waived. The precise baseline discriminator is:

- baseline failing test count: **1**
- baseline failing test identity: the single `enforce-pr-author-skill.Tests.ps1` "allowed commands /
  allows gh pr create --body-file" case
- baseline passing count to hold at or above (excluding tests F6 adds): **2021**

Output Summary: `mcp__drm-copilot__run_poshqc_test` exited **1** with **2021 passed, 1 failed, 0
errors, 9 skipped of 2031 total** test cases in 113.834 s (Pester 5.6.1). Baseline **line coverage
94.34%** (3148 covered / 3337 lines, 189 missed); instruction 93.95%, method 90.23%, class 95.12%;
Pester emits no BRANCH counter so no PowerShell branch figure exists. Line coverage exceeds the >= 85%
threshold by 9.34 pp. The single failure is **PRE-EXISTING and OUT OF SCOPE**:
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` expects `allow` but the hook returns
`deny` because the test reads the real gitignored `artifacts/orchestration/orchestrator-state.json`
instead of a mocked seam, and an orchestrated run is live. That file is not edited by this plan. The
second file named in the directive,
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, **passed** (6/6) at this baseline
and is recorded as passing rather than assumed failing.
