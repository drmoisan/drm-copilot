# PowerShell Test and Coverage Baseline — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T9]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-23

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

The non-zero exit code is the expected consequence of the single pre-existing failure named below. The Pester run settings set `Run.Exit = $true`, so one failing case produces exit code 1 for the whole batch.

## Output Summary

Counts parsed from the emitted JUnit report `artifacts/pester/pester-junit.xml` (written by this run at 00:23; `TestResult.OutputFormat = 'JUnitXml'` per `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`):

```
<testsuites ... name="Pester" tests="2141" errors="0" failures="1" disabled="9" time="96.265">
```

Per-case status tally across the whole report:

| Status | Count |
|---|---|
| Passed | **2131** |
| Failed | **1** |
| Skipped | **9** |
| **Total** | **2141** |

**The three counts reconcile: 2131 + 1 + 9 = 2141**, which equals the `tests="2141"` attribute on the `<testsuites>` root. `errors="0"`.

### The single failure — expected, pre-existing, out of scope

File: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
Case: `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`

Verbatim from the JUnit report:

```
<testcase name="enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists" status="Failed" ... time="0.046">
  <failure message="Expected strings to be the same, but they were different.
Expected length: 5
Actual length:   4
Strings differ at index 0.
Expected: 'allow'
But was:  'deny'
           ^">at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1:142
```

This case reads the live gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam, so it fails whenever an orchestrated run is in flight. It is the single known pre-existing failure recorded in the plan's Out of Scope section. No task in this cycle fixes or edits it. **This is the only failure; there is no second failure and no new failure.**

### Coverage headline

Parsed from the emitted `artifacts/pester/powershell-coverage.xml` (`CodeCoverage.OutputFormat = 'CoverageGutters'`, a JaCoCo-shaped report). Report-level counters:

```
<counter type="INSTRUCTION" missed="278" covered="4316" />
<counter type="LINE" missed="189" covered="3148" />
<counter type="METHOD" missed="26" covered="240" />
<counter type="CLASS" missed="2" covered="39" />
```

- **Command/instruction coverage: 93.95%** — 4316 covered of 4594 total (4316 + 278).
- **Line coverage: 94.34%** — 3148 covered of 3337 total (3148 + 189).

**BRANCH: not emitted by PoshQC/Pester coverage output.** The report emits only `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters; there is no `BRANCH` counter at report, package, or class level. No branch percentage can be recorded for the PowerShell surface, and none is fabricated here.

The run settings also set `CodeCoverage.CoveragePercentTarget = 0`, so coverage does not contribute to the exit code; the exit code reflects the one failing case only.

**Scope caveat on the coverage figures.** `mcp__drm-copilot__run_poshqc_test` executes the installed extension bundle's runner, which imports the installed bundle's module-root-relative `settings/pester.runsettings.psd1`. The two in-repo copies of that file are modified in the working tree by the original plan (each with a 7-line insertion registering the new parallel hooks), and those edits take effect only after the bundle is republished. The aggregate coverage figures above therefore reflect the installed bundle's `CodeCoverage.Path` scope, not the in-repo scope. This does not affect any acceptance criterion in this cycle: [P0-T9] requires only the aggregate headline and the failure set, and **this remediation cycle adds and modifies no PowerShell file**, so there is no new PowerShell production file whose per-file coverage would need to be measured. [P3-T2] likewise compares only the failure set, which is unaffected.

### Working-tree effect

`git status --porcelain | wc -l` after the run reported `31` — unchanged from the pristine pre-remediation count. `git check-ignore -v artifacts/pester/pester-junit.xml` reports `.gitignore:6:/artifacts`, so both emitted reports are gitignored and added no working-tree entry.

## Determination

Exactly one failure, and it is the named pre-existing out-of-scope case. The three counts reconcile to the reported total of 2141. P3-T2 compares against this failure set: its acceptance is satisfied only when the failure set is identical to this one — exactly this single case — with no new failure.
