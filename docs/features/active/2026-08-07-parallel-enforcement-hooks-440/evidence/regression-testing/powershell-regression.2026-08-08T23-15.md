# PowerShell Regression Confirmation — Issue #440 F7 Remediation Cycle 1

- **Task:** [P3-T2]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`
- **Baseline compared against:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/remediation-baseline/powershell-tests-coverage.2026-08-08T23-15.md` ([P0-T9])

Timestamp: 2026-08-09T01-04

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee` (no `scan_folders`, so the scan set resolves from `config/poshqc-scan.json`)

EXIT_CODE: 1

MCP dispatcher response, verbatim:

```
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a0b28ae2f972ac0ee",
  "summary": "Command exited with code 1."
}
```

The non-zero exit code is the expected consequence of the single pre-existing failure named below, identical in kind to the [P0-T9] baseline, which also exited 1. The Pester run settings set `Run.Exit = $true`, so one failing case produces exit code 1 for the whole batch. **This is not a regression**: the baseline exit code was also 1 for exactly the same reason.

## Output Summary

Counts parsed from the emitted JUnit report `artifacts/pester/pester-junit.xml` (written by this run; `TestResult.OutputFormat = 'JUnitXml'` per `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`):

```
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="2141" errors="0" failures="1" disabled="9" time="101.380">
```

Per-case status tally across the whole report:

| Status | Count | [P0-T9] baseline | Delta |
| --- | --- | --- | --- |
| Passed | **2131** | 2131 | 0 |
| Failed | **1** | 1 | 0 |
| Skipped | **9** | 9 | 0 |
| **Total** | **2141** | 2141 | 0 |

**The three counts reconcile: 2131 + 1 + 9 = 2141**, which equals the `tests="2141"` attribute on the `<testsuites>` root. `errors="0"`.

The tally was produced by counting per-case `status="..."` attributes in the report:

```
$ grep -c 'status="Passed"' artifacts/pester/pester-junit.xml   -> 2131
$ grep -c 'status="Failed"' artifacts/pester/pester-junit.xml   -> 1
$ grep -c 'status="Skipped"' artifacts/pester/pester-junit.xml  -> 9
```

### The single failure — expected, pre-existing, out of scope

File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
Case: `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`

Verbatim from the JUnit report:

```
<testcase name="enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists" status="Failed" classname="...\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1" assertions="0" time="0.063">
  <failure message="Expected strings to be the same, but they were different.
Expected length: 5
Actual length:   4
Strings differ at index 0.
Expected: 'allow'
But was:  'deny'
           ^">at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', ...\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:142
```

**Attribution.** This case reads the live gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam, so it fails whenever an orchestrated run is in flight — which it is, because this remediation cycle is itself an orchestrated run. It is byte-for-byte the same case, same assertion, same line 142, and same expected-versus-actual pair (`'allow'` versus `'deny'`) as the [P0-T9] baseline failure. It is named in the plan's Out of Scope section, the file is not in this branch's diff, and no task in this cycle fixes or edits it.

**Failure-set comparison against the [P0-T9] baseline:**

| | Baseline failure set | Post-change failure set |
| --- | --- | --- |
| Count | 1 | 1 |
| Member | `enforce-pr-author-skill.Tests.ps1 :: allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | `enforce-pr-author-skill.Tests.ps1 :: allows gh pr create --body-file artifacts/pr_body_12.md when context exists` |

**The two failure sets are identical. There is no second failure and no new failure.**

### Coverage headline

Parsed from the emitted `artifacts/pester/powershell-coverage.xml` (`CodeCoverage.OutputFormat = 'CoverageGutters'`, a JaCoCo-shaped report). Report-level counters:

```
<counter type="INSTRUCTION" missed="278" covered="4316" />
<counter type="LINE" missed="189" covered="3148" />
<counter type="METHOD" missed="26" covered="240" />
<counter type="CLASS" missed="2" covered="39" />
```

- **Command/instruction coverage: 93.95%** — 4316 covered of 4594 total (4316 + 278). Identical to the [P0-T9] baseline.
- **Line coverage: 94.34%** — 3148 covered of 3337 total (3148 + 189). Identical to the [P0-T9] baseline.

**BRANCH: not emitted by PoshQC/Pester coverage output.** `grep -c 'type="BRANCH"' artifacts/pester/powershell-coverage.xml` returns `0`: the report emits only `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters at report, package, and class level. No branch percentage can be recorded for the PowerShell surface, and none is fabricated here. This is the same explicit absence note recorded at [P0-T9].

The run settings set `CodeCoverage.CoveragePercentTarget = 0`, so coverage does not contribute to the exit code; the exit code reflects the one failing case only.

**No PowerShell file is in this cycle's change set.** This remediation cycle adds and modifies no `.ps1` or `.psd1` file, so the identical coverage figures are the expected outcome and there is no new PowerShell production file whose per-file coverage would need to be measured.

### Working-tree effect

`git status --porcelain | wc -l` after the run reported `39` — the post-Phase-2 count, unchanged by this run. `artifacts/` is gitignored (`.gitignore:6:/artifacts`), so both emitted reports added no working-tree entry.

## Determination

Exactly one failure, and it is the named pre-existing out-of-scope case, identical to the [P0-T9] baseline failure. The three counts (2131 passed, 1 failed, 9 skipped) reconcile to the reported total of 2141 and match the baseline exactly. **The failure set is identical to the [P0-T9] baseline and no new failure appeared. The PowerShell suite is unaffected by this remediation cycle.**
