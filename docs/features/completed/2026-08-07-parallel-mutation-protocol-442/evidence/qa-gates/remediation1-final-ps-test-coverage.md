# Remediation Cycle 1 — Final QA: PowerShell Pester Tests and Coverage

Timestamp: 2026-08-09T09-03

Task: [P7-T7]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`
(no `scan_folders` argument, so the scan set resolves from `config/poshqc-scan.json`
`test.scanFolders`)

EXIT_CODE: 1

The non-zero exit is caused **entirely** by the ONE pre-existing, out-of-scope failure named below,
which fails identically at the Phase 0 baseline. The MCP wrapper prints no counts, so the numeric
values were read from the two result files the run wrote, `artifacts/pester/pester-junit.xml` and
`artifacts/pester/powershell-coverage.xml`, both pre-existing PoshQC output locations rather than
evidence paths.

## Test Result Counts (numeric, no placeholders)

Root JUnit element:

```xml
<testsuites name="Pester" tests="2053" errors="0" failures="1" disabled="9" time="94.099">
```

| Metric | Post-change | Baseline ([P0-T7]) | Delta |
| --- | --- | --- | --- |
| Total test cases | 2053 | 2053 | 0 |
| **Passed** | **2043** | 2043 | **0** |
| **Failed** | **1** (pre-existing) | 1 (same) | **0** |
| Errors | 0 | 0 | 0 |
| Skipped / disabled | 9 | 9 | 0 |
| Wall time | 94.099 s | 98.418 s | -4.3 s |

Per-case status tally: `Passed 2043`, `Failed 1`, `Skipped 9`; 2043 + 1 + 9 = 2053, reconciling
exactly with the root element. **Every count is identical to baseline**, which is the expected result
because this cycle edits no PowerShell file.

## The Single Failure — PRE-EXISTING and OUT OF SCOPE

- Test file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Failing case: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: `enforce-pr-author-skill.Tests.ps1:142`
- Message: `Expected: 'allow' But was: 'deny'`

Cause: the test reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of
a mocked read seam, so its verdict tracks live orchestration state while an orchestrated run is live.
It is the test's missing seam, not a defect in the hook.

**This is the ONLY failure in the 2053-case run, and it is byte-identical in identity, assertion site,
and message to the Phase 0 baseline capture.** It was NOT fixed, NOT edited, and does not block
completion. **No other Pester failure occurred, so nothing is attributable to this remediation
cycle.**

## Aggregate Coverage — Numeric Post-Change Values

Report-level counters from `artifacts/pester/powershell-coverage.xml`:

```xml
  <counter type="INSTRUCTION" missed="278" covered="4316" />
  <counter type="LINE" missed="189" covered="3148" />
  <counter type="METHOD" missed="26" covered="240" />
  <counter type="CLASS" missed="2" covered="39" />
```

| Coverage metric | Post-change | Baseline | Threshold | Verdict |
| --- | --- | --- | --- | --- |
| **Line coverage** | **94.3362%** (3148 / 3337; 189 missed) | 94.3362% | >= 85% | **PASS**, margin +9.34 pp, **no regression** |
| Instruction coverage | 93.9486% (4316 / 4594) | 93.9486% | not a policy threshold | unchanged |
| Method coverage | 90.2256% (240 / 266) | 90.2256% | not a policy threshold | unchanged |
| Class coverage | 95.122% (39 / 41) | 95.122% | not a policy threshold | unchanged |

Pester's JaCoCo output carries **no `BRANCH` counter**, so this toolchain produces no PowerShell
branch-coverage figure. The line figure above is the recorded PowerShell coverage headline.

## Coverage of `.claude/hooks/enforce-parallel-abandon-gate.ps1` (numeric)

The hook is ABSENT from the aggregate report because
`mcp__drm-copilot__run_poshqc_test` resolves its Pester run settings — including the
`CodeCoverage.Path` allowlist — from the INSTALLED extension's bundled resources rather than from the
workspace passed as `workspace_root`. The base plan's edit appending the hook to the allowlist is
present in both in-repo copies and takes effect on the next extension rebuild. Rather than record a
placeholder or infer zero, the hook was measured directly.

Command: `pwsh -NoProfile -File <scratchpad>/measure-abandon-gate.ps1`, which invokes `Invoke-Pester`
(Pester 5.6.1) with `Run.Path` set to the hook's test file and `CodeCoverage.Path` set to the hook,
writing its coverage XML to the session scratchpad so no artifact is added to the branch.
EXIT_CODE: 0

```
PESTER_VERSION=5.6.1
TOTAL=22 PASSED=22 FAILED=0 SKIPPED=0
ANALYZED=57 EXECUTED=48 MISSED=9
COVERAGE_PERCENT=84.2105263157895
FILES_ANALYZED=1
MISSED_LINES=56,251,251,253,254,257,257,257,259
COUNTER INSTRUCTION missed=9 covered=48
COUNTER LINE missed=6 covered=40
COUNTER METHOD missed=1 covered=8
COUNTER CLASS missed=0 covered=1
```

| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | Value | Threshold | Verdict |
| --- | --- | --- | --- |
| **Line coverage** | **86.96%** (40 covered / 46 lines; 6 missed) | >= 85% | **PASS**, margin +1.96 pp |
| Instruction coverage | 84.2105% (48 / 57; 9 missed) | not a policy threshold | recorded |
| Method coverage | 88.89% (8 / 9; 1 missed) | not a policy threshold | recorded |
| Tests exercising the file | 22 passed / 0 failed | n/a | PASS |

**86.96% is identical to the figure the base plan recorded**, confirming this cycle changed nothing
about the hook. The 6 uncovered lines are the two deliberately host-bound regions, each the thinnest
possible wiring per `.claude/rules/general-unit-test.md` § Coverage Exclusion Policy: line 56, the
body of the injectable read seam `return $env:CLAUDE_TOOL_INPUT`, which tests replace with a mock;
and lines 251-259, the entry-point wiring after the dot-source guard, which by design does not execute
when the test dot-sources the file. **No part of the decision logic is uncovered.**

## Output Summary

`mcp__drm-copilot__run_poshqc_test` exited **1** with **2043 passed / 1 failed / 9 skipped of 2053
total** cases in 94.099 s — every count identical to baseline. Post-change **line coverage 94.3362%**
(3148 / 3337, 189 missed), identical to baseline, so there is **no PowerShell coverage regression**;
the >= 85% threshold is met with a +9.34 pp margin. Pester emits no BRANCH counter, so no PowerShell
branch figure exists. The single failure is the **PRE-EXISTING and OUT OF SCOPE**
`enforce-pr-author-skill.Tests.ps1` "allows gh pr create --body-file" case, unedited and identical to
baseline; it is the only PowerShell failure. Coverage of
`.claude/hooks/enforce-parallel-abandon-gate.ps1` is **86.96% line (40/46)**, measured directly and
unchanged from the base plan's figure.

Acceptance: the only failure is the pre-existing `enforce-pr-author-skill.Tests.ps1:142` case,
unedited; every other test passes; numeric coverage recorded. **PASS.**
