# Remediation Cycle 1 — PowerShell Pester Test and Coverage Baseline

Timestamp: 2026-08-09T06-27

Task: [P0-T7]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
HEAD at capture: a9e2463c
Working tree at capture: clean (no remediation edit applied yet)

Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`
(no `scan_folders` argument, so the scan set resolves from `config/poshqc-scan.json`
`test.scanFolders`)

EXIT_CODE: 1

The non-zero exit code is caused entirely by ONE pre-existing, out-of-scope failure, named below.
The MCP wrapper prints no counts, so the numeric values were read from the two result files the
run wrote: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`.
Both are pre-existing PoshQC tool output locations, not evidence paths.

## Raw MCP Output

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c",
  "summary": "Command exited with code 1."
}
```

## Test Result Counts (numeric, no placeholders)

Root JUnit element:

```xml
<testsuites name="Pester" tests="2053" errors="0" failures="1" disabled="9" time="98.418">
```

| Metric | Baseline value |
| --- | --- |
| Total test cases | 2053 |
| **Passed** | **2043** |
| **Failed** | **1** (pre-existing, named below) |
| Errors | 0 |
| **Skipped / disabled** | **9** |
| Wall time | 98.418 s |

Per-case status tally: `Passed 2043`, `Failed 1`, `Skipped 9`; 2043 + 1 + 9 = 2053, reconciling
exactly with the root element.

The F6 suite `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` reports
`tests="22" failures="0"`.

## The Single Failure — PRE-EXISTING and OUT OF SCOPE

- Test file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- Failing case: `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Assertion site: `enforce-pr-author-skill.Tests.ps1:142`
- Message: `Expected strings to be the same, but they were different. Expected length: 5, Actual length: 4, Strings differ at index 0. Expected: 'allow' But was: 'deny'`

Cause: the test reads the real gitignored `artifacts/orchestration/orchestrator-state.json`
instead of a mocked read seam. An orchestrated run is live and that checkpoint has been written,
so the hook correctly returns `deny` where the test's fixture-free expectation assumes `allow`.
This is the test's missing seam, not a defect in the hook and not anything this remediation cycle
touches.

**This is the ONLY failure in the 2053-case run.** It must remain the only PowerShell failure,
must not be fixed, and must not be edited. Any OTHER Pester failure at [P7-T7] is attributable to
this cycle and must be fixed.

## Coverage — Numeric Baseline Values (no placeholders)

Report-level counters from `artifacts/pester/powershell-coverage.xml`:

```xml
  <counter type="INSTRUCTION" missed="278" covered="4316" />
  <counter type="LINE" missed="189" covered="3148" />
  <counter type="METHOD" missed="26" covered="240" />
  <counter type="CLASS" missed="2" covered="39" />
```

| Coverage metric | Baseline value | Threshold | Verdict |
| --- | --- | --- | --- |
| **Line coverage** | **94.3362%** (3148 covered / 3337 total; 189 missed) | >= 85% | PASS, margin +9.34 pp |
| Instruction coverage | 93.9486% (4316 / 4594; 278 missed) | not a policy threshold | recorded |
| Method coverage | 90.2256% (240 / 266; 26 missed) | not a policy threshold | recorded |
| Class coverage | 95.122% (39 / 41; 2 missed) | not a policy threshold | recorded |

Pester's JaCoCo output carries no `BRANCH` counter, so this toolchain produces no PowerShell
branch-coverage figure. The line figure above is the recorded PowerShell coverage headline and is
the comparison basis for [P7-T7] and [P7-T8].

## Recorded Measurement Property (not a defect, not zero coverage)

`.claude/hooks/enforce-parallel-abandon-gate.ps1` is ABSENT from
`artifacts/pester/powershell-coverage.xml` even though its 22 Pester cases ran and passed. The
reason is tool resolution, not missing coverage: `mcp__drm-copilot__run_poshqc_test` resolves its
Pester run settings — including the `CodeCoverage.Path` allowlist — from the INSTALLED
extension's bundled resources, not from the workspace passed as `workspace_root`. The base plan's
edit appending the hook to the allowlist in both in-repo copies is present and correct, but it
does not change what the current session's MCP run measures; a future extension rebuild picks it
up. The base plan measured the hook directly at 86.96% line (40/46) with a targeted
`Invoke-Pester` run (recorded in `<FEATURE>/evidence/qa-gates/final-ps-test-coverage.md`).
This remediation cycle edits no PowerShell file, so no change to that figure is expected;
[P7-T7] re-measures it rather than inferring it.

Output Summary: `mcp__drm-copilot__run_poshqc_test` exited **1** with **2043 passed / 1 failed /
9 skipped of 2053 total** cases in 98.418 s. Baseline **line coverage 94.3362%** (3148 covered /
3337 lines, 189 missed); no branch figure exists for PowerShell. The single failure is
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` case "allows gh pr create
--body-file artifacts/pr_body_12.md when context exists" at `:142`, which is PRE-EXISTING and
OUT OF SCOPE and must remain the only PowerShell failure.
